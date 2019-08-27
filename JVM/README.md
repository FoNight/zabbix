使用方法：

1.将需要的jar包放置/lib下

2.将脚本jmx_discovery.sh 放置zabbix配置文件目录下 本文在/usr/local/zabbix-2.4.5/etc/zabbix_agentd.conf.d/下

	2.1 # 执行脚本，输出JSON串儿，验证是否正确

3.zabbix导入模板Template_App_Tomcat.xml

	3.1 # 根据具体TomCat配置修改监控指标是否启用