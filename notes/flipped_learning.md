# Flipped Learning Resources

## Week 01

### AWS CLI v2

Please review the basic operations of the AWS CLI:

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

### Terraform

- Reading
  [Chapter 1. Why Terraform, Terraform: Up and Running 3rd](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch01.html)
- Video
  [Lesson 1: Terraform Fundamentals, Essential Terraform in AWS](https://learning.oreilly.com/course/essential-terraform-in/9780138312244/)

### Questions

- What is IaC? What problems does IaC address?
- What is idempotence?
- What is the difference between "configuration management", "orchestration",
  and "provisioning"?
- What does it mean to say that Terraform is "declarative"?
- What are "server templating tools"?
- What language are Terraform configuration files written in?
- Descripe the following Terraform commands.
  - `init`
  - `plan`
  - `apply`
  - `destroy`
- What is a Terraform "provider"?
- What is a Terraform "block"?
- What is Terraform "state"?

## Week 02

### Terraform Basics Video's

In preparation for the lab, please review the following videos:

1. [Terraform Help System](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_01_05/)
1. [How Does Terraform Work](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_01_05/)
1. [Terraform Documentation](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_01_06/)
1. [Terraform Workflow](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_01_07/)
1. [Formatting Terraform Code](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_03/)
1. [Initializing the Working Directory](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_04/)
1. [Validating Terraform Code](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_05/)
1. [Viewing the Terraform Plan](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_06/)
1. [Applying the Infrastructure](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_07/)
1. [Terraform State File](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_08/)
1. [Destroying the Infrastructure](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_08/)
1. [Terraform Variables: Deploying a Configurable Web Server](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch02.html#idm46165915172384)
1. [Terraform Variables: Overview](https://developer.hashicorp.com/terraform/language/values) -
   including `Input Variables` and `Output Values`, and `Local Values`

## Week 03

### Terraform State Overview

1. [Terraform State](https://developer.hashicorp.com/terraform/language/state)
1. [Terraform State Cheat Sheet](attachments/terraform-state-cheat-sheet.pdf)
1. [Terraform Inspecting State: List](https://developer.hashicorp.com/terraform/cli/commands/state/list)
1. [Terraform Inspecting State: Show](https://developer.hashicorp.com/terraform/cli/commands/state/show)
1. [Terraform State: Import](https://developer.hashicorp.com/terraform/language/import)
1. [Terraform Importing State: Generating Configuration](https://developer.hashicorp.com/terraform/language/import/generating-configuration)
1. [Importing Existing Infrastructure into Terraform](https://spacelift.io/blog/importing-exisiting-infrastructure-into-terraform)

## Week 04

### Introduction to Ansible

1. [Introduction to Ansible](https://learning.oreilly.com/videos/ansible-and-ansible-playbooks/9781835084182/9781835084182-video1_1/)
1. [How Ansible Works](https://learning.oreilly.com/videos/ansible-and-ansible-playbooks/9781835084182/9781835084182-video1_3/)
1. [Ch 1. Introduction, Ansible Up and Running 3rd](https://learning.oreilly.com/library/view/ansible-up-and/9781098109141/ch01.html)
1. [Ch 3. Playbooks: A beginning, Ansible Up and Running 3rd](https://learning.oreilly.com/library/view/ansible-up-and/9781098109141/ch03.html)


## Week 05

### Ansible: Inventory, Facts, and Variables
1. [Ch 4 Ansible Inventory Ansible: Up and Running](https://learning.oreilly.com/library/view/ansible-up-and/9781098109141/ch04.html)
1. Ansible working with Variables
  1. [Intro](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_00/)
  1. [Separating Code from Site Specific Configuration](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_01/)
  1. [Using Variables in a playbook](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_02/)
  1. [Understanding where to define your variables](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_02/)
  1. [Using Ansible Facts](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_02/)
  1. [Using `set_fact`](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_05/)
  1. [Understanding Different Notations for Facts and Variables](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_06/)
  1. [Using Multi-valued Variables](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_07/)
  1. [Using Magic Variables](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_08/)
  1. [Using Register](https://learning.oreilly.com/videos/ansible-core-concepts/9780135391662/9780135391662-ANS1_02_06_09/)
1. [Ch 5 Vanriables and Facts: Ansible: Up and Running](https://learning.oreilly.com/library/view/ansible-up-and/9781098109141/ch05.html)

## Week 06

### Redhat CentOS 9 Stream References
1. [CentOS 9 Stream AMI Images](https://www.centos.org/download/aws-images/)
1. [Redhat Setting up and configuring NGINX](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/deploying_web_servers_and_reverse_proxies/setting-up-and-configuring-nginx_deploying-web-servers-and-reverse-proxies)

### Ansible Variables and Variable Files
1. [Ansible Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#defining-variables-in-included-files-and-roles)
1. [Ansible `include_vars` Module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_vars_module.html)
1. [Load Variable files based on Ansible Facts](https://kirito174.medium.com/load-var-files-based-on-ansible-facts-bed963999332)
1. [Ansible Facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html): note `INJECT_FACTS_AS_VARS` setting is turned off for this lab.
1. [Ansible inject variables as facts](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#inject-facts-as-vars) - turn to `false` so always access via `ansible_facts` dictionary.

### Selecting Hosts for Ansible Plays
1. [Ansible Host Selection Patterns](https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html)
1. [Ansible Conditionals](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)

### Controlling the Running of Ansible Tasks and Plays
1. [Ansible Tags](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_tags.html)
1. [Ansible Loops](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)
1. [Ansible Handlers](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html)

### Grouping Ansible Tasks
1. [Ansible Blocks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_blocks.html)


## Week 07/08 

### Terraform Modules

1. [Terraform Modules](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch04.html)
1. [Terraform Creating Modules](https://developer.hashicorp.com/terraform/language/modules/develop)
1. [Terraform Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
1. [Terraform Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources)
1. [Terraform Module Tutorials](https://developer.hashicorp.com/terraform/tutorials/modules)
1. [Terraform Deploying Multi-tiered Web Application in AWS](https://learning.oreilly.com/videos/terraform-in-action/9781617296895VE/9781617296895VE-TFIAc4s1/)
    1. [Root Module](https://learning.oreilly.com/videos/terraform-in-action/9781617296895VE/9781617296895VE-TFIAc4s2/)
    1. [Database Module](https://learning.oreilly.com/videos/terraform-in-action/9781617296895VE/9781617296895VE-TFIAc4s3/)

### Terraform Compound Data and Loops

1. [Terraform Variables: Examples and Best Practices](https://spacelift.io/blog/how-to-use-terraform-variables)
1. [Terraform Map Variable – What It is & How to Use](https://spacelift.io/blog/terraform-map-variable)
1. [Terraform Tips and Tricks: Loops, If-Statements, Deployment, and Gotchas](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch05.html)
1. [Manage Similar Resources with `for each`](https://developer.hashicorp.com/terraform/tutorials/configuration-language/for-each)
1. [Mange Similar Resources with `count`](https://developer.hashicorp.com/terraform/tutorials/configuration-language/count)
1. [Terraform For Loop – Expression Overview with Examples](https://spacelift.io/blog/terraform-for-loop)
1. [Terraform Count vs. For Each Meta-Argument – When to Use It](https://spacelift.io/blog/terraform-count-for-each)
1. [Terraform Map Variable](https://spacelift.io/blog/terraform-map-variable)
1. [Terraform File Paths](https://spacelift.io/blog/terraform-path)

## Week 10

### Ansible Roles

1. [Ansible Up and Running: CH09 Roles](https://learning.oreilly.com/library/view/ansible-up-and/9781098109141/ch09.html)
1. [How to use Ansible Roles to abstract your infrastructure](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-roles-to-abstract-your-infrastructure-environment)
1. [Roles — Ansible Documentation](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)
1. [How to use Ansible Galaxy](https://www.redhat.com/sysadmin/ansible-galaxy-intro)
1. [Ansible Galaxy](https://galaxy.ansible.com/)
