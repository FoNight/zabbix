#!/bin/bash
# auth hzh
# date 2019-08-16

Host="127.0.0.1"

# 过滤已添加JMX配置的TomCat
jmx_TomCat=`ps aux | grep tomcat | grep "jmxremote" | grep -v grep  | awk -F'file=' '{print $2}' | awk -F'conf' '{print $1}'`


# 统计本机TomCat实例个数 
tomcat_no=`echo "${jmx_TomCat}" | wc -l `

i=1
cmd="/lib/cmdline-jmxclient-0.10.3.jar"
java_cmd=`which java`

# --输出JSON文件--
printf '{\n\t"data":[\n'
for tomcat in $jmx_TomCat                                                                    
do
	# 这里的NF不一能提提取tomcat服务名，可需要修改为:NF-1。
    t_service=`echo "$tomcat"|awk -F"/" '{print $(NF-1)}'`  

    # 获取JMX端口
    n_port=`grep 'jmxremote.port' "${tomcat}"/bin/catalina.sh | grep -v '^#'| awk -F'jmxremote.port=' '{print $2}' | awk '{print $1}'`

    # 获取TomCat Web端口
    t_port=`${java_cmd} -jar "${cmd}" - "${Host}":"${n_port}" |grep 'ThreadPool' | grep "http"|  awk -F'"' '{print $2}'`

    # 获取TomCat PID
    t_pid=`ps -ef | grep -Ev 'grep|jmxclient' | grep "${n_port}"| awk '{print $2}'`

    # 获取JDBC id
    j_id=`${java_cmd} -jar "${cmd}" - "${Host}":"${n_port}" | grep "alibaba" | grep id= | awk -F':' '{print $2}'| awk -F',' '{print $1}' | head -n 1`

    # 调试输出TomCat PID
    # echo JMX_PORT:${n_port},t_pid:${t_pid}

    # 获取TomCat部署项目文件夹名称,过滤不需要统计的应用目录(根据实际需要修改 -Ev 参数后名称 以 | 分隔)
    ignore_name="/,|tiao|manager,|examples|docs"
    app_name=`${java_cmd} -jar "${cmd}" - "${Host}":"${n_port}" | grep  'type=Manager'| grep -Ev "${ignore_name}" | awk -F',' '{print $1}'| awk -F'=' '{print $2}'`
    
    # 调试输出
    # echo "${app_name}"

    # 判断如果是最后一个TomCat，则打印格式为else下
        if [ "$i" != "${tomcat_no}" ];then
                printf "\t\t{ \n"
                printf "\t\t\t\"{#JMX_PORT}\":\"${n_port}\",\n"
                printf "\t\t\t\"{#TOMCAT_PORT}\":\"${t_port}\",\n"
                printf "\t\t\t\"{#TOMCAT_PID}\":\"${t_pid}\",\n"
                printf "\t\t\t\"{#JDBC_ID}\":\"${j_id}\",\n"
                printf "\t\t\t\"{#APP_PATH_NAME}\":\"${app_name}\",\n"
                printf "\t\t\t\"{#JAVA_NAME}\":\"${t_service}\"\n\t\t},\n"
        else
                printf "\t\t{ \n"
                printf "\t\t\t\"{#JMX_PORT}\":\"${n_port}\",\n"
                printf "\t\t\t\"{#TOMCAT_PORT}\":\"${t_port}\",\n"
                printf "\t\t\t\"{#TOMCAT_PID}\":\"${t_pid}\",\n"
                printf "\t\t\t\"{#JDBC_ID}\":\"${j_id}\",\n"
                printf "\t\t\t\"{#APP_PATH_NAME}\":\"${app_name}\",\n"
                printf "\t\t\t\"{#JAVA_NAME}\":\"${t_service}\"\n\t\t}\n\t\t]\n}\n"
        fi
        let "i=i+1"
done

#  jmx_discovery.sh  脚本位置根据实际情况修改

# UserParameter=java.jmx.discovery,/usr/local/zabbix-2.4.5/etc/zabbix_agentd.conf.d/jmx_discovery.sh
# UserParameter=java.Runtime.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=Runtime "$2" 2>&1 |grep $2 |awk '{print $NF}'
# UserParameter=java.Memory.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=Memory "$2" 2>&1 |grep $2 |awk '{print $NF}'
# UserParameter=java.System.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=OperatingSystem "$2" 2>&1 |grep "$2" |awk '{print $NF}'
# UserParameter=java.HeapMemoryUsage.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=Memory HeapMemoryUsage 2>&1 |grep "$2" |awk '{print $NF}'
# UserParameter=java.NonHeapMemoryUsage.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=Memory NonHeapMemoryUsage 2>&1 |grep "$2" |awk '{print $NF}'
# UserParameter=java.LoadClass.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=ClassLoading "$2" 2>&1 |awk '{print $NF}'
# UserParameter=java.Threading.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=Threading "$2" 2>&1 |awk '{print $NF}'
# UserParameter=java.MemoryPool.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=MemoryPool,"$2" Usage 2>&1 | grep "$3" | awk '{print $NF}'
# UserParameter=java.Gc.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" java.lang:type=GarbageCollector,name="$2" "$3" 2>&1 | awk '{print $NF}'
# UserParameter=tomcat.ThreadPool.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" Catalina:type=ThreadPool,name=\"$2\" "$3" 2>&1 | awk '{print $NF}'
# UserParameter=tomcat.GlobalRequestProcessor.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" Catalina:type=GlobalRequestProcessor,name=\"$2\" "$3" 2>&1 | awk '{print $NF}'
# UserParameter=tomcat.Version[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" Catalina:type=Server serverInfo 2>&1 | awk '{print $NF}'
# UserParameter=tomcat.Session.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" Catalina:type=Manager,context="$2",host=localhost $3 2>&1 | awk '{print $NF}'
# UserParameter=tomcat.Cpu.status[*],/usr/bin/top -bn 1 -p "$1" | grep "$1" | awk '{print $$9}'
# UserParameter=tomcat.DruidDataSource.status[*],java -jar /lib/cmdline-jmxclient-0.10.3.jar - 127.0.0.1:"$1" com.alibaba.druid:"$2",type=DruidDataSource "$3" 2>&1 | awk '{print $NF}'

