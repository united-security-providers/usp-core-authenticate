# Container Internals

## SLS Tomcat and Web Application

The Core Authenticate container runs a Tomcat instance with a Secure Login Service (SLS) instance. 

* External plain HTTP listening port: 8080

As of now, there is no HTTPS port configured. You may do this yourself, if necessary, by mounting a custom
Tomcat configuration into the "conf" subdirectory of the Tomcat instance.

### Base directories

The base (aka "CATALINA_HOME") directory of the Tomcat instance is

- ```/usr/share/usp/sls/```

The SLS is a Java web application in the Tomcat "webapp/sls" subfolder:

- ```/usr/share/usp/sls/webapps/sls/```

### Log files

All SLS log files are written to the "logs" subfolder of the Tomcat instance:

- ```/usr/share/usp/sls/logs/```

### Tomcat configuration

The Tomcat configuration ("server.xml" with listeners etc.) is, as usual, in the "conf" subfolder of the Tomcat instance:

- ```/usr/share/usp/sls/conf/```

### Main SLS configuration

Most SLS configuration files are within the ```WEB-INF``` subfolder:

- ```/usr/share/usp/sls/webapps/sls/WEB-INF/```

#### Configuration Customization

NOTE: In most use-cases it will not be necessary to mount any external files in here. Instead, the SLS in this container
provides a pre-configured override mechanism which allows to mount one single properties file into a special pre-defined 
path; any configuration property set in a properties file in that path will override a corresponding pre-configured 
property in the SLS web application.

Configuration override path:

- ```/var/lib/usp/sls/config```

Any properties file mounted into this path will be processed by the SLS at startup time, and any configuration properties
found there (either in one single or in multiple properties files) will automatically be used and prioritized over
the configuration properties in the internal default configuration.

Generally speaking, all properties-based SLS configuration can be put into a single file. It can be split up into 
multiple files in order to help organizing and grouping settings, but the SLS will internally merge them all into 
a single Java properties object.

#### Example Custom Configuration

So, in order to configure the SLS to use the LDAP adapter for authentication and to set the LDAP adapter settings,
a properties file with the following example contents would have to be mounted into this example path:

- File: ```override.properties```
- Mount path: ```/var/lib/usp/sls/config/override.properties```
- Contents:

```properties
adapter.authentication=ldap
ldap.url=#{var('ldap_backend_system')}
ldap.principal.default=myLdapTechPrincipal
ldap.password.default=12345678
ldap.auth.type=bind
ldap.auth.bind.principal=#{var('ldap.search.dn')}
ldap.auth.search.1=l=partners,dc=acme,dc=com
ldap.auth.search.2=l=employees,dc=acme,dc=com
ldap.auth.search.attributes=modifiersName,subschemaSubentry
ldap.auth.filter=(cn=#{session.getCred('username')})
ldap.auth.successful.search.required=true
```

### JSPs

All the JSP files (Java Server Pages) for the HTML frontend are in the ```jsp``` subfolder:

- ```/usr/share/usp/sls/webapps/sls/WEB-INF/jsp/```

When using custom JSP files, the external volume containing the custom JSPs must be mounted into this path.

