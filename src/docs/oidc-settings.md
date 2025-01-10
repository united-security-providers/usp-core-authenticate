# OIDC OP Settings

The following OIDC OP configuration properties are pre-configured in the "Core Authenticate" container:

```properties
# The OIDC OP issuer (used e.g. as "iss" claim in id_token/access_token).
oidc.op.issuer=https://#{var('header.host')}/oidc-op/sls

# OP keystore.
oidc.op.keystore.file=WEB-INF/sls.jks
oidc.op.keystore.type=JKS
oidc.op.keystore.pass=changeit

# Alias of OIDC OP key pair in keystore.
oidc.op.keystore.keypair.alias=sls

# Validity period of the authorization code in seconds.
# Default is 60 sec (1 min), maximally allowed value is 3600 sec (1 hour).
oidc.op.authorization_code.validity.secs=60

# Validity period of the id_token/access_token in seconds.
# Default: 300 seconds (5 minutes)
oidc.op.id_token.validity.secs=120

# What to use as userid in the id_token/access_token.
oidc.op.id_token.userid=${session.getVerifiedCred('username')}

# Validity period of the refresh_token in hours
# Default: 24 hours (one day)
oidc.op.refresh_token.validity.hours=1

# Whether to renew the refresh_token validity at refresh request processing or not.
# Default: false
oidc.op.refresh_token.validity.renew=true
```

For details on OIDC configuration, please see [SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x10007_Heading1Tarsec_OIDC_OP_Adapter)

## Registering a Relying Party

In order to actually use the OIDC OP, registering a Relying Party will be the minimal required action. This can
be done through the properties overrides (see [Kubernetes overrides](config_k8s_overrides.md) for details) by setting a few custom configuration
properties. Example:

```properties
oidc.op.issuer=OtherCompany
oidc.op.rp.10.client_id=partner_company_id
oidc.op.rp.10.client_secret=some_secret_goes_here
oidc.op.rp.10.redirect_uris=https://other.company.com/oidc/rp
```

For details on OIDC Relying Party configuration, please see [SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x10007_Heading1Tarsec_OIDC_OP_Adapter)
