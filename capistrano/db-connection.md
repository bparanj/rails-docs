Check that the connection to production database is working.

To test an ActiveRecord database connection in a Rails application, you can use the Rails console. Here’s how to do it concisely:

1. **Open your terminal.**
2. **Navigate to your Rails application directory.**
3. **Enter the Rails console:**
   ```bash
   rails console
   ```
4. **In the Rails console, execute:**
   ```ruby
   ActiveRecord::Base.connection.active?
   ```
   This command returns `true` if the connection is active and working; otherwise, it returns `false`.

This method quickly checks if your ActiveRecord setup can successfully connect to the configured database.
