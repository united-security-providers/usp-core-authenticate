# Service Manifest

The SLS is listening on port 8080 and exposes that port. So a typical example k8s service manifest would be:

```
kind: Service
apiVersion: v1
metadata:
  name: slsoidcop
  namespace: {{.Values.namespace}}
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/instance: slsoidcop
  ports:
  - name: http
    port: 8080
    targetPort: 8080
```

