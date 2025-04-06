# Creating Infrastructure with Terraform using NAT Gateway

## Project Description

This project demonstrates how to provision a complete AWS infrastructure using Terraform for deploying a WordPress website connected to a MySQL database.

The setup follows a real-world architecture:

- WordPress is deployed inside a Docker container on an EC2 instance in a Public Subnet.
- MySQL is deployed inside a Docker container on an EC2 instance in a Private Subnet .
- Both instances reside inside a custom VPC with proper security group configurations.
- Bastion Host (WordPress EC2) is used to SSH into the MySQL EC2 instance.

This project aims to showcase Infrastructure as Code (IaC) using Terraform in a secure and production-ready environment.

### Task: Infrastructure as Code using Terraform
 Objective:
Write an Infrastructure as Code (IaC) using Terraform to automate the creation of a complete environment in AWS.
Requirements:
1. Create a VPC
    - Use Terraform to create a Virtual Private Cloud (VPC).
2. Create 2 Subnets inside the VPC:
    - Public Subnet - This subnet should be accessible from the public internet.
    -  Private Subnet - This subnet should be restricted from public access (NAT gateway providing internet access)
3. Create an Internet Gateway
   - Create a public-facing Internet Gateway (IGW) to allow internet access.
   - Attach this IGW to the VPC.
4. Create a Route Table
    - Create a route table for the Internet Gateway.
    - Configure it to allow traffic from the public subnet to the internet.
    - Associate this route table with the Public Subnet.
5. Create a NAT gateway
    - Create a route table for the NAT Gateway.
    - Configure it to allow traffic from the private subnet to the internet.
    - Associate this route table with the Private Subnet.
6. Launch EC2 Instance with WordPress
    - Deploy an EC2 instance in the Public Subnet.
    - Pre-configure the instance with WordPress setup.
    - Create a Security Group allowing inbound traffic on port `80` (HTTP) so that clients can access the WordPress site.
7. Launch EC2 Instance with MySQL
    - Deploy an EC2 instance in the Private Subnet.
    - Create a Security Group allowing inbound traffic on port `3306` (MySQL) only from the WordPress instance.
    - This instance should not be accessible from the public internet.
 Note:
    - The WordPress EC2 instance is deployed in the Public Subnet so that clients from the internet can access the WordPress site.
    - The MySQL EC2 instance is deployed in the Private Subnet to ensure security — only the WordPress instance should be able to connect to the MySQL database (no public access).

## Solution
Terraform Code : 

Provider :
Provider needs to be mention which is aws along with region and profile.
![image](https://github.com/user-attachments/assets/744d3360-256b-4994-b5a9-7ba0dcc801db)

VPC :
VPC is created with IP range to provide to subnet.

![image](https://github.com/user-attachments/assets/0a72ba14-9adf-43a2-9df0-5e38d4d374f7)

![image](https://github.com/user-attachments/assets/c00fb275-05fa-456b-9a6e-8846c4ec33ce)


Public Subnet:
Create a public subnet in the above created VPC, in the availability zone us-east-1a to launch the Wordpress. Also enable the auto public ip assign so that client can access the site. Assign IP address range.

![image](https://github.com/user-attachments/assets/c1a1c69d-0915-4543-a7c1-16321b058277)


Private Subnet:
Creating a private subnet in the same VPC to launch the MYSQL in it so that is is secure and cannot be access by the outside. IP range is provided. It is launched in ap-south-1b zone.

![image](https://github.com/user-attachments/assets/589a2ff6-f726-4cc8-97fe-0745dae83a7a)
![image](https://github.com/user-attachments/assets/660f6b6e-c572-4912-91d4-0f21e4d49a1a)

Internet Gateway:
Creating an internet gateway so that our public subnet can connect to outside world and client can access the instance.

![image](https://github.com/user-attachments/assets/866a4fcb-2562-4f5d-83e3-340ae7a13d7e)

![image](https://github.com/user-attachments/assets/630de82d-9a9f-4258-83b4-3e432531dc94)

Route Tables:
Public Subnet : A route table contains a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed. Also we have to associate the route table to our public subnet so that it can know where is the internet gateway to connect to the outside world.

![image](https://github.com/user-attachments/assets/ab8b79ff-883f-499a-a326-48bb68329009)
![image](https://github.com/user-attachments/assets/4f6ea329-50ce-42a7-a496-e20ec6dbae2f)


Elastic IP : Attaching Elastic IP for the NAT Gatway

![image](https://github.com/user-attachments/assets/939e0447-5fc3-4c0e-a42f-1f8ab1c18805)

![image](https://github.com/user-attachments/assets/3ffa7c87-fc2c-45c2-8cbe-88762e6b408f)

NAT Gateway : NAT Gateway is highly available AWS managed service that makes it easy to connect to the internet from instances in the private subnet in a VPC. MySQL instance can now access internet from private subnet.

![image](https://github.com/user-attachments/assets/002fff7d-31fa-428c-a3f3-d2566d8c5a73)
![image](https://github.com/user-attachments/assets/34f7ac73-672f-4005-afc4-52e16ce160bb)

Route Tables:
Private Subnet : A route table contains a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed. Also we have to associate the route table to our private subnet so that it can know where is the NAT gateway to connect to the outside world.

![image](https://github.com/user-attachments/assets/f707b3ec-3ed6-4b18-8fb8-a6be253954ac)
![image](https://github.com/user-attachments/assets/4f6ea329-50ce-42a7-a496-e20ec6dbae2f)

Mysql Instance:
Launching an instance in the private subnet for the MYSQL using docker. For this first we have to create a security group which allows port number 3306 because MYSQL runs on port number 3306. Next I launch an instance in the private subnet and above created security group. At last I launch MYSQL container inside the instance.
Security Group:

![image](https://github.com/user-attachments/assets/6d5e62cf-5cb3-4c2d-b294-6fdbf371599e)
![image](https://github.com/user-attachments/assets/a09fcdf8-66f3-416e-a43f-c0eff78e90b2)
![image](https://github.com/user-attachments/assets/7d4652d0-4afa-49d4-8c6e-de908efdcea8)


Wordpress Instance:
Launching another instance in the public subnet for the WordPress. But again for this we have first create a security group which allows port 80 since WordPress runs on port 80. Then I launch EC2 instance using my AMI inside which I launch docker container for the WordPress.

Security Group:

![image](https://github.com/user-attachments/assets/91d77a74-82b0-4b43-b01b-b0d4ce0bd0ce)

![image](https://github.com/user-attachments/assets/ef2d2ee0-b891-450b-b167-ebd6405792a3)


![image](https://github.com/user-attachments/assets/e8deec85-4c17-4072-9fee-4db8f957f64f)


So now you can access the WordPress using the public IP of the of the Wordpress instance, which stores all its data in the MYSQL which is running in the private subnet so that your data is secure.

![image](https://github.com/user-attachments/assets/22f74d7d-075f-4fda-b7c0-d6b4b16cab27)

![image](https://github.com/user-attachments/assets/f0a25195-75f8-4664-9ab5-f5d9c59946eb)

![image](https://github.com/user-attachments/assets/bc513635-4a1d-4f47-9fb3-823ce9259311)

![image](https://github.com/user-attachments/assets/46d418a1-0d39-4ce0-8e2d-131c07b2901b)






---

