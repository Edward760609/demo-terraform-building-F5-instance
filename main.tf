# Configure the AWS provider
provider "aws" {
  region = "ap-northeast-1"
}

# Create the security groups
resource "aws_security_group" "bigipverify-bigip-external-sg" {
  name   = "bigipverify-bigip-external-sg"
  description = "Security group for external access to the F5 BigIP instances"

  # Add inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bigipverify-bigip-internal-sg" {
  name   = "bigipverify-bigip-internal-sg"
  description = "Security group for internal access to the F5 BigIP instances"

  # Add inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_security_group" "bigipverify-bigip-mgmt-sg" {
  name   = "bigipverify-bigip-mgmt-sg"
  description = "Security group for management access to the F5 BigIP instances"

  # Add inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the network interfaces
resource "aws_network_interface" "bigipverify-bigip-external" {
  subnet_id = var.subnet_id_external
  security_groups = [aws_security_group.bigipverify-bigip-external-sg.id]
}

resource "aws_network_interface" "bigipverify-bigip-internal" {
  subnet_id = var.subnet_id_internal
  security_groups = [aws_security_group.bigipverify-bigip-internal-sg.id]
}

resource "aws_network_interface" "bigipverify-bigip-mgmt" {
  subnet_id = var.subnet_id_mgmt
  security_groups = [aws_security_group.bigipverify-bigip-mgmt-sg.id]
}

# Create the instances
resource "aws_instance" "bigIP-active" {
  ami = var.ami_id
  instance_type = "m5.4xlarge"
  key_name = var.key_name
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.bigipverify-bigip-mgmt.id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.bigipver
    
    # Create the instances (continued)
resource "aws_instance" "bigIP-standby" {
  ami = var.ami_id
  instance_type = "m5.4xlarge"
  key_name = var.key_name
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.bigipverify-bigip-mgmt.id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.bigipverify-bigip-internal.id
  }
  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.bigipverify-bigip-external.id
  }

  # Install the F5 Cloud Failover package when the instance is created
  provisioner "local-exec" {
    command = "apt-get install -y f5-cloud-failover"
  }
}

