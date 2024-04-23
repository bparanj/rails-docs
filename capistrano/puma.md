To create an Ansible playbook that configures a Puma service and allows you to set the application name dynamically from the command line, you can use Ansible's templating features along with the `extra-vars` option for passing variables during runtime.

### Step 1: Create the Template for the Systemd Service File

First, create a Jinja2 template file for your systemd service (`puma.service.j2`) that uses a variable for the application path:

```jinja2
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/apps/{{ app_name }}/current
ExecStart=/bin/bash -lc 'bundle exec puma -C /home/deploy/apps/{{ app_name}}/current/config/puma.rb'
Restart=always

[Install]
WantedBy=multi-user.target
```

### Step 2: Write the Ansible Playbook

Create a playbook (`puma.yml`) that uses this template to configure the systemd service file:

```yaml
---
- name: Configure Puma Systemd Service
  hosts: all
  become: true

  vars:
    app_name: "{{ app_name }}"  # This will be overridden by command-line input

  tasks:
    - name: Copy the Puma systemd service file from template
      ansible.builtin.template:
        src: ../templates/puma.service.j2
        dest: /etc/systemd/system/puma.service
      notify:
        - reload systemd
        - restart puma service

  handlers:
    - name: reload systemd
      ansible.builtin.systemd:
        daemon_reload: yes

    - name: restart puma service
      ansible.builtin.systemd:
        name: puma
        state: restarted
        enabled: yes
```

### Step 3 : Create the Inventory File

Create the inventory.ini file inside the ansible directory in hivegrid.dev project:

```sh
[ec2_instances]
54.188.245.219

[ec2_instances:vars]
ansible_port=2222
ansible_user=ubuntu
ansible_ssh_private_key_file=/Users/bparanj/work/hivegrid.dev/javascript/rails-server.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Step 4: Run the Playbook with the Application Name

Provide the application name using the `--extra-vars` or `-e` option, when running the playbook:

```sh
ansible-playbook -i inventory.ini playbooks/puma.yml -e "app_name=capt"
```

This command sets the `app_name` variable to "capt", which is used in the playbook to configure the paths in the systemd service file correctly.

### Explanation

- **Templates** the systemd service configuration for Puma using a variable for the application name, making it reusable for different applications.
- **Reloads** systemd to recognize changes to the service definitions.
- **Restarts** the Puma service to apply the new configuration.

This approach ensures flexibility and reusability, allowing you to deploy and manage the Puma service for different Rails applications without modifying the playbook.

Next step: Setup SSL. 

- Map IP to domain
- Run SSL playbook
- Restart Puma after deploy

