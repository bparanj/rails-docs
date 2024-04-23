To configure Capistrano to restart Puma after each deployment, you'll need to set up a custom task within your Capistrano deployment scripts. This involves editing the `deploy.rb` file or the specific environment file like `config/deploy/production.rb` to include a task that manages the Puma restart. Here's how to do it step-by-step:

### Step 1: Define the Puma Restart Task

You can define a task to restart Puma by sending specific commands to manage the Puma service. The exact command can vary depending on how Puma is set up (e.g., using systemd, an init script, or directly with Capistrano puma plugin).

#### Using Systemd

If Puma is managed with `systemd`, you might have a service file set up for your application. Here’s how you can create a Capistrano task to restart it:

1. **Edit `deploy.rb` or `config/deploy/production.rb`**:
   ```ruby
   namespace :puma do
     desc 'Restart Puma'
     task :restart do
       on roles(:app) do
         execute :sudo, 'systemctl restart puma_your_application_name.service'
       end
     end
   end
   ```

   Replace `puma_your_application_name.service` with the actual name of your Puma service file.

#### Using Capistrano Puma Plugin

If you are using the Capistrano-puma gem (https://github.com/seuros/capistrano-puma), restarting Puma can be automated by the plugin itself. Ensure you have the following in your `Capfile`:

```ruby
require 'capistrano/puma'
install_plugin Capistrano::Puma  # Default puma tasks
install_plugin Capistrano::Puma::Workers  # if you want to control the workers (in clustered mode)
install_plugin Capistrano::Puma::Jungle  # if you need the jungle tasks
install_plugin Capistrano::Puma::Monit  # if you need the monit tasks
install_plugin Capistrano::Puma::Nginx  # if you want to control Nginx
```

Then, Puma will be automatically restarted if configured properly in the `deploy.rb` or `config/deploy/production.rb`.

### Step 2: Hook the Restart Task into the Deployment Process

You can hook your restart task at the end of the deployment process to ensure it runs each time you deploy:

```ruby
after 'deploy:published', 'puma:restart'
```

This line means "after the deploy:published event, run the puma:restart task."

### Step 3: Ensure Proper Permissions

Make sure that the deployment user (`deploy` user typically) has the necessary permissions to restart Puma, especially if you're using system commands like `systemctl`. This might require tweaking `sudoers` settings to allow passwordless sudo for specific commands.

### Step 4: Deploy

Once you’ve set up the tasks and hooks, run your Capistrano deployment with:

```bash
cap production deploy
```

This should complete the deployment and restart Puma using the method you configured.

By following these steps, you ensure that Puma is correctly restarted after each deployment, maintaining uptime and applying the latest application updates automatically.