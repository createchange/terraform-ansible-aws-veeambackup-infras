module "vpc" {
  source = "../vpc"
}

data "template_file" "user-data" {
  template = "${file("templates/user-data.ps1")}"
}

variable "ansible-vars" {
  type = "string"
  default = "ansible_user=administrator ansible_password=redacted ansible_connection=winrm ansible_winrm_server_cert_validation=ignore ansible_winrm_transport=ntlm ansible_winrm_message_encryption=auto"
}

resource "aws_instance" "veeam-backup-server" {
  subnet_id = "${module.vpc.subnet-id}"
  security_groups = ["${module.vpc.sg-id}"]
  ami           = "ami-08b4a0f6e106c1dba"
  instance_type = "t3.medium"
  key_name = "veeam_key"
  user_data = "${data.template_file.user-data.rendered}"
  associate_public_ip_address = "true"
  availability_zone = "us-east-2c"

  credit_specification {
    cpu_credits = "standard"
  }

  tags {
    Name = "Veeam Backup Server - template"
    OS = "Windows Server 2016"
  }
  provisioner "local-exec" {
    command = "cd ../ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u administrator -i '${aws_instance.veeam-backup-server.public_ip},' playbooks/ec2-prep.yml -vvvv --extra-vars '${var.ansible-vars}'"
  }
}

resource "aws_ami_from_instance" "veeam-ami" {
  name = "veeam-ami"
  source_instance_id = "${aws_instance.veeam-backup-server.id}"
}

resource "aws_ami_copy" "veeam-encrypted-ami" {
  name = "veeam-encrypted-ami"
  description = "Encrypted Veeam 365 Backup AMI"
  source_ami_id = "${aws_ami_from_instance.veeam-ami.id}"
  source_ami_region = "us-east-2"
  encrypted = "true"
}

resource "aws_instance" "veeam-backup-server-encrypted" {
  subnet_id = "${module.vpc.subnet-id}"
  security_groups = ["${module.vpc.sg-id}"]
  ami           = "${aws_ami_copy.veeam-encrypted-ami.id}"
  instance_type = "t3.medium"
  key_name = "veeam_key"
  associate_public_ip_address = "true"
  availability_zone = "us-east-2c"

  credit_specification {
    cpu_credits = "standard"
  }

  tags {
    Name = "Veeam Backup Server"
    OS = "Windows Server 2016"
  }
provisioner "local-exec" {
    command = "cd ../ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u administrator -i '${aws_instance.veeam-backup-server-encrypted.public_ip},' playbooks/site.yml -vvvv --extra-vars '${var.ansible-vars}'"
  }
}
