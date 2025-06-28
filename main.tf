# Providers for each region
provider "aws" {
  alias = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias = "eu_west"
  region = "eu-west-1"
}

provider "aws" {
  alias = "ap_southeast"
  region = "ap-southeast-1"
}

# key-pair for ssh
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# key made available for ansible
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/artillery-key.pem"
  file_permission = "0600"
}

# =============================
# us-east-1 Resources - Artillery Basecamp
# =============================

resource "aws_vpc" "us_east_vpc" {
  provider = aws.us_east
  cidr_block = "18.1.0.0/16"
  tags = { Name = "Artillery-Basecamp" }
}

resource "aws_subnet" "us_east_subnet" {
  provider = aws.us_east
  vpc_id = aws_vpc.us_east_vpc.id
  cidr_block = "18.1.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "us_east_igw" {
  provider = aws.us_east
  vpc_id = aws_vpc.us_east_vpc.id
}

resource "aws_route_table" "us_east_rt" {
  provider = aws.us_east
  vpc_id = aws_vpc.us_east_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.us_east_igw.id
  }
}

resource "aws_route_table_association" "us_east_rta" {
  provider = aws.us_east
  subnet_id = aws_subnet.us_east_subnet.id
  route_table_id = aws_route_table.us_east_rt.id
}

resource "aws_security_group" "us_east_sg" {
  provider = aws.us_east
  name = "allow_ssh_http_us"
  description = "Allow SSH and outbound HTTP traffic"
  vpc_id = aws_vpc.us_east_vpc.id

  ingress {
    from_port = 2222
    to_port = 2222
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "us_east_key" {
  provider   = aws.us_east
  key_name   = "artillery-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "us_east_artillery" {
  count = 4
  provider = aws.us_east
  ami = "ami-020cba7c55df1f615"
  instance_type = var.instance_type
  key_name = aws_key_pair.us_east_key.key_name
  subnet_id = aws_subnet.us_east_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.us_east_sg.id]
  tags = {
    Name = "artillery-shell-${count.index}"
  }
}

# =============================
# eu-west-1 Resources - Artillery Frontline EU
# =============================

resource "aws_vpc" "eu_west_vpc" {
  provider = aws.eu_west
  cidr_block = "18.2.0.0/16"
  tags = { Name = "Artillery-Frontline-EU" }
}

resource "aws_subnet" "eu_west_subnet" {
  provider = aws.eu_west
  vpc_id = aws_vpc.eu_west_vpc.id
  cidr_block = "18.2.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_internet_gateway" "eu_west_igw" {
  provider = aws.eu_west
  vpc_id = aws_vpc.eu_west_vpc.id
}

resource "aws_route_table" "eu_west_rt" {
  provider = aws.eu_west
  vpc_id = aws_vpc.eu_west_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eu_west_igw.id
  }
}

resource "aws_route_table_association" "eu_west_rta" {
  provider = aws.eu_west
  subnet_id = aws_subnet.eu_west_subnet.id
  route_table_id = aws_route_table.eu_west_rt.id
}

resource "aws_security_group" "eu_west_sg" {
  provider = aws.eu_west
  name = "allow_ssh_http_eu"
  description = "Allow SSH and outbound HTTP traffic"
  vpc_id = aws_vpc.eu_west_vpc.id

  ingress {
    from_port = 2222
    to_port = 2222
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "eu_west_key" {
  provider   = aws.eu_west
  key_name   = "artillery-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "eu_west_artillery" {
  count = 4
  provider = aws.eu_west
  ami = "ami-01f23391a59163da9"
  instance_type = var.instance_type
  key_name = aws_key_pair.eu_west_key.key_name
  subnet_id = aws_subnet.eu_west_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.eu_west_sg.id]
  tags = {
    Name = "artillery-missile-${count.index}"
  }
}

# =============================
# ap-southeast-1 Resources - Artillery Pacific Strike
# =============================

resource "aws_vpc" "ap_southeast_vpc" {
  provider = aws.ap_southeast
  cidr_block = "18.3.0.0/16"
  tags = { Name = "Artillery-Pacific-Strike" }
}

resource "aws_subnet" "ap_southeast_subnet" {
  provider = aws.ap_southeast
  vpc_id = aws_vpc.ap_southeast_vpc.id
  cidr_block = "18.3.1.0/24"
  availability_zone = "ap-southeast-1a"
}

resource "aws_internet_gateway" "ap_southeast_igw" {
  provider = aws.ap_southeast
  vpc_id = aws_vpc.ap_southeast_vpc.id
}

resource "aws_route_table" "ap_southeast_rt" {
  provider = aws.ap_southeast
  vpc_id = aws_vpc.ap_southeast_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ap_southeast_igw.id
  }
}

resource "aws_route_table_association" "ap_southeast_rta" {
  provider = aws.ap_southeast
  subnet_id = aws_subnet.ap_southeast_subnet.id
  route_table_id = aws_route_table.ap_southeast_rt.id
}

resource "aws_security_group" "ap_southeast_sg" {
  provider = aws.ap_southeast
  name = "allow_ssh_http_ap"
  description = "Allow SSH and outbound HTTP traffic"
  vpc_id = aws_vpc.ap_southeast_vpc.id

  ingress {
    from_port = 2222
    to_port = 2222
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ap_southeast_key" {
  provider   = aws.ap_southeast
  key_name   = "artillery-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "ap_southeast_artillery" {
  count = 4
  provider = aws.ap_southeast
  ami = "ami-02c7683e4ca3ebf58"
  instance_type = var.instance_type
  key_name = aws_key_pair.ap_southeast_key.key_name
  subnet_id = aws_subnet.ap_southeast_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ap_southeast_sg.id]
  tags = {
    Name = "artillery-mortar-${count.index}"
  }
}

# =============================
# Outputs
# =============================

output "us_east_ips" {
  value = aws_instance.us_east_artillery[*].public_ip
}

output "eu_west_ips" {
  value = aws_instance.eu_west_artillery[*].public_ip
}

output "ap_southeast_ips" {
  value = aws_instance.ap_southeast_artillery[*].public_ip
}