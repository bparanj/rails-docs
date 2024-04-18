Using ruby-install to install gem leads to :

Bundler::PermissionError: There was an error while trying to write to `/usr/local/lib/ruby/gems/3.3.0/cache/rake-13.2.1.gem`. It
is likely that you need to grant write permissions for that path.

when installing gems.

The error you're encountering, `Bundler::PermissionError`, suggests that Bundler does not have the necessary write permissions to install gems in the specified directory (`/usr/local/lib/ruby/gems/3.3.0/cache`). This is a common issue when trying to install Ruby gems system-wide without sufficient privileges.

### Solutions to Resolve the Permission Error

Here are several approaches to resolving this issue, depending on your specific setup and requirements:

#### 1. **Use `sudo` with Gem Installation (Not Recommended)**
Using `sudo` to run Bundler or gem installation commands grants the necessary permissions to write to the system directories. However, using `sudo` with Ruby gems is generally discouraged because it can lead to security risks and potential conflicts with system-managed files.

If you choose to use `sudo`, here’s how you can do it:
```bash
sudo gem install bundler
sudo bundler install
```

#### 2. **Configure Gem Installation Directory for Current User**
A safer and more recommended approach is to configure Bundler and RubyGems to install gems in a directory where your user has write permissions. You can configure this by setting the `GEM_HOME` and `GEM_PATH` environment variables.

For example, to set these in your `.bashrc` or `.zshrc` file:
```bash
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$HOME/.gem"
export PATH="$HOME/.gem/bin:$PATH"
```
After adding these lines, run `source ~/.bashrc` or `source ~/.zshrc` to reload your shell configuration.

Now, when you install gems using Bundler or RubyGems, they will be installed in your home directory under `.gem`.

#### 3. **Use a Version Manager for Ruby**
Using a Ruby version manager like `rbenv` or `RVM` can help manage Ruby versions and gems without needing elevated permissions. These tools install Ruby and its gems in your user's home directory, avoiding the need for `sudo`.

- **Installing `rbenv`** (example on a Unix-like system):
  ```bash
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  source ~/.bashrc
  ```
- **Installing Ruby using `rbenv`**:
  ```bash
  rbenv install 3.3.0
  rbenv global 3.3.0
  ```

- **Installing `RVM`**:
  ```bash
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  \curl -sSL https://get.rvm.io | bash -s stable
  source ~/.rvm/scripts/rvm
  rvm install 3.3.0
  rvm use 3.3.0 --default
  ```

### Conclusion
The preferred method is generally to configure the gem installation directory for your user or to use a version manager, as these methods avoid potential security issues associated with using `sudo`. Choose the method that best fits your environment and workflow.

If you used `ruby-install` to install Ruby, you have a flexible setup, but you may need to adjust some configurations to ensure gems are installed without requiring sudo. `ruby-install` typically installs Ruby into `/opt/rubies` or a similar directory, which might require elevated permissions for writing, depending on how your system permissions are configured.

### Adjusting Environment Variables

To avoid needing sudo for installing gems, you should set your `GEM_HOME` and `GEM_PATH` to a directory within your user's home directory. This ensures that all gem installations go to a location where you have write access.

Here’s how you can configure these environment variables:

1. **Open your shell configuration file** (`~/.bashrc`, `~/.zshrc`, etc.) with a text editor.

2. **Add these lines** to set `GEM_HOME` and `GEM_PATH`, and append the gem binary directory to your `PATH`:

    ```bash
    export GEM_HOME="$HOME/.gem"
    export GEM_PATH="$HOME/.gem"
    export PATH="$HOME/.gem/bin:$PATH"
    ```

3. **Save the file** and reload your shell configuration by running:
    ```bash
    source ~/.bashrc  # If using bash
    source ~/.zshrc   # If using zsh
    ```

4. **Verify the configuration** by checking the environment variables:
    ```bash
    echo $GEM_HOME
    echo $GEM_PATH
    ```

### Installing Gems

Once the environment variables are set, you should be able to install gems without sudo:

```bash
gem install bundler
bundler install
```

### Using `ruby-install` and `chruby`

If you’re using `chruby` in conjunction with `ruby-install` (a common setup), make sure that `chruby` is configured to automatically adjust `GEM_HOME` and `GEM_PATH`. This is usually handled by `chruby`'s auto-switching feature if you've sourced `chruby.sh` and `auto.sh` in your shell configuration file:

```bash
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
```

Ensure that `chruby` is correctly switching to the Ruby version installed by `ruby-install`:

```bash
chruby
```

This command lists available Ruby versions and shows the currently active version. You can switch to a specific version with:

```bash
chruby ruby-3.3.0
```

### Final Checks

After these settings, test the installation of a new gem to ensure everything is configured correctly:

```bash
gem install rake
```

This command should install `rake` without requiring sudo, placing the gem in `$HOME/.gem`.

### Conclusion

Setting up `GEM_HOME` and `GEM_PATH` within your home directory allows you to manage Ruby gems installed via `ruby-install` or any other method without needing elevated permissions. This approach enhances both security and ease of use in managing Ruby environments.

Given that the output of `which ruby` shows `/usr/local/bin/ruby`, it appears that Ruby is installed globally on your system and likely managed by a system-level package manager or a manual installation into `/usr/local/bin`. This setup can require administrative privileges (sudo) for installing gems globally, which isn't ideal for development environments due to potential permission and path issues.

### Resolving Ruby Gem Installation Issues

To address this and avoid needing `sudo` for installing Ruby gems, here are some steps to help you manage Ruby environments and gem installations more effectively, especially if you want to keep using the globally installed Ruby:

#### 1. **Set Up Local Gem Installation**

As previously mentioned, configuring `GEM_HOME` and `GEM_PATH` to a user-owned directory helps avoid permission issues. This setup also works with the globally installed Ruby:

1. **Open your shell configuration file** (like `~/.bashrc` or `~/.zshrc`) with your favorite editor.

2. **Add the following lines** to configure local gem installation paths:

   ```bash
   export GEM_HOME="$HOME/.gem"
   export GEM_PATH="$HOME/.gem"
   export PATH="$HOME/.gem/bin:$PATH"
   ```

3. **Reload your shell configuration** to apply these changes:

   ```bash
   source ~/.bashrc  # If you are using bash
   source ~/.zshrc   # If you are using zsh
   ```

4. **Test the configuration** by installing a gem:

   ```bash
   gem install bundler
   ```

   This command should install `bundler` without requiring sudo.

#### 2. **Consider Using a Ruby Version Manager**

Using a Ruby version manager like `rbenv` or `RVM` can simplify managing Ruby versions and gemsets without affecting the system-wide Ruby installation:

- **rbenv**: Manages Ruby versions by inserting a directory of shims at the front of the `PATH`:

  ```bash
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  source ~/.bashrc
  rbenv install 3.0.0
  rbenv global 3.0.0
  ```

- **RVM**: Supports managing multiple Ruby environments independently:

  ```bash
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  \curl -sSL https://get.rvm.io | bash -s stable
  source ~/.rvm/scripts/rvm
  rvm install 3.0.0
  rvm use 3.0.0 --default
  ```

These managers not only help with avoiding permission issues but also allow you to work with multiple Ruby versions for different projects.

#### 3. **Adjust System Ruby (Not Recommended)**

While not recommended due to potential conflicts with other system applications, you can technically adjust the permissions of the `/usr/local/bin/ruby` directory to allow your user to manage gems without sudo. This is least advised as it can lead to system instability.

### Conclusion

For a development environment, using `rbenv` or `RVM` provides flexibility and avoids permission issues associated with a global Ruby installation. Alternatively, configuring local gem paths allows immediate relief from permission issues without needing to install additional tools.
