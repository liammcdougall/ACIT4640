# Learning outcomes and topics

- Terraform modules
	- modules what and why
	- Breakup an existing terraform configuration to use several modules

# Terraform modules

Technically any Terraform configuration is a module. 

> _Modules_ are containers for multiple resources that are used together. A module consists of a collection of `.tf` and/or `.tf.json` files kept together in a directory.
> - [Terraform docs](https://developer.hashicorp.com/terraform/language/modules)

Modules help to organise, encapsulate and make configuration easier to reuse. 

An individual module can, and usually does contain multiple .tf files.

Modules can be stored in a number of places. Local files, Git repos, S3 buckets...
