## Setup Development Machine 

### Install Ruby

Install Ruby 3.3.0 using RVM on development machine.

```sh {title="Install Ruby"} 
gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash
source /home/ubuntu/.bash_profile
rvm install 3.3.0
```

Check installed version:

```
ruby -v
```

### SSH Key Setup
 
Setup SSH key to access Rails app in Github.

Create the SSH key:

```
ssh-keygen -t ed25519 -C "bparanj@gmail.com"
```

Add it to your Github account.

Get the demo project:

```
git clone git@github.com:bparanj/capt.git
```

Install the dependencies:

```
cd capt
bundle
```

```
export CAPT_DATABASE_PASSWORD='password'
```

Modify config/deploy.rb:

```
# config valid for current version and patch releases of Capistrano
lock "~> 3.18.1"

server '54.188.245.219', user: 'deploy', roles: %w{app db web}, port: 2222
set :application, "capt"
set :repo_url, "git@github.com:bparanj/capt.git"
set :deploy_to, '/home/deploy/apps/capt'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/master.key')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/uploads')
set :keep_releases, 5
```

Copy SSH key in development machine to the server:

cat ~/.ssh/id_ed25519.pub

ssh-ed25519 some-secret <email>

Copy this key to the server:

sudo -i -u deploy
vi ~/.ssh/authorized_keys

Test connection to the server from development machine:

ssh -p 2222 -i ~/.ssh/id_ed25519 deploy@54.188.245.219

Copy database.yml to /home/deploy/apps/capt/shared/config/database.yml: (replace this with task)

# In config/deploy.rb or config/deploy/production.rb

# Task to create database.yml in shared path
namespace :deploy do
  desc 'Setup database configuration'
  task :setup_config do
    on roles(:app) do
      unless test "[ -f #{shared_path}/config/database.yml ]"
        upload! 'config/deploy/templates/database.yml', "#{shared_path}/config/database.yml"
      end
    end
  end
  
  before 'deploy:check:linked_files', 'deploy:setup_config'
end


On development machine, to install pg gem:

sudo apt install libpq-dev
sudo apt install build-essential postgresql-client


cap deploy:check 

cap production deploy

