# project-transfer

Bash script useful for transferring projects from one Domino instance to another.
The aim of the script is to help in selective migrations between major versions where other tools might fall short.

## Usage

The easiest way to use this tool is to build the Docker image either locally or as a Domino environment.
If you are using a workspace, you will need to copy the `project_transfer.sh` file into the project.

I recommend hard coding the old and new customer Domino urls, for better usability, eg.
```bash
#old_domino_url=${1:?"Old Domino URL is required"} && shift 1
#new_domino_url=${1:?"New Domino URL is required"} && shift 1
old_domino_url="https://vip.domino.tech"
new_domino_url="https://field.cs.domino.tech"
```

Once you have the image/environment, you'll need access to the terminal of the container.  
Then you'll want to run these commands:
```bash
# You may need to make the script executable
chmod +x project_transfer.sh

# Start transferring projects to the new domino (without hardcoded urls)
./project_transfer.sh https://vip.domino.tech https://field.cs.domino.tech test_project_1 test_project_2 test_project_3

# Start transferring projects to the new domino (with hardcoded urls)
./project_transfer.sh test_project_1 test_project_2 test_project_3

# Start transferring projects (as an admin) for other users
# The project will be uploaded under the admin's account, transfer ownership back to the original user 
./project_transfer.sh linus_tarvolds/test_project_1 jeff_bezos/test_project_2
```

## Pitfalls and Workarounds

### SSO Login

If SSO is used for a Domino instance, then when the script presents the user with a login, they will need to use their API key instead of their password.

### Self-Signed Certificates

Some Domino instances use self-signed certificates for SSL. In this event, you'll need to download and add the certs to the Java TrustStore that the CLI uses.  
An example to come later...