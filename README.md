# HOW TO USE:
At the root level is a Pipfile. Initiate a pipenv with `pipenv install && pipenv shell`

### If experiencing timeouts and Ansible playbook fails to complete:
try: https://github.com/ansible/ansible/pull/51217/commits/c27a3720a6e583e734641d0724d7f66a8166bbd0

or change connection to `psrp`:https://docs.ansible.com/ansible/latest/plugins/connection/psrp.html (requires python module: pyprsp)

# TO DO:
### EBS
- auto mount volume (right now needs to be initialized, formatted, and assigned letter)
- figure out key encryption aspect - it auto creates key, unsure if we want to use a pre-created key, generate one through TF or use autocreated one (note: letting it autogenerate one for the volume means it is NOT removed when destroying through TF. Best option may be to gen one and pass it to the instance in the TF config)
- destroy volume?

### EC2
- continue working through ansible playbook to automate as many tasks as possible
- consider switching from winrm module to psrp module, which could help alleviate timeouts

## KMS
- if implementing this, need to give TF AWS user permissions to interact with this resource

# Requirements

For sure:
- Terraform binary
- Ansible >= 2.7.9 (not yet released, but should change Pipfile when it is - [Presently have it locked to a specific commit that fixes winrm timing out](https://github.com/ansible/ansible/pull/53307))
- Python 3.7
- pip3
- pipenv
- build-essential
- libssl-dev
- libffi-dev
- python3-dev

