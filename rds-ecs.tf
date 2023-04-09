resource "aws_security_group" "rds_security_group" {
  name_prefix = "rds-"
  ingress {
    from_port   = var.DB_PORT
    to_port     = var.DB_PORT
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [var.subnet-pub-three,var.subnet-pub-four]
}




resource "aws_db_instance" "rds_instance" {
  identifier           = var.BD_IDENTIFIER
  allocated_storage    = 10
  engine               = var.ENGINE_DB
  engine_version       = var.ENGINE_VERSION
  instance_class       = var.INSTANCE_TYPE_RDS
  name                 = var.DB_NAME
  username             = var.DB_USERNAME
  password             = var.DB_PASSWORD
  parameter_group_name = var.BD_PARAMETER_GROUP_NAME
  port     = var.DB_PORT
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}