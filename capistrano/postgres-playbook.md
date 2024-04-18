Fix for deploy user password issue for database.

The issue you're encountering with the PostgreSQL playbook, where the general `peer` authentication method directive for all users (`local all all peer`) overrides the specific directive for the `deploy` user (`local all deploy md5`), can be resolved by ensuring that the specific configuration for the `deploy` user is placed before the general configuration in the `pg_hba.conf` file. Order matters in the `pg_hba.conf` file because PostgreSQL reads this file from top to bottom, applying the first matching rule it finds.

### Correcting the Playbook

To fix this, you need to modify the Ansible playbook to ensure that the line setting the `md5` authentication for the `deploy` user is inserted before any broader directives that could override it. You can use the `insertbefore` parameter in the `lineinfile` module to specify where the line should be added in the file.

Here's how you can modify your playbook to fix the authentication issue:

```yaml
- name: Install PostgreSQL 16 on Ubuntu 22.04
  hosts: all
  become: true  # Use sudo
  vars:
    ansible_python_interpreter: /usr/bin/python3

  tasks:
    # (Previous tasks remain unchanged...)

    - name: Ensure libpq-dev is installed (Ubuntu/Debian)
      ansible.builtin.apt:
        name: libpq-dev
        state: present

    - name: Install psycopg2-binary using pip3  # Required for postgresql modules
      ansible.builtin.pip:
        name: psycopg2-binary
        state: present

    - name: Create database user with a password and grant CREATE DB privilege
      ansible.builtin.postgresql_user:
        login_user: postgres
        name: deploy
        password: "password"
        state: present
        role_attr_flags: CREATEDB
      become: true
      become_user: postgres

    - name: Add deploy user md5 auth to pg_hba.conf before general directive
      ansible.builtin.lineinfile:
        path: /etc/postgresql/16/main/pg_hba.conf
        insertbefore: '^local\s+all\s+all\s+peer$'
        line: "local   all             deploy                                  md5"
        state: present
      become: true
      notify: restart postgresql

    - name: Ensure general peer authentication is set
      ansible.builtin.lineinfile:
        path: /etc/postgresql/16/main/pg_hba.conf
        regexp: '^local\s+all\s+all\s+peer$'
        line: "local   all             all                                     peer"
        state: present
      notify: restart postgresql

  handlers:
    - name: restart postgresql
      ansible.builtin.service:
        name: postgresql
        state: restarted
        enabled: yes
```

### Key Adjustments
- **Adjusted `Add deploy user md5 auth to pg_hba.conf before general directive` task**: This task now ensures that the specific directive for the `deploy` user is added before the general `peer` directive using the `insertbefore` parameter.
- **Idempotence and Order**: The `lineinfile` tasks are idempotent and will only modify the file if the exact line does not exist already. The order of lines as managed by Ansible ensures the correct application of rules.

### Final Recommendation
Run this playbook to apply the changes. After running, verify that the `pg_hba.conf` file has the correct order of lines, and then test connectivity as the `deploy` user to ensure that `md5` authentication is working as expected.

See the corrected playbook in hivegrid.dev codebase.

Yes, the Ansible playbook you provided appears correct for the purpose of installing PostgreSQL 16 on Ubuntu 22.04, configuring it, and managing access through the `pg_hba.conf` file. The tasks are well-defined and logically ordered to ensure the PostgreSQL environment is set up efficiently and securely.

### Overview of Key Aspects

1. **Install Prerequisites** - Correctly ensures that necessary packages like `ca-certificates` and `wget` are installed, which are essential for further tasks such as downloading and verifying the GPG key.

2. **GPG Key and Repository Setup** - Adds the PostgreSQL repository and its GPG key correctly to ensure that packages are downloaded from a trusted source.

3. **PostgreSQL Installation** - Installs PostgreSQL 16 and its client, which are specified correctly.

4. **Environment Setup** - The playbook makes sure the PostgreSQL environment (like the directory for Ansible operations) is prepared with appropriate permissions.

5. **Service Management** - Ensures PostgreSQL service is enabled and starts at boot, and is configured to listen only on localhost for increased security.

6. **Database User and Permissions** - Appropriately handles the creation of the database user and adjusts permissions to allow database operations, setting a strong foundation for database interactions.

7. **Modify `pg_hba.conf`** - Correctly places the line for the `deploy` user using MD5 authentication above the general directive to ensure that it doesn't get overridden by more generic configurations.

8. **Restart Handler** - Utilizes a handler to restart PostgreSQL when necessary, ensuring changes in configurations take effect without manual intervention.

### Specific Suggestions

- **Template Use**: When modifying configuration files or setting up repositories, consider using Ansible's `template` module for more dynamic and complex configurations. This allows you to use Jinja2 templates to manage configurations, which can be more maintainable and scalable.

- **Variable Management**: Ensure that sensitive data, like the database user password (`"password"`), is managed securely, potentially using Ansible vault or environment variables, rather than hardcoding in the playbook.

- **Idempotence Check**: While `lineinfile` is used effectively here, double-check that these entries do not duplicate if the playbook runs multiple times. Ansible is generally good at ensuring idempotence, but it's a best practice to verify this behavior.

- **Security Best Practices**: While configuring PostgreSQL to listen only on localhost is good for security, also ensure that all external connections (if required) are secured and encrypted, possibly using SSL.

Overall, your playbook is well-constructed and should achieve the setup and configuration goals effectively. Just ensure to handle sensitive data carefully and verify the idempotence of tasks in practical deployments.
