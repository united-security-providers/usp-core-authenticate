# Adding custom files

In some cases it might be necessary to create or add custom files to the container. One way of doing this is 
to have those files on an external volume and mount that directly into the SLS web application; the other one
is to override and extend the startup command of the container, and add any custom directive as need, before
launching the Tomcat server.

## Adding custom JSP example

If a custom JSP file should be added to the existing files, and it is not possible to do this through a simple mount
directly into the "jsp" folder of the SLS web application, an alternative approach would be:

- Put the single JSP on a local volume (or in case of a Kubernetes environment possibly in a ConfigMap) and mount
  this as a temporary folder in the container
- Copy the file at startup time from that temporary folder to the target "jsp" folder in the SLS web application
- Launch Tomcat

Here is an example deployment manifest that mounts the volume with the custom JSP file to "/tmp/jsp-file/" and
then copies the file from there into the SLS "jsp" folder in the customized startup command:


```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: slsoidcop
  namespace: acme-authenticate
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: slsoidcop
    spec:
      containers:
      - name: slsoidcop
        image: devuspregistry.azurecr.io/usp/core/sls/sls:%SLS_VERSION%
        imagePullPolicy: Always
        # Override Tomcat container startup command to perform custom operations
        command: ['sh', '-v', '-c']
        args:
          - |
            # Copy custom JSP file from temporary path into SLS jsp folder
            cp /tmp/sls-jsp-file/*.jsp /usr/share/usp/sls/webapps/sls/WEB-INF/jsp/
            # Now execute original Tomcat container startup command
            catalina.sh run
        volumeMounts:
          # Mount the override properties
          - mountPath: /var/lib/usp/sls/config
            name: sls-config-volume
          # Mount volume "sls-jsp-volume" into temporary path "/tmp/jsp-file"
          - mountPath: /tmp/jsp-file
            name: sls-jsp-volume
      volumes:
        - configMap:
            defaultMode: 0775
            name: sls-config
          name: sls-config-volume
        - configMap:
            defaultMode: 0775
            # Create volume "sls-jsp-volume" with contents from ConfigMap "sls-jsp-file"
            name: sls-jsp-file
          name: sls-jsp-volume
  selector:
    matchLabels:
      app.kubernetes.io/instance: slsoidcop
```

And the ConfigMap "sls-jsp-file" with the custom JSP could look like this:

```
kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    app.kubernetes.io/instance: slsoidcop
    app.kubernetes.io/name: slsoidcop
  name: sls-jsp-file
  namespace: acme-authenticate
data:
  Login.jsp: |
    <%@ page session="true" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>
        <head>
            <title>Custom Page</title>
        </head>
        <body>
          <h1>Hello World</h1>
        </body>
    </html>
```