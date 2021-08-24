// Generate tmp private key to setup cluster
resource "tls_private_key" "temp" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

locals {
  tmp_private_key = nonsensitive(tls_private_key.temp.private_key_pem)
  tmp_public_key  = tls_private_key.temp.public_key_openssh
}

// cluster
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "node_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.private_subnet_id[1]
  security_groups             = [var.sg_cluster_id]
  key_name                    = var.node_key_name
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              # Sleep to ensure that infrastructure is up
              sleep 270
              # Install microk8s with addons
              sudo apt update
              sudo apt upgrade -y
              sudo snap install microk8s --classic
              sudo usermod -a -G microk8s ubuntu
              sudo chown -f -R ubuntu ~/.kube
              su - ubuntu
              microk8s status --wait-ready
              microk8s enable dns ingress
              # Setup public key for communication to master node
              echo "${local.tmp_public_key}" >> /home/ubuntu/.ssh/authorized_keys
              sudo systemctl restart ssh
	          EOF

  tags = {
    Name = "node_2"
  }

  depends_on = [
    tls_private_key.temp
  ]
}

resource "aws_instance" "node_3" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.private_subnet_id[2]
  security_groups             = [var.sg_cluster_id]
  key_name                    = var.node_key_name
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              # Sleep to ensure that infrastructure is up
              sleep 270
              # Install microk8s with addons
              sudo apt update
              sudo apt upgrade -y
              sudo snap install microk8s --classic
              sudo usermod -a -G microk8s ubuntu
              sudo chown -f -R ubuntu ~/.kube
              su - ubuntu
              microk8s status --wait-ready
              microk8s enable dns ingress
              # Setup public key for communication to master node
              echo "${local.tmp_public_key}" >> /home/ubuntu/.ssh/authorized_keys
              sudo systemctl restart ssh
	          EOF

  tags = {
    Name = "node_3"
  }

  depends_on = [
    tls_private_key.temp
  ]
}

// Get private ipv4 of worker nodes
data "aws_instance" "node_2" {
  instance_id = aws_instance.node_2.id
}

data "aws_instance" "node_3" {
  instance_id = aws_instance.node_3.id
}

resource "aws_instance" "node_1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.small"
  subnet_id       = var.private_subnet_id[0]
  security_groups = [var.sg_cluster_id]
  // This time Im using only one key
  // because it will be easier to show "internals" of infrastructure
  // In "real-case" scenario there would be different keys for each instance.
  // But in truly real-case scenario I would try to implement Session Manager
  key_name                    = var.node_key_name
  associate_public_ip_address = false

  // Script to initialize kubernetes cluster
  user_data = <<-EOF
              #!/bin/bash
              # Sleep to ensure that infrastructure is up
              sleep 270
              # Install microk8s with addons
              sudo apt update
              sudo apt upgrade -y
              sudo snap install microk8s --classic
              sudo usermod -a -G microk8s ubuntu
              sudo chown -f -R ubuntu ~/.kube
              su - ubuntu
              microk8s status --wait-ready
              microk8s enable dns ingress
              # Setup private key for communication between nodes
              echo "${local.tmp_private_key}" > /tmp/tmp_private_key.pem
              sudo chmod 700 /tmp/tmp_private_key.pem
              sudo chown ubuntu:ubuntu /tmp/tmp_private_key.pem
              # Setup nodes
              sudo microk8s add-node | sed -n '2p' > /tmp/worker_2
              export W2="sudo $(cat /tmp/worker_2)"
              ssh -o "StrictHostKeyChecking no" -i /tmp/tmp_private_key.pem ubuntu@${data.aws_instance.node_2.private_ip} -t $W2
              sleep 10
              sudo microk8s add-node | sed -n '2p' > /tmp/worker_3
              export W3="sudo $(cat /tmp/worker_3)"
              ssh -o "StrictHostKeyChecking no" -i /tmp/tmp_private_key.pem ubuntu@${data.aws_instance.node_3.private_ip} -t $W3
	          EOF

  tags = {
    Name = "node_1"
  }
  // Wait for worker nodes to initialize
  // so userdata will run successfully
  depends_on = [
    aws_instance.node_2,
    aws_instance.node_3,
    tls_private_key.temp,
    data.aws_instance.node_2,
    data.aws_instance.node_3
  ]
}
