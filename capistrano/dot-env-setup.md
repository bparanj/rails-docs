To use the `dotenv` gem to manage production environment variables in a Rails application deployed with Capistrano, you need to follow a few steps to properly integrate and automate the process. The `dotenv` gem allows you to load environment variables from a `.env` file into the ENV in your application, which can be very useful for managing configuration separate from your code.

### Step 1: Add dotenv to Your Gemfile

First, make sure that `dotenv-rails` is included in your Gemfile. It's common to include it in both the development and production groups if you're going to use it in production, or you might choose to only include it in the production group.

```ruby
# Gemfile
group :development, :production do
  gem 'dotenv-rails'
end
```

Run `bundle install` to install the gem.

### Step 2: Create Environment Files

Create a `.env.production` file in your Rails project root directory (or wherever you manage your environment files). This file will contain all your production environment variables.

```plaintext
# .env.production
DATABASE_URL="postgres://user:password@localhost/mydatabase"
SECRET_KEY_BASE="someverysecuresecretkey"
ANOTHER_API_KEY="yourapikey"
```

### Step 3: Configuring Capistrano

You'll need to make sure Capistrano copies this `.env.production` file to the server on each deploy, and ideally, it should be symlinked to the `current` directory after each deployment.

1. **Add the `.env.production` file to your `shared` directory on the server.** You can do this manually or write a task in Capistrano to do it once.

2. **Configure Capistrano to symlink the file during deploys.** Edit your `deploy.rb` or `config/deploy/production.rb` to include a task that symlinks your `.env.production` file.

```ruby
# config/deploy.rb or config/deploy/production.rb

append :linked_files, '.env.production'

namespace :deploy do
  after :updating, :link_dotenv do
    on roles(:app) do
      execute :ln, "-s", "#{shared_path}/.env.production", "#{release_path}/.env.production"
    end
  end
end
```

### Step 4: Loading Environment Variables

Ensure that your application loads the environment variables from the `.env.production` file. With `dotenv-rails`, this should be handled automatically. However, make sure that the `dotenv-rails` gem is not restricted to the `development` group in your Gemfile.

### Step 5: Deploy

Now, when you deploy with Capistrano, the `.env.production` file should be symlinked from the `shared` directory to each new `release` directory. The environment variables it contains will be loaded by your application.

```bash
cap production deploy
```

### Security Note

Be cautious with your `.env.production` file:
- **Do not commit this file to your version control system.** You might want to add `.env.production` to your `.gitignore` file.
- **Manage access permissions** on the server to ensure that only the application and authorized users can read this file.

Using the `dotenv` gem with Capistrano in this way lets you manage your application's configuration securely and efficiently, leveraging Capistrano's powerful deployment capabilities along with the simplicity of environment variable management provided by `dotenv`.
