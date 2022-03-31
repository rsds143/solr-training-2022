
if [ "x$JVM_DEPENDENT_DONE" = "x" ]; then
    # Prevent duplicate execution of this block
    JVM_DEPENDENT_DONE=1

    # Use JAVA_HOME if set, otherwise look for java in PATH
    if [ -x "$JAVA_HOME/bin/java" ]; then
        JAVA="$JAVA_HOME/bin/java"
    else
        JAVA="`which java`"
    fi

    if [ "x$JAVA" = "x" ]; then
        echo "Java executable not found (hint: set JAVA_HOME)" >&2
        exit 1
    fi

    # Determine the sort of JVM we'll be running on.
    #
    # This single sed invocation extracts:
    # - the major java version, for Java 8 the patch version
    # - the JVM Vendor
    # - the architecture (64 or 32 bit)
    # Known version banners (1st line):
    #   OpenJDK/8:          openjdk version "1.8.0_181"
    #   OpenJDK/11:         openjdk version "11.0.1" 2018-10-16
    #   Oracle/8:           java version "1.8.0_181"
    #   Oracle/11:          java version "11" 2018-09-25
    #   adoptopenjdk/8:     openjdk version "1.8.0-adoptopenjdk" 2018-11-11 (3rd replacement in the sed script)
    #   adoptopenjdk/11:    openjdk version "11-adoptopenjdk" 2018-11-11
    #   GraalVM/8:          openjdk version "1.8.0_192"
    #   Zing/8:             java version "1.8.0-zing_16.07.0.0"
    #   OpenJ9:             (same as OpenJDK)
    # Known version banners (3rd line):
    #   OpenJDK/8:          OpenJDK 64-Bit Server VM (Zulu 8.31.0.1-linux64) (build 25.181-b02, mixed mode)
    #   OpenJDK/11:         OpenJDK 64-Bit Server VM 18.9 (build 11.0.1+13, mixed mode)
    #   Oracle/8:           Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
    #   Oracle/11:          Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11+28, mixed mode)
    #   adoptopenjdk/8:     OpenJDK 64-Bit Server VM (build 25.71-b00, mixed mode)
    #   adoptopenjdk/11:    OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11+28, mixed mode)
    #   GraalVM/8:          GraalVM 1.0.0-rc9 (build 25.192-b12-jvmci-0.49, mixed mode)
    #   Zing/8:             Zing 64-Bit Tiered VM (build 1.8.0-zing_16.07.0.0-b17-product-azlinuxM-X86_64, mixed mode)
    #   OpenJ9/8:           Eclipse OpenJ9 VM (build openj9-0.11.0, JRE 1.8.0 Linux amd64-64-Bit Compressed References 20181107_95 (JIT enabled, AOT enabled)
    #   OpenJ9/11:          Eclipse OpenJ9 VM AdoptOpenJDK (build openj9-0.11.0, JRE 11 Linux amd64-64-Bit Compressed References 20181020_70 (JIT enabled, AOT enabled)
    # Note: the returned patch version is only valid for Java 8 and is always 0 for other Java versions.
    # The version banner for OpenJ9 outputs more lines than the other JVMs.
    #
    # Warning: be careful when editing the following code and test against both bash and dash!
    jvmver_output=`"${JAVA:-java}" -version 2>&1`
    jvmver=`echo "$jvmver_output" | sed -E '{1s/^(openjdk|java) version \"([1-9][0-9])(\.[0-9.]*)?.*\".*$/\2_0/
                                             1s/^(openjdk|java) version \"1\.8\.0_([0-9]+).*\".*$/8_\2/
                                             1s/^(openjdk|java) version \"1\.8\.0.*\".*$/8_999/
                                             2,10d
                                             }'`
    # jvmver contains java version number and patch version separated by an underscore
    JAVA_VERSION=${jvmver%%_*}
    jvmver="${jvmver#*_}"
    JVM_PATCH_VERSION=${jvmver%%_*}
    jvmver=`echo "$jvmver_output" | sed -E '{1,2d
                                             3s/^(([^ ]+).*)(32|64-Bit).*/\2_\3/
                                             4,10d
                                             }'`
    JVM_VENDOR=${jvmver%%_*}
    jvmver="${jvmver#*_}"
    JVM_ARCH=${jvmver%%_*}

    if [ $JAVA_VERSION -eq 8 ] && [ $JVM_PATCH_VERSION -lt 151 ] ; then
        echo "DSE requires either Java 8 (update 151 or newer) or Java 11 (or newer). Java 8 update $JVM_PATCH_VERSION is not supported."
        exit 1
    elif [ $JAVA_VERSION -ne 8 ] && [ $JAVA_VERSION -lt 11 ] ; then
        echo "DSE requires either Java 8 (update 151 or newer) or Java 11 (or newer), but found Java $JAVA_VERSION."
        exit 1
    fi

    case "$JVM_VENDOR" in
        OpenJDK)
            ;;
        Eclipse)
            ;;
        Java)
            JVM_VENDOR=Oracle
            ;;
        GraalVM*)
            JVM_ARCH="64-Bit"
            ;;
        Zing)
            JVM_VENDOR=Azul
            ;;
        *)
            # Help fill in other JVM values
            JVM_VENDOR=other
            JVM_ARCH=unknown
            ;;
    esac

    # Read user-defined JVM options from jvm*.options files
    #
    # There are two sets of jvm*.options files. One for the DSE daemon and one for clients.
    # Only the DSE daemon needs to pass in 'jvmoptions_variant' set to '-server' to pick up
    # the correct JVM options. Clients and tools do not need to set 'jvmoptions_variant'.
    #

    JVM_OPTS_FILES=""
    if [ -f "$CASSANDRA_CONF/jvm.options" ] ; then
        JVM_OPTS_FILES="${JVM_OPTS_FILES} ${CASSANDRA_CONF}/jvm.options"
    fi
    # Load jvm*-clients.options files by default, unless 'jvmoptions_variant' specifies something else ('-server').
    if [ -f "$CASSANDRA_CONF/jvm${jvmoptions_variant:--clients}.options" ] ; then
        JVM_OPTS_FILES="${JVM_OPTS_FILES} ${CASSANDRA_CONF}/jvm${jvmoptions_variant:--clients}.options"
    fi
    if [ $JAVA_VERSION -ge 11 ] && [ -f "${CASSANDRA_CONF}/jvm11${jvmoptions_variant:--clients}.options" ] ; then
        JVM_OPTS_FILES="${JVM_OPTS_FILES} ${CASSANDRA_CONF}/jvm11${jvmoptions_variant:--clients}.options"
    fi
    if [ $JAVA_VERSION -eq 8 ] && [ -f "${CASSANDRA_CONF}/jvm8${jvmoptions_variant:--clients}.options" ] ; then
        JVM_OPTS_FILES="${JVM_OPTS_FILES} ${CASSANDRA_CONF}/jvm8${jvmoptions_variant:--clients}.options"
    fi

    if [ "x$JVM_OPTS_FILES" = "x" ]; then
      echo "Found no jvm options file, did you set CASSANDRA_DEPLOYMENT correctly?"
      exit
    fi

    for opt in `grep -h "^-" ${JVM_OPTS_FILES}` ; do
      JVM_OPTS="$JVM_OPTS $opt"
    done

    # Update GC logs JVM options only for the DSE deamon, but not for tools + clients
    if [ "${jvmoptions_variant:--clients}" = "-server" ] ; then
        #GC log path has to be defined here because it needs to access CASSANDRA_HOME
        if [ $JAVA_VERSION -ge 11 ] ; then
            # See description of https://bugs.openjdk.java.net/browse/JDK-8046148 for details about the syntax
            # The following is the equivalent to -XX:+PrintGCDetails -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10M
            echo "$JVM_OPTS" | grep -q "^-[X]log:gc"
            if [ "$?" = "1" ] ; then # [X] to prevent ccm from replacing this line
                # only add -Xlog:gc if it's not mentioned in jvm-server.options file
                mkdir -p ${CASSANDRA_LOG_DIR}
                # See notes about -Xlog in jvm11-server.options file
                JVM_OPTS="$JVM_OPTS -Xlog:gc*=info,safepoint*=info:file=${CASSANDRA_LOG_DIR}/gc.log:time,uptimenanos,tags,pid,tid,level:filecount=10,filesize=25M"
                # JVM information, gives basic information about OS, CPU, memory + container
                JVM_OPTS="$JVM_OPTS -Xlog:container*=info,logging*=info,os*=info,pagesize*=info,setting*=info,startuptime*=info,system*=info,os+thread=off:file=${CASSANDRA_LOG_DIR}/jvm.log:time,uptimenanos,tags,pid,tid,level:filecount=10,filesize=10M"
                # Debugging JIT
                #JVM_OPTS="$JVM_OPTS -Xlog:inlining*=debug,jit*=debug,monitorinflation*=debug:file=${CASSANDRA_LOG_DIR}/jit.log:time,uptimenanos,tags,pid,tid,level:filecount=10,filesize=10M"
            fi
        else
            # Java 8
            echo "$JVM_OPTS" | grep -q "^-[X]loggc"
            if [ "$?" = "1" ] ; then # [X] to prevent ccm from replacing this line
                # only add -Xloggc if it's not mentioned in jvm-server.options file
                mkdir -p ${CASSANDRA_LOG_DIR}
                JVM_OPTS="$JVM_OPTS -Xloggc:${CASSANDRA_LOG_DIR}/gc.log"
            fi
        fi
    fi
fi
