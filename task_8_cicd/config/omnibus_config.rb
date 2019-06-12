# All specified ports must match ports configured in stack yaml.

# example to set external_url from env var
# host = `printenv GITLAB_HOST`
# external_url "http://#{host}"
# For HTTP
# external_url "http://${UCP_HOST}:9090"
# For HTTPS (notice the https)
# external_url "https://${UCP_HOST}:1443"
# SSH port
gitlab_rails['gitlab_shell_ssh_port'] = 2022
# Read Gitlab root password from container secret
gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password')
# set the runners token: SEgCf2Arv49hQUkmV6m9
gitlab_rails['initial_shared_runners_registration_token'] = "SEgCf2Arv49hQUkmV6m9"