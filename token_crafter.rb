require 'octokit'
require 'jwt'

# Instantiate an Octokit client authenticated as a GitHub App.
# GitHub App authentication requires that you construct a
# JWT (https://jwt.io/introduction/) signed with the app's private key,
# so GitHub can be sure that it came from the app an not altered by
# a malicious third party.
def authenticate_app
  payload = {
    iat: Time.now.to_i,
    exp: Time.now.to_i + (10 * 60),
    iss: 287720
  }

  github_private_key = ENV["APP_PRIVATE_KEY"]
  private_key = OpenSSL::PKey::RSA.new(github_private_key.gsub('\n', "\n"))
  jwt = JWT.encode(payload, private_key, 'RS256')

  app_client = Octokit::Client.new(bearer_token: jwt)

  installations = app_client.find_integration_installations
  installation_id = installations.first[:id]

  app_client.create_app_installation_access_token(installation_id)[:token]
end

puts authenticate_app
