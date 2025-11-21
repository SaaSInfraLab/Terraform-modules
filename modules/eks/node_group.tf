// Data source to fetch latest EKS optimized AMI
data "aws_ami" "eks_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }
}

// Launch template for EKS worker nodes
resource "aws_launch_template" "nodes" {
  name_prefix = "${var.cluster_name}-"
  description = "Launch template for ${var.cluster_name} EKS worker nodes"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      { Name = "${var.cluster_name}-node" }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      { Name = "${var.cluster_name}-volume" }
    )
  }

  # For managed node groups, AWS handles the bootstrap automatically
  # Custom user data can cause MIME format issues

  lifecycle {
    create_before_destroy = true
  }
}

// EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = local.node_group_name
  node_role_arn   = var.node_iam_role_arn
  subnet_ids      = var.private_subnet_ids
  version         = var.cluster_version

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  instance_types = var.node_instance_types

  tags = merge(
    var.tags,
    {
      Name = local.node_group_name
    }
  )

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_launch_template.nodes,
    aws_iam_instance_profile.nodes[0]
  ]
}

// Instance profile for nodes (created by IAM module, referenced here)
resource "aws_iam_instance_profile" "nodes" {
  count      = var.node_iam_role_arn != null ? 1 : 0
  name_prefix = "${var.cluster_name}-"
  role        = data.aws_iam_role.node_role[0].name

  depends_on = [
    data.aws_iam_role.node_role
  ]
}

// Data source to reference the node IAM role (passed in as ARN)
data "aws_iam_role" "node_role" {
  count = var.node_iam_role_arn != null ? 1 : 0
  name  = var.node_iam_role_arn != null ? split("/", var.node_iam_role_arn)[1] : null
}
