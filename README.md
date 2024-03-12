# Ruby on Rails Documentation

| Software | Version |
| -------- | ------- |
| Ruby     | 3.3.0   |
| Rails    | 7.1.2   |


## Deployment

1. Create host.ini file.
2. Run the playbook:

```
ansible-playbook -i inventory.ini deploy.yml
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

sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma
sudo systemctl status puma


## Code Formatting

Format code:

```
rubocop -a
```

Automatically indent:

```
rubocop -A
```

## Minitest Assertion

https://ruby-doc.org/stdlib-3.1.1/libdoc/minitest/rdoc/Minitest/Assertions.html

## Debugger

Add gem "debug" to the test case and use `debugger` on the line you want the execution to stop for debugging.
https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem

## Bug Report Templates

[Templates](https://github.com/rails/rails/tree/main/guides/bug_report_templates)