# SAML 2.0 IdP Settings

The following SAML IdP configuration properties are pre-configured in the "Core Authenticate" container:

```properties
#############saml.securityConfiguration.signatureReferenceDigestMethod=http://www.w3.org/2001/04/xmlenc#sha512

# IdP EntityID,
idp.entity.id=https://${header.host}/idp/sls
#idp.entity.id=https://sestest2.seslab.local/idp/sls

# IdP Keystore.
idp.keystore.file=WEB-INF/sls.jks
idp.keystore.type=JKS
idp.keystore.pass=changeit
# or store keystore password in a file and reference the file as follows:
#idp.keystore.pass=${function.getValueFromFile('/path/to/file')}
# Alias of IdP key pair in keystore.
idp.keystore.keypair.alias=idp

# SSO/SLO: URL for each binding.
# Currently only redirect binding is supported
idp.sso.redirect.url=https://${header.host}/ite/idp/sls/auth
idp.slo.redirect.url=https://${header.host}/ite/idp/sls/slo

#idp.redirectWithMetaRefresh=slo

# Optional: Offset in seconds to subtract from the issue instant in
# assertions and saml responses. Use as workaround for problems with
# clock sync on IdP and SP. Note however, that some SPs will conversely
# not accept Assertions that have nominally been issued before the
# Request was created/sent.
# Default: 0.
#idp.issueinstant.offset.secs=60

# Validity period of assertion and conditions in assertion
# (issue instant offset is added to that).
# Default: 600 sec (10 min).
idp.assertion.validity.secs=600

# Authentication method in the assertion.
idp.assertion.authentication.method=urn:oasis:names:tc:SAML:2.0:ac:classes:Password

# Supported NameIDs.
# If there is no NameIDPolicy in the request, the first one indicated is used.
# Otherwise, the first match of format+allowcreate with the NameIDPolicy is used.
idp.assertion.nameid.1.format=urn:oasis:names:tc:SAML:2.0:nameid-format:transient
idp.assertion.nameid.1.allowcreate=true
# idp.assertion.nameid.1.value=${idp.createRandomId()}
idp.assertion.nameid.1.value=saml-user_${session.getCred('username')}
# Note that beyond simple use cases, it may be more convenient to use
# JEXL functions idp.setAssertionAttribute[...]() to set attributes.
# The name format to use, 'basic' and 'uri' are supported.
# (This setting has the same effect as the deprecated idp.assertion.attr.<no>.type).
idp.assertion.attr.1.nameformat=basic
# (Long) name of the attribute.
idp.assertion.attr.1.name=urn:oid:0.9.2342.19200300.100.1.1
# Friendly name of the attribute.
idp.assertion.attr.1.friendlyname=uid
# Use this setting for a single string value, typically a JEXL expression.
idp.assertion.attr.1.value=${session.getCred('USERNAME')}
# Alternatively provide the name of a JEXL variable that may contain
# either a single string value or a string array.
# Note that the variable name must be indicated as a constant,
# e.g. "var", not as a JEXL expression, e.g. "${var}.
# idp.assertion.attr.1.value.variable=attribute.ldap.ismemberof
# Optional setting that defines the value type to use:
# - string (default)
# - base64: given value(s) are first UTF-8 encoded and then base64 encoded
# - base64.provided: given value(s) are taken as is, indicated that is base64 in attribute
#idp.assertion.attr.1.value.type=string
# Optional setting that enforces a profile:
# - basic: Basic profile, see saml-profiles-2.0-os, section 8.1.
# - x500ldap: X500/LDAP profile, saml-profiles-2.0-os, section 8.2.
#idp.assertion.attr.1.profile=x500ldap

idp.assertion.attr.2.nameformat=uri
idp.assertion.attr.2.name=urn:oid:1.3.6.1.4.1.1466.115.121.1.12
idp.assertion.attr.2.friendlyname=dn
idp.assertion.attr.2.value.variable=queryResultArrayFromSsoAttr
idp.assertion.attr.2.value.type=base64
idp.assertion.attr.2.profile=x500ldap

# SSO Attributes, stored after successful login at IdP.
# Use JEXL ${idp.getSsoAttribute(<key>)} to retrieve.
idp.sso.attr.1.key=multi
# Either set a single string variable explicitly...
#idp.sso.attr.1.value=${session.getCred('USERNAME')}
# ... or indicate the name of a variable that can contain
# a single string value or an array of strings.
# Note that the variable name must be indicated as a constant,
# e.g. "var", not as a JEXL expression, e.g. "${var}.
idp.sso.attr.1.value.variable=queryResultArrayForSsoAttr
```

For details on SAML configuration, please see [SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x10007_Heading1Tarsec_SAML_IdP_Adapter)

## Registering a Service Provider

In order to actually use the SAML IdP, registering a Service Provider will be the minimal required action. This can
be done through the properties overrides (see [overrides](overrides/) for details) by setting a few custom configuration
properties. Example:

```properties
idp.sp.1.alias=acme-ltd-sp
idp.sp.1.metadata.provider=file
idp.sp.1.metadata.location=WEB-INF/idp/acmesp-metadata.xml
idp.sp.1.message.sign=sso.post,slo.redirect
idp.sp.1.message.checksign=true
idp.sp.1.sso=false
idp.sp.1.url=https://www.acme-ltd.com/sp
idp.sp.1.keystore.keypair.alias=myidp
```
This registers an SP with an alias "acme-ltd-sp" (can be using in various scripting functions etc.). However, this will
also require to upload the SP SAML metadata file "acmesp-metadata.xml" to the SLS subdirectory "WEB-INF/idp/":

- ```/usr/share/usp/sls/webapps/sls/WEB-INF/idp/acmesp-metadata.xml```

In certain deployment scenarios ("docker-compose" for example) you may be able to just mount this file directly into that
path in the SLS. In others, like Kubernetes, you may need to use an approach where you mount this file into a temporary 
folder and then copy it to the target directory at startup time, by adapting the container startup command. See 
["Adding custom files"](/config_k8s_files/) for details.