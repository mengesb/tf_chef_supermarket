tf_chef_supermarket CHANGELOG
=============================

This file is used to list changes made in each version of the tf_chef_supermarket Terraform plan.

v0.1.1 (2016-05-10)
-------------------
- [Brian Menges] - Add `chef_identity_url` to [attributes-json.tpl](files/attributes-json.tpl)

v0.1.0 (2016-04-25)
-------------------
- [Brian Menges] - Update runlist
- [Brian Menges] - Update comments

v0.0.10 (2016-04-22)
-------------------
- [Brian Menges] - Missing provider

v0.0.9 (2016-04-21)
-------------------
- [Brian Menges] - Updated usage of `wait_on`

v0.0.8 (2016-04-20)
-------------------
- [Brian Menges] - redirect_uri wrong; fixed

v0.0.7 (2016-04-20)
-------------------
- [Brian Menges] - sed string not terminated

v0.0.6 (2016-04-20)
-------------------
- [Brian Menges] - Update sed modification of configuration json

v0.0.5 (2016-04-20)
-------------------
- [Brian Menges] - fix chef_api_request script call

v0.0.4 (2016-04-20)
-------------------
- [Brian Menges] - Specify provider so that defaults can be overwritten

v0.0.3 (2016-04-20)
-------------------
- [Brian Menges] - Added `security_group_id` to `outputs.tf`
- [Brian Menges] - Added variables `wait_on`, `log_to_file`, `public_ip`, `root_delete_termination`, `client_version`
- [Brian Menges] - Updated `main.tf` to use new variables
- [Brian Menges] - Implemented `wait_on` dependency chain usage
- [Brian Menges] - Updated HEREDOC style usage in plan
- [Brian Menges] - Updated `attributes-json.tpl` and added chef_client

v0.0.2 (2016-03-28)
-------------------
- [Brian Menges] - SED script update to handle adding or instantiating an oc_id['application'] in configuration
- [Brian Menges] - Documentation updates

v0.0.1 (2016-03-24)
-------------------
- [Brian Menges] - initial commit

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
