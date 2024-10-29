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

## module exercise

Unzip the zip file in the exercise starter files below and use it to answer the following questions.

1. How is data passed into a module?
2. How is data passed out of a module?
3. Modify the `mod_demo` module to create a security group module for use in the mod_demo project?

[Starter code for modules lab](https://gitlab.com/cit_4640/4640_notes_w24/-/blob/main/starter_code/week06/mod_demo.zip)

**Reference:**

[What Are Terraform Modules and How to Use Them](https://spacelift.io/blog/what-are-terraform-modules-and-how-do-they-work)

[Terraform Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources)

# Flipped learning material

- [Write Terraform Tests](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- Watch Lesson 5: Working with variables from [Ansible: From Basic to Guru](https://learning.oreilly.com/course/ansible-from-basics/9780137894949/)
- Watch Lesson 6: Using Conditionals from [Ansible: From Basic to Guru](https://learning.oreilly.com/course/ansible-from-basics/9780137894949/)