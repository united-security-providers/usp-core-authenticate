# "Overrides" ConfigMap Manifest

The SLS is configured through properties for the most part. The container comes with a sensible set of default
configurations so that it will run out of the box, although it will not perform any actual authentication; for that,
a minimal set of configuration properties will be required.

This is achieved through a k8s ConfigMap manifest which defines a set of key-/value pairs that will be provided in
the SLS instance; if any properties are defined there that are already pre-configured in the SLS, the pre-configured
values will be overridden (hence the "overrides" term used here).

An example configuration ConfigMap which configures the SLS to use the internal file adapter for (demo) authentication
would look like this:

```
kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    app.kubernetes.io/instance: slsoidcop
    app.kubernetes.io/name: slsoidcop
  name: sls-config
  namespace: acme-authenticate
data:
  custom.overrides: |
    adapter.authentication=file
    oidc.op.issuer=USP-Core-Authenticate
    oidc.op.rp.10.client_id=Some_Client
    oidc.op.rp.10.client_secret=myClientSecret
    oidc.op.rp.10.redirect_uris=https://login.acme.com:8443/core-authenticate/callback
```

This will create a file "custom.overrides" which then has to be mounted into the right location in the container to
be processed by the SLS at startup time.

