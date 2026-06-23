resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  for_each = toset(var.allowed_ssh_cidrs)

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "dns_tcp" {
  for_each = toset(var.dns_allowed_cidrs)

  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "dns_udp" {
  for_each = toset(var.dns_allowed_cidrs)

  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.this.id
}

# If no AMI provided via ami_map or ami_default, fall back to SSM parameter
data "aws_ami" "ubuntu_lts" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
}

locals {
  ami_from_map = lookup(var.ami_map, var.aws_region, "")
  ami_final    = local.ami_from_map != "" ? local.ami_from_map : (var.ami_default != "" ? var.ami_default : data.aws_ami.ubuntu_lts.id)
}

resource "aws_instance" "this" {
  ami                    = local.ami_final
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_name

  # Set private_ip only when provided
  private_ip = var.private_ip != "" ? var.private_ip : null

  user_data = var.user_data

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "this" {
  count    = var.assign_eip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"
}
