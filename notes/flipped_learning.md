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
1. [Appplying the Infrastrucure](https://learning.oreilly.com/videos/essential-terraform-in/9780138312244/9780138312244-ETA1_01_02_07/)
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