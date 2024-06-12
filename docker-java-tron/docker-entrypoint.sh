#!/bin/bash
set -eou pipefail

export JAVA_TOOL_OPTIONS="-XX:+UseConcMarkSweepGC -XX:+PrintGCDetails -Xloggc:./gc.log -XX:+PrintGCDateStamps -XX:+CMSParallelRemarkEnabled -XX:ReservedCodeCacheSize=256m -XX:+CMSScavengeBeforeRemark -Xms9g -Xmx24g -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -XX:MaxDirectMemorySize=1G -XX:NewRatio=2 -XX:+ParallelRefProcEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70"

echo "Initialization completed successfully"

exec "$@"
