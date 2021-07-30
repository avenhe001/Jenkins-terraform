# VPC Clarify
module "vpc" {

  source = "terraform-aws-modules/vpc/aws"


  name = var.vpc_name

  cidr = "10.10.0.0/16"

  # Two AZs
  azs = ["ap-southeast-1a", "ap-southeast-1b"]
  # Two public subnets IN EACH AZ
  public_subnets = ["10.10.0.0/24", "10.10.10.0/24"]
  # Two private subnets IN EACH AZ
  private_subnets = ["10.10.1.0/24", "10.10.11.0/24"]
# Two database subnets IN EACH AZ
  database_subnets = ["10.10.2.0/24", "10.10.12.0/24"]

  create_database_subnet_group = true

  enable_dns_hostnames = true

  enable_dns_support = true

}

# WEB SG Clarify
# Inbound Rules 80 443 22
module "websg" {

  source = "terraform-aws-modules/security-group/aws"

  name = "web-service"

  description = "Security group for HTTP and SSH within VPC"

  vpc_id = module.vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp", "ssh-tcp", "all-icmp"]

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_ipv6_cidr_blocks = []

  egress_rules = ["all-all"]

  egress_cidr_blocks = ["0.0.0.0/0"]

  egress_ipv6_cidr_blocks = []

}

# APP SG Clarify
# Inbound Rules WEB
module "appsg" {

  source = "terraform-aws-modules/security-group/aws"

  name = "app-service"

  description = "Security group for App within VPC"

  vpc_id = module.vpc.vpc_id


  ingress_ipv6_cidr_blocks = []

  egress_ipv6_cidr_blocks = []


  ingress_with_source_security_group_id = [

    {

      rule = "all-all"

      source_security_group_id = "${module.websg.security_group_id}"

    },

  ]


  egress_with_source_security_group_id = [

    {

      rule = "all-all"

      source_security_group_id = "${module.websg.security_group_id}"

    },

  ]

}

# DB SG Clarify
# Inbound Rules APP
module "dbssg" {

  source = "terraform-aws-modules/security-group/aws"

  name = "dbs-service"

  description = "Security group for Database within VPC"

  vpc_id = module.vpc.vpc_id


  ingress_ipv6_cidr_blocks = []

  egress_ipv6_cidr_blocks = []


  ingress_with_source_security_group_id = [

    {

      rule = "all-all"

      source_security_group_id = "${module.appsg.security_group_id}"

    },

  ]

  egress_with_source_security_group_id = [

    {

      rule = "all-all"

      source_security_group_id = "${module.appsg.security_group_id}"

    },

  ]

}

# EC2 in WEB 1a Clarify
module "ec2_web_1a" {

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "web_1a"

  instance_count = 1

  ami = var.inst_ami

  instance_type = var.inst_type

  key_name = var.aws_key_pair

  monitoring = true

  vpc_security_group_ids = ["${module.websg.security_group_id}"]

  subnet_id = module.vpc.public_subnets[0]

  associate_public_ip_address = true


  tags = {

    Terraform = "true"

  }

}

# EC2 in WEB 1b Clarify
module "ec2_web_1b" {

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "web_1b"

  instance_count = 1

  ami = var.inst_ami

  instance_type = var.inst_type

  key_name = var.aws_key_pair

  monitoring = true

  vpc_security_group_ids = ["${module.websg.security_group_id}"]

  subnet_id = module.vpc.public_subnets[1]

  associate_public_ip_address = true


  tags = {

    Terraform = "true"

  }

}

# EC2 in AOO 1a Clarify
module "ec2_app_1a" {

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "app_1a"

  instance_count = 2

  ami = var.inst_ami

  instance_type = var.inst_type

  key_name = var.aws_key_pair

  monitoring = true

  vpc_security_group_ids = ["${module.appsg.security_group_id}"]

  subnet_id = module.vpc.private_subnets[0]

  associate_public_ip_address = false


  tags = {

    Terraform = "true"

  }

}

# EC2 in AOO 1b Clarify
module "ec2_app_1b" {

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "app_1b"

  instance_count = 2

  ami = var.inst_ami

  instance_type = var.inst_type

  key_name = var.aws_key_pair

  monitoring = true

  vpc_security_group_ids = ["${module.appsg.security_group_id}"]

  subnet_id = module.vpc.private_subnets[1]

  associate_public_ip_address = false

  tags = {

    Terraform = "true"

  }

}
