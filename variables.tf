variable "ALB_NAME" {
  type = string
  default = "alb-ecs"

}
variable "ALB_TYPE" {
  type = string
  default = "application"

}

variable "VPC_ID" {
  type = string
  default = "vpc-03175fe3d5f18a2eb"

}

variable "VPC_SUBNETS_ALB" {
  type = list(string)
    default = ["subnet-0197a82d708f4bf9e",
    "subnet-0951b1493dbbc7a71",
    "subnet-0c54f3cb4275567a0",
    "subnet-02143f1f7b80feba6"  
  ]
}


variable "subnet-pub-one" {
  type = string
  default = "subnet-0197a82d708f4bf9e"
}


variable "subnet-pub-two" {
  type = string
  default = "subnet-0951b1493dbbc7a71"
}

variable "subnet-pub-three" {
  type = string
  default = "subnet-0c54f3cb4275567a0"
}

variable "subnet-pub-four" {
  type = string
  default = "subnet-02143f1f7b80feba6"
}


variable "ECS_SG" {
  default = ""
}

variable "ALB_ARN" {
  default = ""
 
}

variable "IMAGE_ID" {
  type = string
  default = "ami-06e46074ae430fba6"
}


variable "SSH_KEY_NAME" {
  type = string
  default = "key2023"
}

variable "INSTANCE_TYPE" {
  type = string
  default = "t2.micro"
}



variable "CLUSTER_NAME" {
  type = string
  default = "metabase-launch"
}


