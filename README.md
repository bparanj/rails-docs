Production server:

```sh
ssh -i rails-server.pem -p 2222 ubuntu@54.188.245.219 
```

# Ruby on Rails Documentation

| Software | Version |
| -------- | ------- |
| Ruby     | 3.3.0   |
| Rails    | 7.1.2   |

## Sequence

1. Run deploy.yml 
2. Run puma.yml
3. Run caddy_ssl.yml

Pending:

Move the playbooks from iac codebase to this codebase.

## Deployment

1. Create host.ini file.
2. Run the playbook:

```sh
ansible-playbook -i inventory.ini deploy.yml
```

## SSL Playbook

```sh
ansible-playbook -i inventory.ini caddy_ssl.yml
```

## Puma Service

Create an entry in /etc/systemd/system/puma.service:

```
[Unit]
Description=Rails Puma Webserver
Wants=network-online.target
After=network.target network-online.target
 
[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/rails-docs/
ExecStart=/bin/bash -lc 'bundle exec puma -C /var/www/rails-docs/config/puma.rb'

TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

```sh
sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma
sudo systemctl status puma
```

## Code Formatting

Format code:

```sh
rubocop -a
```

Automatically indent:

```sh
rubocop -A
```

## Debugger

Add gem "debug" to the test case and use `debugger` on the line you want the execution to stop for debugging.
https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
