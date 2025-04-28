
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_subnet" "public-sub" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id
  route{
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
}
resource "aws_route_table_association" "asso-1" {
  subnet_id = aws_subnet.public-sub.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_eip" "eip" {
  depends_on = [ aws_internet_gateway.igw ]
  vpc = true
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public-sub.id
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_subnet" "private-sub" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
}
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
}
resource "aws_route_table_association" "asso-2" {
  subnet_id = aws_subnet.private-sub.id
  route_table_id = aws_route_table.rt2.id
}
resource "aws_security_group" "sg-pub" {
  vpc_id = aws_vpc.vpc.id
  ingress{
    to_port = 80
    from_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress{
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "Wordpress" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-sub.id
  security_groups = [aws_security_group.sg-pub.id]
  associate_public_ip_address = true
  key_name = "first-project"
  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("/workspaces/Building-Infra-Using-NAT/first-project.pem")
  }
  provisioner "remote-exec" {
    inline = [
    "sudo apt update -y",
    "sudo apt install docker.io -y",
    "sudo systemctl start docker",
    "sudo systemctl enable docker",
    "sudo docker run -d --name wordpress-container -p 80:80 wordpress:latest"
    ]
  }
}
resource "aws_security_group" "sg-priv" {
  vpc_id = aws_vpc.vpc.id
  ingress{
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    to_port = 3306
    from_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "MySQL" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private-sub.id
  security_groups = [aws_security_group.sg-priv.id]
  key_name = "first-project"
  associate_public_ip_address = false
  connection {
    type = "ssh"
    user = "ubuntu"
    host =  self.private_ip
    private_key = file("/workspaces/Building-Infra-Using-NAT/first-project.pem")
    bastion_user = "ubuntu"
    bastion_host = aws_instance.Wordpress.public_ip
    bastion_host_key = file("/workspaces/Building-Infra-Using-NAT/first-project.pem")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      "sudo docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=password 3306:3306 mysql:5.7"
    ]
  }
}
