# Authentication Settings

During an OIDC or a SAML flow, the SLS at some point has to authenticate the user. There are a number of mechanisms
available in the SLS to support this:

- LDAP: Identify the user with an LDAP directory service.
- RADIUS: Use a RADIUS server to authenticate the user. 
- SPNEGO: Authenticate the user through HTTP-based Kerberos.
- HTTP: Perform a custom HTTP call to a backend (REST or otherwise) to verify the user credentials. 
- PKI: Use X509 certificates to identify the user.
- File: For testing or demo purposes only: Use a local XML file in the SLS with pre-defined users and passwords.

By default, no authentication is configured in the "Core Authenticate" container, so one MUST be defined first before
any login attempt is possible.

## Select authentication type

In order to perform the authentication step in the login model ("do.auth", "do.auth2", "do.auth3" etc.) the desired
backend adapter must be configured using a simple alias (usually the backend type as a lower-case string):

- LDAP: ```ldap```
- RADIUS: ```radius```
- SPNEGO: ```spnego```
- HTTP: ```http```
- PKI: ```pki```
- File: ```file```

For details on how to configure each authentication backend please consult the 
[SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#_adapters_authentication_systems)



