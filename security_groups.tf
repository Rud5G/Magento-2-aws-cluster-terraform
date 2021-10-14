


////////////////////////////////////////////////////////[ SECURITY GROUPS ]///////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for ALB
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "alb" {
  name        = "${var.app["brand"]}-alb-sg"
  description = "Security group rules for ${var.app["brand"]} ALB"
  vpc_id      = aws_vpc.this.id

  ingress = [
    {
      description      = "Allow all inbound traffic on the load balancer https listener port"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]
  
  ingress = [
    {
      description      = "Allow all inbound traffic on the load balancer http listener port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] 
    }
  ]

  egress = [
    {
      description      = "Allow outbound traffic to instances on the load balancer listener port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
	  security_groups  = aws_security_group.ec2.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-alb-sg"
  }
}

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for EC2
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "ec2" {
  name        = "${var.app["brand"]}-ec2-sg"
  description = "Security group rules for ${var.app["brand"]} EC2"
  vpc_id      = aws_vpc.this.id
  
  ingress = [
    {
      description      = "Allow inbound traffic from ALB on the instance http port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = aws_security_group.ec2.id
    }
  ]
  
  ingress = [
    {
      description      = "Allow inbound traffic from EC2 on the instance http port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = aws_security_group.alb.id
    }
  ]
  
  egress = [
    {
      description      = "Allow outbound traffic on the instance http port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.this.cidr_block]
    }
  ]
  
  egress = [
    {
      description      = "Allow outbound traffic on the instance https port"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]
  
  egress = [
    {
      description      = "Allow outbound traffic on the instance MySQL port"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      security_groups  = aws_security_group.rds.id
    }
  ]

  egress = [
    {
      description      = "Allow outbound traffic on the instance RabbitMQ port"
      from_port        = 5671
      to_port          = 5671
      protocol         = "tcp"
      security_groups  = aws_security_group.rabbitmq.id
    }
  ]

  egress = [
    {
      description      = "Allow outbound traffic on the instance Redis port"
      from_port        = 6379
      to_port          = 6379
      protocol         = "tcp"
      security_groups  = aws_security_group.redis.id
    }
  ]

  egress = [
    {
      description      = "Allow outbound traffic on the instance EFS port"
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      security_groups  = aws_security_group.efs.id
    }
  ]
  
  egress = [
    {
      description      = "Allow outbound traffic on the instance SES port"
      from_port        = 587
      to_port          = 587
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress = [
    {
      description      = "Allow outbound traffic on the instance ELK port"
      from_port        = 9200
      to_port          = 9200
      protocol         = "tcp"
      security_groups  = aws_security_group.elk.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-ec2-sg"
  }
}

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for RDS
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "rds" {
  name        = "${var.app["brand"]}-rds-sg"
  description = "Security group rules for ${var.app["brand"]} RDS"
  vpc_id      = aws_vpc.this.id

  ingress = [
    {
      description      = "Allow all inbound traffic to MySQL port from EC2"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      security_groups  = aws_security_group.ec2.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-rds-sg"
  }
}

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for ElastiCache
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "redis" {
  name        = "${var.app["brand"]}-redis-sg"
  description = "Security group rules for ${var.app["brand"]} ElastiCache"
  vpc_id      = aws_vpc.this.id

  ingress = [
    {
      description      = "Allow all inbound traffic to Redis port from EC2"
      from_port        = 6379
      to_port          = 6379
      protocol         = "tcp"
      security_groups  = aws_security_group.ec2.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-redis-sg"
  }
}

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for RabbitMQ
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "rabbitmq" {
  name        = "${var.app["brand"]}-rabbitmq-sg"
  description = "Security group rules for ${var.app["brand"]} RabbitMQ"
  vpc_id      = aws_vpc.this.id

  ingress = [
    {
      description      = "Allow all inbound traffic to RabbitMQ port from EC2"
      from_port        = 5671
      to_port          = 5671
      protocol         = "tcp"
      security_groups  = aws_security_group.ec2.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-rabbitmq-sg"
  }
}

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for EFS
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "efs" {
  name        = "${var.app["brand"]}-efs-sg"
  description = "Security group rules for ${var.app["brand"]} EFS"
  vpc_id      = aws_vpc.this.id

  ingress = [
    {
      description      = "Allow all inbound traffic to EFS port from EC2"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = aws_security_group.ec2.id
    }
  ]
  
  egress = [
    {
      description      = "Allow all outbound traffic to EC2 port from EFS"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = aws_security_group.ec2.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-efs-sg"
  }
}

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security grou and rules for ELK
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "elk" {
  name        = "${var.app["brand"]}-elk-sg"
  description = "Security group rules for ${var.app["brand"]} ELK"
  vpc_id      = aws_vpc.this.id

  ingress = [
    {
      description      = "Allow all inbound traffic to ELK port from EC2"
      from_port        = 9200
      to_port          = 9200
      protocol         = "tcp"
      security_groups  = aws_security_group.ec2.id
    }
  ]
  
  egress = [
    {
      description      = "Allow all outbound traffic to EC2 port from ELK"
      from_port        = 9200
      to_port          = 9200
      protocol         = "tcp"
      security_groups  = aws_security_group.ec2.id
    }
  ]

  tags = {
    Name = "${var.app["brand"]}-elk-sg"
  }
}
