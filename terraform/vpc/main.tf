resource "aws_vpc" "veeam-backup-vpc" {
  cidr_block = "10.84.3.0/24"
  tags = {
    Name = "veeam-backup-vpc"
  }
}

resource "aws_internet_gateway" "veeam-backup-gw" {
  vpc_id = "${aws_vpc.veeam-backup-vpc.id}"
  tags = {
    Name = "veeam-backup-gateway"
  }
}

resource "aws_subnet" "veeam-backup-subnet" {
  vpc_id = "${aws_vpc.veeam-backup-vpc.id}"
  cidr_block = "10.84.3.0/24"
  availability_zone = "us-east-2c"
  tags {
    Name = "veeam-backup-subnet"
  }
}

resource "aws_security_group" "veeam-backup-sg" {
  name = "veeam-backup-sg"
  vpc_id = "${aws_vpc.veeam-backup-vpc.id}"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_route_table_association" "veeam-backup-rta" {
  subnet_id      = "${aws_subnet.veeam-backup-subnet.id}"
  route_table_id = "${aws_route_table.veeam-backup-rt.id}"
}

resource "aws_route_table" "veeam-backup-rt" {
  vpc_id = "${aws_vpc.veeam-backup-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.veeam-backup-gw.id}"
  }
  tags = {
    Name = "main"
  }
}

output "vpc-id" {
  value = "$(aws_vpc.veeam-backup-vpc.id)"
}

output "subnet-id" {
  value = "${aws_subnet.veeam-backup-subnet.id}"
}

output "sg-id" {
  value = "${aws_security_group.veeam-backup-sg.id}"
}
