{
  "supermarket_omnibus": {
    "chef_server_url": "${chef_fqdn}",
    "chef_oauth2_app_id": "${oauth_id}",
    "chef_oauth2_secret": "${oauth_sec}",
    "chef_oauth2_verify_ssl": true,
    "config": {
      "ssl": {
        "certificate": "${cert}",
        "certificate_key": "${cert_key}"
      }
    }
  },
  "fqdn": "${host}.${domain}",
  "firewall": {
    "allow_established": true,
    "allow_ssh": true
  },
  "system": {
    "short_hostname": "${host}",
    "domain_name": "${domain}",
    "manage_hostsfile": true
  },
  "tags": []
}

