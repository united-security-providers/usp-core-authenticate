### Secret Manifest

For the OpenID Connect authentication adapter, a client secret must be configured for each client (see section 
"overrides") with SLS configuration properties. The value there is a reference to a k8s secret, which must be
configured with a secret manifest. An example would be:

```
apiVersion: v1
kind: Secret
metadata:
  name: core-waap-hmac-secret-ref-slsoidcop
  namespace: acme-authenticate
type: Opaque
stringData:
  hmacSecret.yaml: |
    resources:
    - "@type": "type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.Secret"
      name: core-waap-hmac-secret-ref-slsoidcop
      genericSecret:
        secret:
          inlineString: "thisismysupersecret"
```

The string "thisismysupersecret" in this example is the OIDC clients' secret that must also be configured in the client.
