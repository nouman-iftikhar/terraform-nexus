resource "aws_efs_file_system" "efs" {
  creation_token = var.efs.name

  tags = var.shared_tags
}

resource "aws_efs_mount_target" "one" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.subnet_id_1
  security_groups = [aws_security_group.this.id]
}

resource "aws_efs_mount_target" "two" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.subnet_id_2
  security_groups = [aws_security_group.this.id]
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.efs.id
}

resource "aws_security_group" "this" {

  name        = "${var.efs.name}-sg"
  vpc_id                 = var.vpc_id

  tags = var.shared_tags
}

resource "aws_security_group_rule" "this" {

  security_group_id = aws_security_group.this.id

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
}
