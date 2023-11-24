resource "auth0_connection" "google" {
  name     = "google"
  strategy = "google-oauth2"
}

resource "auth0_connection_clients" "frontend" {
  connection_id = auth0_connection.google.id
  enabled_clients = [
    auth0_client.frontend.id,
  ]
}

resource "auth0_client" "frontend" {
  name            = "bathrc-accounts-frontend"
  app_type        = "spa"
  callbacks       = ["${aws_api_gateway_stage.S3APIStage.invoke_url}/ui/callback"]
  oidc_conformant = true
  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_resource_server" "backend" {
  name             = "bathrc-accounts-backend"
  identifier       = "bathrc-accounts-backend-id"
  signing_alg      = "RS256"
  enforce_policies = true

  token_lifetime         = 86400
  token_lifetime_for_web = 7200

  skip_consent_for_verifiable_first_party_clients = true
}

resource "auth0_resource_server_scopes" "backend" {
  resource_server_identifier = auth0_resource_server.backend.identifier

  scopes {
    name        = "fullaccess:apis"
    description = "Full access to APIs"
  }
}

resource "auth0_role" "admin" {
  name = "admin"
}

resource "auth0_role_permissions" "admin" {
  name    = "admin"
  role_id = auth0_role.admin.id

  permissions {
    name                       = "fullaccess:apis"
    resource_server_identifier = auth0_resource_server.backend.identifier
  }
}
