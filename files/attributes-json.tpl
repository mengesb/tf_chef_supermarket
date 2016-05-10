{
  "chef_client": {
    "init_style": "none"
  },
  "fqdn": "${host}.${domain}",
  "firewall": {
    "allow_established": true,
    "allow_ssh": true
  },
  "supermarket_omnibus": {
    "chef_identity_url": "${chef_fqdn}/id",
    "chef_oauth2_app_id": "${oauth_id}",
    "chef_oauth2_secret": "${oauth_sec}",
    "chef_oauth2_verify_ssl": true,
    "chef_server_url": "${chef_fqdn}",
    "config": {
      "ssl": {
        "certificate": "${cert}",
        "certificate_key": "${cert_key}"
      }
    }
  },
  "system": {
    "delay_network_restart": false,
    "domain_name": "${domain}",
    "manage_hostsfile": true,
    "short_hostname": "${host}"
  },
  "tags": []
}
