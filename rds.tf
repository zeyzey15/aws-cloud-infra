resource "aws_db_instance" "default" {
  availability_zone     = "eu-west-1a"
  count                 = var.create_db ? 1 : 0
  allocated_storage     = 20
  db_name               = ""
  engine                = "mysql"
  engine_version        = "8.0.41"
  instance_class        = "db.t3.micro"
  username              = "admin"
  password              = var.db_password
  parameter_group_name  = "default.mysql8.0"
  copy_tags_to_snapshot = true
  publicly_accessible   = true
  skip_final_snapshot   = true
  storage_encrypted     = true
  apply_immediately     = true
  max_allocated_storage = 1000
  db_subnet_group_name  = aws_db_subnet_group.default.id
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnets_public

  tags = {
    Name = "My DB subnet group"
  }
}
