# Deployment Manifest

The deployment manifest for the Core Authenticate container looks, at the minimum, something like this:

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
            # Create a new keystore with a key pair for OIDC OP / SAML operations
            keytool -genkeypair -noprompt \
             -alias sls \
             -dname "CN=acme.com, OU=auth, O=usp, L=john, S=doe, C=CH" \
             # Pre-configured filename is "WEB-INF/sls.jks"
             -keystore sls.jks \
             -storepass changeit \
             -keypass changeit \
             -keyalg RSA
            mv sls.jks /usr/share/usp/sls/webapps/sls/WEB-INF/
            # Now execute original Tomcat container startup command
            catalina.sh run
        volumeMounts:
          # Mount the override properties
          - mountPath: /var/lib/usp/sls/config
            name: sls-config-volume
      volumes:
        - configMap:
            defaultMode: 0775
            name: sls-config
          name: sls-config-volume
  selector:
    matchLabels:
      app.kubernetes.io/instance: slsoidcop
```

This mounts the contents of the ConfigMap "sls-config" (see [Kubernetes overrides](config_k8s_overrides.md) for details) into
the required path for the SLS to process them at startup time.