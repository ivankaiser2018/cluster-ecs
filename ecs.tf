#
# ECS ami
#


/* data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS
} */
 



# get latest active revision
#
data "aws_ecs_task_definition" "ecs-service-task" {
  task_definition = aws_ecs_task_definition.metabase-task.family
  depends_on      = [aws_ecs_task_definition.metabase-task]
}


#Criação do Cluster do Metabase

resource "aws_ecs_cluster" "ecs_cluster" {
    name  = var.CLUSTER_NAME
} 





# Regras de segurança para o Metabase
resource "aws_security_group" "sg-metabase" {
  name_prefix = "metabase"
  vpc_id      = var.VPC_ID
   ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
      } 
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }


      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

}


# EC2 Auto Scaling Group

resource "aws_launch_configuration" "launch_config" {
  name_prefix = "metabase-launch"
  //image_id    = data.aws_ami.ecs.id
  image_id= var.IMAGE_ID
  instance_type = var.INSTANCE_TYPE
  key_name    = var.SSH_KEY_NAME
  iam_instance_profile = aws_iam_instance_profile.cluster-ec2-role.id
  security_groups = [aws_security_group.sg-metabase.id]
  user_data = <<-EOF
              sudo yum install -y ecs-init
              sudo service docker start
              sudo service ecs start
              sudo newgrp docker
              sudo usermod -aG docker $USER
              sudo systemctl restart docker
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
             
              EOF

  lifecycle {
    create_before_destroy = true
  }

}




resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "metabase-asg"
  max_size                  = 3
  min_size                  = 1
  launch_configuration      = aws_launch_configuration.launch_config.id
  vpc_zone_identifier       = [var.subnet-pub-one, var.subnet-pub-two]
  target_group_arns         = [aws_alb_target_group.target-lb-metabase.arn]

  tag {
        key  = "Name"
        value = "${var.CLUSTER_NAME}-ecs"
        propagate_at_launch = true
    }

} 



# ECS SERVICE





#
# task definition
#



# Definição da tarefa do Metabase
resource "aws_ecs_task_definition" "metabase-task" {
  family                   = "metabase"
 // task_role_arn      = aws_iam_role.task_role.arn 
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  //network_mode             = "bridge"
  container_definitions = jsonencode([
    {
      "cpu": 512,
      "memory": 512,
      "name": "metabase",
      "image": "metabase/metabase",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "MB_DB_TYPE",
          "value": "postgres"
        },
        {
          "name": "MB_DB_PORT",
          "value": "${var.DB_PORT}"
        },
        {
          "name": "MB_DB_DBNAME",
          "value": "${var.DB_NAME}"
        },
        {
          "name": "MB_DB_USER",
          "value": "${var.DB_USERNAME}"
        },
        {
          "name": "MB_DB_PASS",
          "value": "${var.DB_PASSWORD}"
        },
        {
          "name": "MB_DB_HOST",
          "value": "${replace(aws_db_instance.rds_instance.endpoint,":9856","")}"
        }
      ]
    }
  ])

  }




#
# ecs service
#

resource "aws_ecs_service" "ecs-service" {
  name    = "nginx-container"
  cluster = aws_ecs_cluster.ecs_cluster.id
 // launch_type     = "EC2"
  task_definition = "${aws_ecs_task_definition.metabase-task.family}:${max(
  aws_ecs_task_definition.metabase-task.revision,
  data.aws_ecs_task_definition.ecs-service-task.revision,
  )}"
  iam_role  = aws_iam_role.cluster-service-role.id
 /*   deployment_controller {
    type = "EXTERNAL"
  }  
 */
   load_balancer {
    target_group_arn = aws_alb_target_group.target-lb-metabase.id
    container_name   = "metabase"
    container_port   = 3000
  }

 
/*  network_configuration {
    security_groups = [aws_security_group.sg-metabase.id]
    subnets = var.VPC_SUBNETS_ALB
    assign_public_ip = true
  }  */

  depends_on = [null_resource.alb_exists]
}

resource "null_resource" "alb_exists" {
  triggers = {
    alb_name = var.ALB_ARN
  }
}