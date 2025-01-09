# Logging Settings

The SLS employs a custom USP logger derived from Log4j 1 (all known Log4j 1 vulnerabilities eliminated and some custom
functionality added). The configuration file is located in the "WEB-INF" folder of the SLS web application:

- ```/usr/share/usp/sls/webapps/sls/WEB-INF/usp-logging.xml```

This file has the same structure as the "log4j.xml" files had.  The log files are written to this folder:

- ```/usr/share/usp/sls/logs/```

For details on how to configure logging, please consult the chapter about logging in the 
[SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x19283_Heading1Tarsec_Logging)
