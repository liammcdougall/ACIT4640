# Intro to Ansible roles

> In Ansible, the _role_ is the primary mechanism for breaking a playbook into multiple files. This simplifies writing complex playbooks, and it makes them easier to reuse.
> - Ansible in Action 3rd

## Where should roles go in your project

Ansible roles have a defined directory structure. Ansible will look for roles in the following locations:

- in collections, if you are using them
- in a directory called `roles/`, relative to the playbook file (This is the solution that we are going to use)
- in the configured [roles_path](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-roles-path). The default search path is `~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles`.
- in the directory where the playbook file is located

## Organising the roles directory

Inside of the roles directory individual directories are created for each role, for example a database role

```
ansible.cfg
roles/
	database/
```

Inside of each role, ie the database role directory ansible uses any of eight standard directories. If you don't need to include a directory you don't have to.

- Tasks
	The _tasks_ directory has a _main.yml_ file that serves as an entry point for the actions a role does.

- Files
	Holds files and scripts to be uploaded to hosts.

- Templates
	Holds Jinja2 template files to be uploaded to hosts.

- Handlers
	The _handlers_ directory has a _main.yml_ file that has the actions that respond to change notifications.

- Vars
	Variables that shouldn’t generally be overridden.

- Defaults
	Default variables that can be overridden.

- Meta
	Information about the role.

- Library
	modules, which may be used within this role (see [Embedding modules and plugins in roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#embedding-modules-and-plugins-in-roles) for more information).

So the database example might look like this:

```
ansible.cfg
roles/
	database/
		tasks/
			main.yml
		vars/
			main.yml
```


**Resources:**

[Ansible Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)

# Creating Ansible roles

Because roles are just directories and files, you don't need any special tools for creating roles on your local machine.

You can also use existing roles, hosted on Ansible Galaxy. Because of this there is the `ansible-galaxy` command. 

Today we are just going to focus on creating our own roles, and using them from local ansible configuration files. But the `ansible-galaxy` command can still help with this. 

Try running the command below in a directory containing an empty 'roles' directory.

```bash
ansible-galaxy init --init-path roles db-role
```

This command will create the scaffolding for a 'db-role' inside of the roles directory. Which will create something like this:

```
.
└── roles
    └── db-role
        ├── defaults
        │   └── main.yml
        ├── files
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── README.md
        ├── tasks
        │   └── main.yml
        ├── templates
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml

11 directories, 8 files
```

**Resources:**

- [Ansible Docs](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html)
- [Ansible Galaxy](https://galaxy.ansible.com/ui/)

# Using a role in an Ansible playbook

If your project includes a 'web.yml' playbook, and roles directory that contains a 'db-role' role, you can use that role from your playbook like so:

```yml
# web.yml
---
- name: Roles for the database servers
  hosts: database
  become: true
  roles:
    - db-role
```


**Resources:**
- [Ansible examples](https://github.com/ansible/ansible-examples/tree/master/lamp_simple)
- [Ansible roles tutorial on spacelift](https://spacelift.io/blog/ansible-roles)

