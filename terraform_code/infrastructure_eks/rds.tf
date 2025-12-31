resource "aws_db_subnet_group" "rds" {
  name       = "main-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "password123" # In production, use secrets manager or variables
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "MyRDSInstance"
  }
}
