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
WorkingDirectory=/var/www/{{ app_name }}/current
ExecStart=/bin/bash -lc 'bundle exec puma -C /var/www/{{ app_name }}/shared/puma.rb'
Restart=always

[Install]
WantedBy=multi-user.target
```

### Step 2: Write the Ansible Playbook
Create a playbook (`setup_puma_service.yml`) that uses this template to configure the systemd service file:

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
        src: puma.service.j2
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

### Step 3: Run the Playbook with the Application Name
When you want to run the playbook, you provide the application name using the `--extra-vars` or `-e` option:

```bash
ansible-playbook -i inventory.ini setup_puma_service.yml -e "app_name=railsdox"
```

This command sets the `app_name` variable to "railsdox", which is then used in the playbook to configure the paths in the systemd service file correctly.

### Explanation
This playbook:
- **Templates** the systemd service configuration for Puma using a variable for the application name, making it reusable for different applications.
- **Reloads** systemd to recognize changes to the service definitions.
- **Restarts** the Puma service to apply the new configuration.

This approach ensures flexibility and reusability, allowing you to easily deploy and manage the Puma service for different Ruby on Rails applications without modifying the playbook for each one.
