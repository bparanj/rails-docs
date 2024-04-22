b:53:in `process_cache_miss': fingerprint SHA256:/DlLl4s811Q1Ns2VmeGloJ8FEzAaNOkcEJF+4zPiKv4 does not match for "[54.188.245.219]:2222" (Net::SSH::HostKeyMismatch)

ssh-keygen -R "[54.188.245.219]:2222"

sudo -i -u deploy
paste the key into ~/.ssh/authorized_keys

The error you're encountering during your Capistrano deployment (`Net::SSH::HostKeyMismatch`) occurs because the SSH fingerprint of the server you're trying to connect to (EC2 instance) does not match the fingerprint stored in your local `known_hosts` file. This can happen if the server was re-provisioned or its SSH key was changed.

Here’s how to resolve the SSH host key mismatch issue:

1. **Remove the Old SSH Key**: You need to remove the old SSH key from your `known_hosts` file. You can do this manually by editing the `~/.ssh/known_hosts` file and removing the entry corresponding to `54.188.245.219`, or by running the following command:
   ```bash
   ssh-keygen -R "[54.188.245.219]:2222"
   ```
   This command will remove the stored key for the IP address on the specified port.

2. **Retry Deployment**: Once you have removed the offending key, try running your Capistrano deployment again. SSH will prompt you to accept the new host key.
   ```bash
   cap production deploy
   ```
   Make sure to accept the new SSH fingerprint by typing `yes` when prompted.

### Additional Suggestions:

- **Verify SSH Connectivity**: Before running Capistrano, verify that you can SSH into the server using the same credentials and key:
  ```bash
  ssh -i ~/.ssh/your_private_key -p 2222 deploy@54.188.245.219
  ```
  This helps ensure that there are no underlying SSH connectivity issues.

- **Check Capistrano Configuration**: Ensure that your Capistrano configuration (`deploy.rb` or environment-specific files like `production.rb`) is set up correctly, particularly the settings related to the server IP, user, and SSH options.

- **Logging**: If the problem persists, consider enabling more verbose SSH logging in Capistrano by setting `:ssh_options` in your `deploy.rb`:
  ```ruby
  set :ssh_options, {
    verbose: :debug
  }
  ```
  This can provide more insights into what is happening during the SSH connection phase.

By addressing the host key mismatch and ensuring that your SSH configuration is correct, you should be able to proceed with your deployment without encountering this specific error.

The error message you're seeing indicates a problem with SSH key authentication when trying to access your GitHub repository. This is a common issue if the SSH keys are not set up correctly or if the public key is not added to the GitHub account properly.

Here are the steps to resolve this:

1. **Check SSH Keys on Deployment Server**: Ensure that the SSH key pair is correctly set up on the server from which you are deploying (the `deploy@54.188.245.219` server in this case). Check if the public SSH key (`id_rsa.pub` or another key if you are using a different filename) is added to the deploy user's GitHub account. You can list the keys to see which ones are being used by:
   ```bash
   ssh -Tvv git@github.com
   ```
   This command will help you verify which keys are being offered to GitHub and the response from GitHub regarding authentication.

2. **Add SSH Key to GitHub**:
   - On the server, you can display the public key with:
     ```bash
     cat ~/.ssh/id_rsa.pub  # Adjust the file name if you are using a different key
     ```
   - Log into GitHub, go to **Settings** → **SSH and GPG keys**, click on **New SSH key**, give it a title that helps you identify the server, and paste the contents of the public key into the field.

3. **Permissions on GitHub Repository**: Ensure that the deploy user's GitHub account or the SSH key linked to that account has the necessary permissions to access the repository. If the repository is private, the user must be added as a collaborator or the team to which the user belongs must have access rights.

4. **Correct SSH Configuration**:
   - Ensure that the SSH configuration on the deployment server allows SSH forwarding if you're using agent forwarding.
   - Your Capistrano setup in `deploy.rb` or the specific environment file like `config/deploy/production.rb` should have the correct repository URL and branch specified.

5. **Test Manual Clone**:
   - Try manually cloning the repository on the server to see if there are any issues:
     ```bash
     git clone git@github.com:username/repository.git
     ```
   - This can help isolate whether the issue is with Capistrano's configuration or the server's ability to communicate with GitHub.

6. **Capistrano SSH Options**:
   - Make sure your `deploy.rb` or `production.rb` Capistrano configuration includes correct SSH options:
     ```ruby
     set :ssh_options, {
       forward_agent: true,  # This should be true if you rely on SSH agent forwarding
       user: 'deploy',       # Ensure this is the correct user
       keys: %w(~/.ssh/id_rsa)  # Ensure this path is correct
     }
     ```

By following these steps, you should be able to resolve the issue with GitHub repository access during your Capistrano deployment. If the problem persists, double-check all configurations and the setup on both your local machine and the server.

The output you've provided from `ssh -Tvv git@github.com` is quite informative. It shows that the SSH connection to GitHub is successfully established and that the key authentication is working correctly, as indicated by the message:

```plaintext
Hi bparanj! You've successfully authenticated, but GitHub does not provide shell access.
```

This means your SSH key is recognized by GitHub, and you are authenticated without any issues. The "exit status 1" and the message about no shell access are normal for GitHub since it does not provide interactive shell sessions.

### Next Steps for Capistrano Deployment Issue:
Given that SSH key authentication works when tested directly via SSH but fails during Capistrano deployment, here are a few things you should check:

1. **Capistrano Configuration**: Ensure that the Capistrano setup is using the correct SSH key. Sometimes, Capistrano might be configured to use a different key or not use SSH agent forwarding correctly. Verify the `deploy.rb` or specific environment file like `config/deploy/production.rb` for these lines:

    ```ruby
    set :ssh_options, {
      keys: %w(~/.ssh/id_ed25519), # Ensure this path is correct
      forward_agent: true,
      auth_methods: %w(publickey)
    }
    ```

    Ensure the path to the keys is correct and that `forward_agent` is set to `true` if you are using SSH agent forwarding.

2. **SSH Agent Forwarding**:
    - If using SSH agent forwarding, ensure your SSH agent has the keys loaded. You can check this with `ssh-add -L`.
    - Ensure the server you are deploying from has forwarding enabled in its SSH configuration (`/etc/ssh/ssh_config` or `~/.ssh/config`):

      ```plaintext
      Host *
          ForwardAgent yes
      ```

3. **Permissions**: Make sure the SSH keys (`id_ed25519`, etc.) and `.ssh` directory have the correct permissions set:

    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519
    ```

4. **GitHub Repository Access**: Double-check that the repository URL in Capistrano's configuration is correct and that the deploy keys or user keys have access to the repository.

5. **Verbose Deployment**: Run Capistrano with more verbose output to see more detailed error messages. This can be done by adding a verbosity parameter:

    ```bash
    cap production deploy --trace
    ```

This should provide more detailed output on where exactly the deployment process is failing. 

If you continue to face issues, you might want to ensure that the system from which you are deploying (where Capistrano is run) also has the SSH key added to the SSH agent (if using agent forwarding) or is otherwise correctly configured to authenticate against GitHub using the proper SSH key.
