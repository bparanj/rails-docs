To create an Ansible playbook that restarts the Puma application server, you can leverage the `systemctl` command on systems that use systemd for service management. Below is an example of a playbook that restarts the Puma service, which is a common setup for Rails applications deployed on servers like Ubuntu.

### Playbook: Restart Puma Service

This playbook assumes that you have a systemd service set up for Puma (e.g., `puma.service`) and that you're running this playbook as a user with sufficient privileges to manage system services.

```yaml
---
- name: Restart Puma Service Playbook
  hosts: all
  become: true  # Ensures you have the necessary privileges
  tasks:
    - name: Restart Puma service
      ansible.builtin.systemd:
        name: puma
        state: restarted
        enabled: yes  # Ensures the service is enabled to start at boot
      become: true  # Run task as sudo

    - name: Verify Puma service is running
      ansible.builtin.systemd:
        name: puma
        state: started
      register: puma_status
      failed_when: puma_status.status.ActiveState != "active"
```

### Key Components:

1. **Hosts**: Define the hosts or groups on which this playbook should run. This example uses `all`, but you might want to limit this to a specific group of hosts, such as `web` for your web servers.

2. **Become**: The `become: true` directive is used to gain the necessary privileges to manage system services.

3. **Tasks**:
   - **Restart Puma Service**: This task uses the `systemd` module to restart the Puma service. The `enabled: yes` option ensures that the service will start on boot.
   - **Verify Puma Service**: This task checks to ensure that the Puma service is actively running after the restart. It registers the output of the command to a variable `puma_status` and uses a conditional check to fail the playbook if Puma isn't active.

### How to Use:

1. **Save the Playbook**: Save the playbook in ansible/playbooks as `restart_puma.yml`.
2. **Run the Playbook**: Run the playbook from the ansible folder:

```bash
ansible-playbook -i inventory.ini playbooks/restart-puma.yml
```

Replace `inventory_file` with the path to your inventory file. This playbook will ensure that the Puma service is restarted across the specified hosts and verify that it is running afterward.

### Note:
- Ensure that the Puma service is correctly set up as a systemd service on your target servers.
- Adjust the host group or specific hosts as per your environment's setup in the inventory file.
