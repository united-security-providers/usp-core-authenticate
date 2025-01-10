# SAML 2.0 IdP Models

The following SAML IdP models are pre-configured in the "Core Authenticate" container:

## Authenticate

```properties
# SAML Login with SP-initiated login at SPs if no AuthnRequest received
model.login.uri=/samlauth
model.login.failedState=do.saml.idp.sendmsg

model.login.state.500.name=do.generic-skipped-if-post-binding

model.login.state.1000.name=do.generic-initial
model.login.state.1000.nextState.1=do.generic-redirect-to-or-select-sp
model.login.state.1000.nextState.1.if=${!idp.hasSamlMessage() || idp.getSamlMessageAgeSecs() > 3600}

# Workaround: On plain docker the waf-auth hsp runs on port 8443 instead of port 443 as on OpenShift (behind its router),
#             so adapt the port in the AuthnRequest before handling (the AuthnRequest is not signed)
model.login.state.1500.name=do.generic-fix-waf-auth-docker-sp-port
model.login.state.1500.action.1=#{authnRequest = idp.getSamlMessage()}

model.login.state.2000.name=do.saml.idp.handlemsg

model.login.state.4000.name=get.cred
# Simulate direct SAML error response for user 'failure'
model.login.state.4000.nextState.1=do.saml.idp.sendmsg-failure
model.login.state.4000.nextState.1.if.1=${session.getCred('username') eq 'failure'}

model.login.state.5000.name=do.auth
model.login.state.5000.nextState=do.generic-continueLogin
model.login.state.5000.failedState=get.cred

# Send SAML error response back
model.login.state.5200.name=do.saml.idp.sendmsg-failure
model.login.state.5200.param.statusCode=urn:oasis:names:tc:SAML:2.0:status:NoAuthnContext
model.login.state.5200.param.statusMessage=${'Authentication Failed'}
model.login.state.5200.nextState=do.generic-initial

model.login.state.7000.name=do.generic-continueLogin
model.login.state.9000.name=do.saml.idp.sendmsg
#
# no saml message or saml message too old: redirect to SP or show SP selection JSP
model.login.state.10000.name=do.generic-redirect-to-or-select-sp
model.login.state.10000.action.1=${function.setVariable('redirectUrl', idp.getSamlMessageIssuerSpUrl())}
model.login.state.10000.nextState.1=show.jsp-select-sp
model.login.state.10000.nextState.1.if=${!function.hasNonEmptyVariable('redirectUrl')}
#
# redirect to SP
model.login.state.11000.name=do.redirect
model.login.state.11000.param.url=${redirectUrl}
model.login.state.11000.param.url.absolute.allow=true
#
# show SP selection JSP
model.login.state.12000.name=show.jsp-select-sp
model.login.state.12000.param.jsp=jsp.idp.spselection
```

## Metadata

```properties
# Get IdP Metadata
model.metadata.uri=/metadata
model.metadata.failedState=show.jsp

model.metadata.state.10.name=show.jsp
model.metadata.state.10.param.jsp=jsp.idp.metadata
```

For details on SAML configuration, please see [SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x10007_Heading1Tarsec_SAML_IdP_Adapter)
