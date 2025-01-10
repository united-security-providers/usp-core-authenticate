# OIDC OP Models

The following OIDC models are pre-configured in the "Core Authenticate" container:

## Login / Authorization Code Flow

```properties
# OIDC 'Authorization Code Flow' login part 1, user authentication => authorization code

model.authenticate.uri=/auth
model.authenticate.failedState=get.cred
#
# generic "no operation" first state because skipped if first request is a POST
model.authenticate.state.1000.name=do.generic-nop-skipped-if-post
#
# handle oidc message (validate it)
model.authenticate.state.2000.name=do.oidc.op.handlemsg
model.authenticate.state.2000.failedState=do.oidc.op.sendmsg
#
# authenticate user (currently with ldap adapter)
model.authenticate.state.3000.name=do.generic-clearCreds
model.authenticate.state.3000.action.1=#{session.clearCredentials()}
model.authenticate.state.4000.name=get.cred
model.authenticate.state.5000.name=do.auth
#
# create oidc response (optional, would happen automatically at sendmsg)
model.authenticate.state.6000.name=do.oidc.op.createmsg
#
# add custom attributes to authorization code
model.authenticate.state.6500.name=do.generic-add-custom-attributes
model.authenticate.state.6500.action.1=${oidc_op_authorization_code.setAttribute('acme_claim', 'road-runner')}
#
# send oidc response
model.authenticate.state.7000.name=do.oidc.op.sendmsg
model.authenticate.state.7000.failedState=get.usererror
model.authenticate.state.8000.name=get.usererror
```

## Token Endpoint

```properties
# OIDC 'Authorization Code Flow' login part 2, authorization code => id_token/access_token and refresh_token
# and 'Refresh Request', refresh_token => new id_token/access_token and refresh_token

model.token.uri=/oidc-token
model.token.failedState=get.usererror
#
# Detect if incoming request is token request (and not refresh)
model.token.state.1500.name=do.generic-detect-if-token
model.token.state.1500.action.1=#{isTokenRequest = (oidc_op.getOidcRequestWrapper().getType() == 'token')}
#
# generic "no operation" first state because skipped if first request is a POST
model.token.state.1000.name=do.generic-nop-skipped-if-post
#
# handle oidc message (validate it)
model.token.state.2000.name=do.oidc.op.handlemsg
model.token.state.2000.failedState=do.oidc.op.sendmsg
#
# create oidc response (optional, would happen automatically at sendmsg)
model.token.state.3000.name=do.oidc.op.createmsg
model.token.state.3000.failedState=do.oidc.op.sendmsg
#
# add custom claims to id_token/access_token, but only if token request
# (are already in id_token/access_token if refresh request)
model.token.state.4000.name=do.generic-add-custom-claims
model.token.state.4000.action.1=${oidc_op_id_token.setClaim('acme_claim', oidc_op_authorization_code.getAttribute('acme_claim'))}
model.token.state.4000.action.1.if=${isTokenRequest}
#
# send oidc response
model.token.state.7000.name=do.oidc.op.sendmsg
model.token.state.7000.failedState=get.usererror
model.token.state.8000.name=get.usererror\
```

## Userinfo Endpoint

```properties
# OIDC 'Userinfo Request', access_token => userinfo claims

model.userinfo.uri=/oidc-userinfo
model.userinfo.failedState=get.usererror
#
# generic "no operation" first state because skipped if first request is a POST
model.userinfo.state.1000.name=do.generic-nop-skipped-if-post
#
# handle oidc message (validate it)
model.userinfo.state.2000.name=do.oidc.op.handlemsg
model.userinfo.state.2000.failedState=do.oidc.op.sendmsg
#
# create oidc response (optional, would happen automatically at sendmsg)
model.userinfo.state.3000.name=do.oidc.op.createmsg
model.userinfo.state.3000.failedState=do.oidc.op.sendmsg
#
# add custom claims to userinfo
model.userinfo.state.4000.name=do.generic-add-custom-claims
model.userinfo.state.4000.action.1=${userid = session.getVerifiedCred('username')}
model.userinfo.state.4000.action.2=${oidc_op_userinfo.setClaim('preferred_username', userid)}
model.userinfo.state.4000.action.3=${oidc_op_userinfo.setClaim('email', userid + '@acme.not')}
#
# send oidc response
model.userinfo.state.7000.name=do.oidc.op.sendmsg
model.userinfo.state.7000.failedState=get.usererror
model.userinfo.state.8000.name=get.usererror
```

## Configuration

```properties
# OIDC well-known configuration

model.oidc-config.uri=/.well-known/openid-configuration
model.oidc-config.failedState=get.usererror

# mandatory, show the JSP
model.oidc-config.state.30.name=show.jsp-config
model.oidc-config.state.30.property=jsp.op.config

# handle errors
model.oidc-config.state.40.name=get.usererror
```

## JWKS Endpoint

```properties
# OIDC JWKS

model.oidc-jwks.uri.1=/jwks
model.oidc-jwks.uri.2=/oidc-jwks
model.oidc-jwks.uri.3=/.well-known/openid-configuration/jwks
model.oidc-jwks.failedState=show.jsp

model.oidc-jwks.state.1000.name=show.jsp
model.oidc-jwks.state.1000.param.jsp=jsp.op.jwks
```

For details on OIDC configuration, please see [SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x10007_Heading1Tarsec_OIDC_OP_Adapter)
