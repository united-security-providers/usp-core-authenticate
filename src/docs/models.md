# Models (Flows)

Whenever the SLS starts a session, that session will be bound to a so-called model; which is number of pre-defined
states that will be processed based on the users actions or backend responses. So a model is a flow of actions,
requests and responses. It is configured in a set of properties.

* To configure custom models in the Core Authenticate container, the properties must be set as overrides
  (see [Kubernetes overrides](config_k8s_overrides.md) for details).
* For details on model configuration properties, please see [SLS Administration Guide](files/%SLS_VERSION%/html-admin-guide/sls-adminguide.html#x29792_Heading1Tarsec_Model)

The "Core Authenticate" container is pre-configured with several models that support the OIDC OP and SAML IdP use-cases.
See [OIDC Models](oidc-models.md) and [SAML IdP Models](saml-idp-models.md) for details.