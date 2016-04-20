tf_chef_supermarket CHANGELOG
=============================

This file is used to list changes made in each version of the tf_chef_supermarket Terraform plan.

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
