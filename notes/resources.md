# References

## Textbooks

Most of the class readings will come from the following books.

1. [AWS Certified Cloud Practitioner Exam Guide](https://learning.oreilly.com/library/view/aws-certified-cloud/9781801075930/)
1. [Learning Linux Shell Scripting - Second Edition](https://learning.oreilly.com/library/view/learning-linux-shell/9781788993197/)
1. [Terraform: Up and Running, 3rd Edition](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/)
1. [Ansible: Up and Running, 3rd Edition](https://learning.oreilly.com/library/view/ansible-up-and/9781098109141/)

## Amazon Web Services

1. [AWS Docs Landing Page](https://docs.aws.amazon.com/index.html)

## General Linux

1. [Ubuntu Server Docs](https://ubuntu.com/server/docs). This is the
   distribution used throughout the course.

1. [ArchWiki](https://wiki.archlinux.org/) although specific to Arch Linux, much
   of the information is general enough to be useful to other Linux
   distributions. The Wiki is generally pretty up-to-date and often includes
   helpful examples.

1. [Red Hat Enterprise Linux 9 Docs](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9)
   Similar to the ArchWiki above, while these documents are specific to Red Hat,
   much of it is general enough to be be valuable to anyone interested in
   learning more about a Linux OS.

## Bash

1. [Bash Reference Manual](https://www.gnu.org/software/bash/manual/html_node/index.html)
1. [Bash Hackers Wiki](https://flokoe.github.io/bash-hackers-wiki/)
1. [Google Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
1. [The Linux Command Line](https://learning.oreilly.com/library/view/the-linux-command/9781492071235/)
1. [Bash Cookbook](https://learning.oreilly.com/library/view/bash-cookbook-2nd/9781491975329/)
1. [Mastering Bash Shell Scripting: Video Course](https://learning.oreilly.com/videos/mastering-bash-shell/9781801070607/)
1. [Bash Scripting Cheat-sheet](https://devhints.io/bash)
1. [Bash Idioms (Stylish Bash)](https://learning.oreilly.com/library/view/bash-idioms/9781492094746/)

## Terraform

1. [Terraform Cheat Sheet](/attachments/terraform_cheatsheet.pdf)
1. [Terraform Essential Components](/attachments/terraform_essential_components.pdf)
1. [Terraform Documentation Root](https://www.terraform.io/docs/index.html)
1. [Terraform Tutorials: AWS](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)

## Ansible

### Documentation
1. [Ansible Documentation Root](https://docs.ansible.com/ansible/latest/)
1. [How to Navigate Ansible Documentation](https://www.redhat.com/sysadmin/navigate-ansible-documentation)

### Playbook Examples
1. [Simple Playbook Examples](https://www.middlewareinventory.com/blog/ansible-playbook-example/)
1. [Full Playbook Examples](https://github.com/ansible/ansible-examples) - These
   are role based that we will cover later in the course.

### Modules 
1. [Ansible modules](https://docs.ansible.com/ansible/latest/collections/index_module.html).

### Configuration Management Modules References

- Wait till remote is ready: [`wait_for_connection`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/wait_for_connection_module.html)
- Install packages (General): [`package`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html)
- Install packages (Ubuntu): [`apt`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
- Manage users: [`user`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)
- Manage file and properties/permissions: [`file`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)
- Copy to remote: [`copy`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
- Template out to remote: [`template`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
- Download a file: [`get_url`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html)
- Unzip a file: [`unarchive`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html)
  - Use `remote_src: yes` only if the compressed file is already on the remote target!
  - Make sure the binaries to uncompress your file are installed (for example `unzip`)
- Manage systemd units: [`systemd`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html)
- Manage Python dependencies: [`pip`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html)
- Manage MySQL users: [`mysql_user`](https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_user_module.html)
- Manage MySQL databases: [`mysql_db`](https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_db_module.html)
- Get file/filesystem status: [`stat`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html)
- Print variables / messages: [`debug`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html)
- Run a shell command (**AS A LAST RESORT!**): [`shell`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)

> Make sure you look at the requirements for each module! The MySQL modules will require Python libraries for mysql. You can install them first with `apt`.

### Ansible Logic References

- [`register`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#registering-variables): saves the output of a module in a variable
- [`when`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html): conditionally runs a task
- [Loops](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html): repeat tasks with different parameters
- [`become` and `become_user`](https://docs.ansible.com/ansible/latest/user_guide/become.html): run tasks as a different user

## Additional Resources

If you come across a resource that you feel would be valuable to the class
please pass it along to Tom or Nathan and we will add it to this section.
