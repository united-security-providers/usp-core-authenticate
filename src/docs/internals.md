# Internals

## SLS Tomcat and Web Application

The Core Authenticate container runs a Tomcat instance with a Secure Login Service (SLS) instance. 

* External plain HTTP listening port: 8080
* External secure HTTPS listening port: none

As of now, there is no HTTPS port configured. You may do this yourself, if necessary, by mounting a custom
Tomcat configuration into the "conf" subdirectory of the Tomcat instance.

The SLS is a Java web application in the Tomcat "webapp" folder. The directory structure as a whole looks like this:

/<tomcat base path>/
  webapp/
    sls/
      WEB-INF/   -  Most SLS configuration files are stored in this directory
        jsp/     -  The JSPs (Java Server Pages) are stored here
  ...MORE TBD....

This is relevant in case it is necessary to mount custom configuration. In order to use custom JSPs, for instance,
it would be necessary to mount a volume with the custom JSPs into the "jsp" subfolder of the SLS "WEB-INF" directory.

When running the container in Kubernetes, it is also possible to use "ConfigMap" manifests instead of actual volumes
(see ####TODO#### for details and examples).

