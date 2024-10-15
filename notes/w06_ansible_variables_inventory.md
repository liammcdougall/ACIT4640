## Ansible Configuration Files

### Priority Ranked List of Configuration Files
- `ANSIBLE_CONFIG` -- Environment variable that points to an Ansible configuration file.
- `ansible.cfg` -- In the current directory.
- `~/.ansible.cfg` -- In the home directory.
- `/etc/ansible/ansible.cfg` -- System-wide configuration file.

### Verify Loaded Configuration
```bash
ansible --version
```

```
ansible [core 2.15.8]
  config file = /home/tlane/acit_4640_202430/examples/wk05/ansible.cfg
  configured module search path = ['/home/tlane/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/tlane/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.12 (main, Sep 11 2024, 15:47:36) [GCC 11.4.0] (/usr/bin/python3)
  jinja version = 3.0.3
  libyaml = True
```

### Key Configuration Options

- `inventory` -- Path to the inventory file.
- `remote_user` -- User to connect to remote hosts.
- `private_key_file` -- Path to the private key file.
- `ansible_managed` -- Text to include in managed files.
- `log_path` -- Path to the log file.
- `roles_path` -- Path to the roles directory.
- `host_key_checking` -- Check host keys.
- `timeout` -- Timeout for connections.
- `module_stdout` -- Capture module output.
- `module_stderr` -- Capture module errors.

## Variables

### What are Variables?

### Defining Variables

```yaml
---
# Define a variable
my_var: "Hello, World!"
```

### Variable Types

### Variable Scope
In Ansible variables have a scope. The scope of a variable is determined by where
it is defined. Variables can be defined in the following locations:


### Where to Define Variables and Precedence

1. `inventory` -- Variables defined in the inventory file.
1. `playbook` -- Variables defined in the playbook.
    1. `vars` -- Variables defined in the playbook.
    1. `vars_files` -- Variables defined in a separate file listed in playbook.
1. `group_vars` -- separate directory for group variable files - each file is named after the group.
1. `host_vars` -- separate directory for host specific variable files - each file is named after the host.
1. `roles` -- Variables defined in a role.
1. `extra_vars` -- Variables defined on the command line.

### Referencing Variables

```yaml

# Reference a variable
dest: "{{ remote_install_path }}/foo.cfg"
``` 

### Registering Variables


### Built-in Variables
- `ansible_facts` -- Facts about the host.
- `inventory_hostname` -- Hostname of the current host.
- `inventory_hostname_short` -- Short hostname of the current host.
- `group_names` -- List of groups the current host is a member of.
- `groups` -- Dictionary of groups and their members.
- `hostvars` -- Dictionary of all variables for all hosts.
- `ansible_play_hosts` -- List of hosts in the current play.
- `ansible_play_batch` -- List of hosts in the current batch.
- `ansible_check_mode` -- Check mode status.

## Facts

When ansible connects to a host it gathers facts about the host. These facts are
stored in the `ansible_facts` dictionary. You can access these facts in your
playbook using the `ansible_facts` dictionary.

```yaml
---
- hosts: all
  remote_user: root

  tasks:
    - name: Print out all the facts
      ansible.builtin.debug:
        var: ansible_facts
```