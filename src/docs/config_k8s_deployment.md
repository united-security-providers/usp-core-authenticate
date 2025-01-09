### Deployment Manifest

The deployment manifest


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
        image: reg-bob.u-s-p.local/usp/core/sls/sls:5.19.0.2
        imagePullPolicy: Always
        command: ['sh', '-v', '-c']
        args:
          - |
            rm /usr/share/usp/sls/webapps/sls/WEB-INF/user-config.xml
            cp /tmp/sls-webapp-files/user-config.xml /usr/share/usp/sls/webapps/sls/WEB-INF/user-config.xml
            keytool -genkeypair -noprompt \
             -alias sls \
             -dname "CN={{ tpl .Values.hostnames.viaWaap . }}, OU=auth, O=usp, L=john, S=doe, C=CH" \
             -keystore sls.jks \
             -storepass changeit \
             -keypass changeit \
             -keyalg RSA
            mv sls.jks /usr/share/usp/sls/webapps/sls/WEB-INF/
            catalina.sh run
        volumeMounts:
          - mountPath: /var/lib/usp/sls/config
            name: sls-config-volume
          - mountPath: /tmp/sls-webapp-files
            name: sls-webapp-volume
      volumes:
        - configMap:
            defaultMode: 0775
            name: sls-config
          name: sls-config-volume
        - configMap:
            defaultMode: 0775
            name: sls-webapp-files
          name: sls-webapp-volume
  selector:
    matchLabels:
      app.kubernetes.io/instance: slsoidcop
```