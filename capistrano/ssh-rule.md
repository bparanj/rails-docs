Manually launching an EC2 instance from Packer image does not have the inbound rule to allow SSH on port 2222.

The type SSH is not one of the options you can pick, select TCP instead of SSH in the following instructions:

To allow SSH connections on port 2222 in AWS, you need to modify the security group settings associated with your instance(s). This involves adding an inbound rule to the security group that allows TCP traffic on port 2222 from your desired source IP range. Here’s how you can do this using both the AWS Management Console and the AWS CLI:

### Using AWS Management Console

1. **Log in to your AWS Management Console**.
2. **Navigate to the EC2 Dashboard**.
3. **In the navigation pane, click on “Security Groups”** under the “Network & Security” section.
4. **Select the security group** you want to modify. This group should be associated with the instances for which you want to allow SSH access.
5. **Go to the Inbound rules tab** and click on “Edit inbound rules”.
6. **Add a new rule**:
   - **Type**: Select "SSH".
   - **Protocol**: TCP.
   - **Port Range**: Enter 2222 (assuming you’ve configured your SSH service to listen on this port instead of the default port 22).
   - **Source**: Choose "Custom" and enter the IP address range from which connections should be allowed. For testing purposes, you can use `0.0.0.0/0` for all IPs (note this is not recommended for production environments due to security risks). For more security, specify your own IP range.
   - **Description**: Optionally, add a description, e.g., "SSH access on port 2222".
7. **Click “Save rules”** to apply your changes.

### Using AWS CLI

If you prefer using the command line, you can add an inbound rule to your security group using the AWS CLI:

1. **First, ensure you have the AWS CLI installed and configured**.
2. **Run the following command** to add the rule (replace `YourSecurityGroupId` with the actual security group ID):

   ```bash
   aws ec2 authorize-security-group-ingress --group-id YourSecurityGroupId --protocol tcp --port 2222 --cidr 0.0.0.0/0 --output text
   ```

   - `--group-id`: The ID of the security group.
   - `--protocol tcp`: Specifies TCP as the protocol.
   - `--port 2222`: Defines the port range (in this case, 2222).
   - `--cidr 0.0.0.0/0`: Defines the IP range allowed to access. Change `0.0.0.0/0` to a more specific CIDR block for better security.

**Security Tip**: It's a best practice to restrict the source IP range (`--cidr`) to only known IPs that require access. Using `0.0.0.0/0` allows all IPs to attempt connections, which could be a significant security risk.

By following these steps, you will successfully configure AWS to allow SSH connections on port 2222 for your EC2 instances.