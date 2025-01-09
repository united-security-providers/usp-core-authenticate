# Challenge/Response Settings

Whenever an authentication procedure must be enhanced with a 2nd factor, some kind of challenge-/response step needs
to be used. The following options are supported in the SLS:

- "simple" - The SLS generates a secure random code that can be sent to the user by SMS and has to be entered manually.
- "googleauth" - The user has to provide a time-based response code from an authenticator app that was registered previously.
- "webauthn" - The user is identified through their client, possibly with biometric mechanisms (e.g. fingerprint scanner
  on a smartphone), either as a 2nd factor or in a password-less flow.

A few hints about each one:

- With the "simple" challenge adapter, the model state "create.challenge" must be used. This will execute the creation
  of the secure random value that is then available as a scripting variable to be sent to the user, usually by way of
  an HTTP call to a REST backend.
- With the "googleauth" challenge adapter, no "create.challenge" step is necessary, since the SLS does not create the
  challenge; it's created automatically based on the current time.
- With "webauthn" things get a bit more complicated as the configuration details depend heavily on how WebAuthn should
  be used (2FA vs password-less).

For details on how to configure each challenge/response adapter please consult the 
[SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#_adapters_authentication_systems)



