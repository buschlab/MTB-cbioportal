access_by_lua '
  local cbioportalUrl = os.getenv("CBIOPORTAL_URL")
  local keycloakUrl = os.getenv("KEYCLOAK_URL")
  local keycloakRealm = os.getenv("KEYCLOAK_REALM")
  local keycloakClient = os.getenv("KEYCLOAK_CLIENT")
  local keycloak_client_secret = os.getenv("KEYCLOAK_SECRET")

  local opts = {
    redirect_uri_path = "/mtb/redirect",
    accept_none_alg = false,
    discovery = keycloakUrl .. "/realms/" .. keycloakRealm .. "/.well-known/openid-configuration/",
    client_id = keycloakClient,
    client_secret = keycloak_client_secret,
    -- ssl_verify = "yes",
    prompt = "login",
    redirect_uri_scheme = "http",
    -- redirect_uri_scheme = "https",
    logout_path = "/mtb/logout",
    redirect_after_logout_uri = keycloakUrl .. "/realms/" .. keycloakRealm .. "/protocol/openid-connect/logout?client_id=" .. keycloakClient .. "&redirect_uri=" .. cbioportalUrl .. "%2Fmtb%2Flogin",
    redirect_after_logout_with_id_token_hint = false,
    session_contents = {id_token=true, access_token=true}
  }

  -- call introspect for OAuth 2.0 Bearer Access Token validation
  local res, err = require("resty.openidc").authenticate(opts)
  if err then
    ngx.status = 403
    ngx.say(err)
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end

  local user_roles = "no_roles"
  local user_name = "Unknown"
  local user_login_name = "unknown"

  local function extractJwt()
    local jwt = require "resty.jwt"
    local jwt_obj = jwt:load_jwt(res.access_token)
    local cjson = require "cjson"
    local string_token = cjson.encode(jwt_obj)
    local json_token = cjson.decode(string_token)
    local extracted_roles = cjson.encode(json_token.payload.resource_access[keycloakClient].roles)
    if (extracted_roles == nil) then 
        user_roles = "ERROR extracting token" 
    elseif (extracted_roles == "") then 
        user_roles = "no_roles" 
    else 
        user_roles = extracted_roles 
    end
  end

  local function getUser()
    local cjson = require "cjson"
    user_name = cjson.encode(res.id_token.name)
    user_login_name = cjson.encode(res.id_token.preferred_username)
  end

  pcall(extractJwt)
  pcall(getUser)
  ngx.log(ngx.STDERR, user_roles)

  ngx.ctx.user_roles = user_roles
  ngx.ctx.user_name = user_name

  ngx.req.set_header("X-USERROLES", user_roles)
  ngx.req.set_header("X-USERLOGIN", user_login_name)
';
