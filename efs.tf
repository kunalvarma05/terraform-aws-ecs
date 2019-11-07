#------------------------------------------------------------------------------
# Create the EFS for ECS
#------------------------------------------------------------------------------
resource "aws_security_group" "ecs_efs_sg" {
  name        = "${var.ecs_cluster_name}-efs-sg"
  description = "Allows NFS Traffic for ${var.ecs_cluster_name}"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 2049
    protocol  = "tcp"
    to_port   = 2049
    self      = true
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = merge(
    {
      "Name" = "${var.ecs_cluster_name}-efs-sg"
    },
    var.tags
  )
}

resource "aws_efs_file_system" "ecs_efs" {
  creation_token = "${var.ecs_cluster_name}-efs"

  tags = merge(
    {
      "Name" = "${var.ecs_cluster_name}-efs"
    },
    var.tags
  )
}

resource "aws_efs_mount_target" "ecs_efs_mount_target" {
  count          = length(var.subnets) > 0 ? length(var.subnets) : 0
  file_system_id = aws_efs_file_system.ecs_efs.id
  subnet_id      = var.subnets[count.index]
  security_groups = [
    aws_security_group.ecs_efs_sg.id
  ]
}
