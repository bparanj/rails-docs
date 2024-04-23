Postgresql deploy user for database connection is not setup properly.

```sh
 rails c -e production
Loading production environment (Rails 7.1.3.2)
irb(main):001> ActiveRecord::Base.connection.active?
/home/ubuntu/.gem/gems/activerecord-7.1.3.2/lib/active_record/connection_adapters/postgresql_adapter.rb:76:in `rescue in new_client': There is an issue connecting to your database with your username/password, username: deploy. (ActiveRecord::DatabaseConnectionError)

Please check your database configuration to ensure the username/password are valid.

/home/ubuntu/.gem/gems/pg-1.5.6/lib/pg/connection.rb:701:in `async_connect_or_reset': connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  Peer authentication failed for user "deploy" (PG::ConnectionBad)
```

The error you're encountering indicates that there's a problem with the database connection in your Rails application when trying to access it in the production environment. The specific error message `PG::ConnectionBad: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL: Peer authentication failed for user "deploy"` suggests an issue with the PostgreSQL authentication method configured for the user `deploy`.

Here’s how to address the issue:

### Step 1: Check PostgreSQL Authentication Configuration

The problem likely lies in the `pg_hba.conf` file, which controls the authentication methods used by PostgreSQL. This file is usually located in the PostgreSQL data directory (e.g., `/etc/postgresql/12/main/` on Ubuntu with PostgreSQL 12).

1. **Open the `pg_hba.conf` file**. You might need sudo privileges to view or edit this file:
   ```bash
   sudo nano /etc/postgresql/12/main/pg_hba.conf
   ```

2. **Look for entries** related to local connections or the user `deploy`. By default, PostgreSQL uses "peer" authentication for local connections, which might not be appropriate depending on how your application is configured. Here's a typical peer authentication line for local users:
   ```
   # TYPE  DATABASE        USER            ADDRESS                 METHOD
   local   all             all                                     peer
   ```

3. **Change the authentication method** from `peer` to `md5` or `password` for the user `deploy`, if appropriate. For example, to allow password authentication, you could modify it to:
   ```
   local   all             deploy                                  md5
   ```
   or for all users:
   ```
   local   all             all                                     md5
   ```

4. **Save and close the file**.

### Step 2: Restart PostgreSQL

After updating the `pg_hba.conf` file, restart the PostgreSQL server to apply the changes:
```bash
sudo systemctl restart postgresql
```

### Step 3: Check Database Configuration in Rails

Ensure that your database configuration in `config/database.yml` for the production environment is correct. It should look something like this:
```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: your_production_database
  pool: 5
  username: deploy
  password: <your_password>
  host: localhost
```
Make sure the username and password are correct and match those expected by PostgreSQL.

### Step 4: Retry Connecting to the Database

Go back to your Rails console and try to connect again:
```bash
rails c -e production
```
Then in the console:
```ruby
ActiveRecord::Base.connection.active?
```

This should return `true` if the connection is now successful.

### Conclusion

By modifying the PostgreSQL authentication settings and ensuring the Rails configuration matches, you should be able to resolve the connection issue. Always ensure that the authentication methods and credentials are securely managed, especially in a production environment.
