rails new capt --css tailwind --database=postgresql

export CAPT_DATABASE_PASSWORD='password'
echo $CAPT_DATABASE_PASSWORD

config/database.yml

production:
  <<: *default
  database: capt_production
  username: deploy 
  password: <%= ENV["CAPT_DATABASE_PASSWORD"] %>

Add:

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  
  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
end

bundle

cap install

Capfile:

```ruby
# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
#
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
```

config/deploy.rb:

```ruby
set :application, "capt"
server '54.188.245.219', user: 'deploy', roles: %w{app db web}, port: 2222
set :repo_url, "git@github.com:bparanj/capt.git"
set :deploy_to, '/var/www/capt'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/master.key')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/uploads')
set :keep_releases, 5
```

ubuntu@ip-172-31-37-34:~/work/capt$ ssh-add -l
Could not open a connection to your authentication agent.
ubuntu@ip-172-31-37-34:~/work/capt$ eval "$(ssh-agent -s)"
Agent pid 34680
ubuntu@ip-172-31-37-34:~/work/capt$ ssh-add
Identity added: /home/ubuntu/.ssh/id_ed25519 (email)
ubuntu@ip-172-31-37-34:~/work/capt$ ssh-add -l
256 SHA256:blah-b-b email (ED25519)

see capistrano/ssh-setup.md

ssh-copy-id -i ~/.ssh/id_ed25519.pub deploy@54.188.245.219 -p 2222


Packages needed to install Ruby using rvm:

 bzip2, g++, gcc, autoconf, automake, bison, libc6-dev, libffi-dev, libgdbm-dev, libncurses5-dev, libsqlite3-dev, libtool, libyaml-dev, make, pkg-config, sqlite3, zlib1g-dev, libgmp-dev, libreadline-dev, libssl-dev.

Sequence

1. Run cap production deploy
2. Run puma.yml
3. Run caddy_ssl.yml

Revise: https://github.com/bparanj/rails-docs