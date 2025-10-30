// Security Group Rule - Allow HTTPS to cluster API from allowed CIDRs
resource "aws_security_group_rule" "cluster_api_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = var.cluster_security_group_id
  description       = "Allow HTTPS to EKS API from allowed CIDRs"
}

// Security Group Rule - Allow nodes to communicate with cluster API
resource "aws_security_group_rule" "nodes_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.nodes_security_group_id
  security_group_id        = var.cluster_security_group_id
  description              = "Allow worker nodes to communicate with cluster API"
}

// Security Group Rule - Allow cluster to nodes (kubelet)
resource "aws_security_group_rule" "cluster_to_nodes_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = var.cluster_security_group_id
  security_group_id        = var.nodes_security_group_id
  description              = "Allow cluster to kubelet API on nodes"
}

// Security Group Rule - Allow pod-to-pod communication within nodes
resource "aws_security_group_rule" "pod_to_pod" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.nodes_security_group_id
  security_group_id        = var.nodes_security_group_id
  description              = "Allow pod-to-pod communication within nodes"
}

// Network ACL for additional security (optional, restrictive ingress)
resource "aws_network_acl" "eks_nacl" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-nacl" }
  )
}

// Network ACL Rule - Allow HTTPS
resource "aws_network_acl_rule" "https_ingress" {
  network_acl_id = aws_network_acl.eks_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

// Network ACL Rule - Allow Kubelet
resource "aws_network_acl_rule" "kubelet_ingress" {
  network_acl_id = aws_network_acl.eks_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 10250
  to_port        = 10250
}

// Network ACL Rule - Allow ephemeral ports
resource "aws_network_acl_rule" "ephemeral_ingress" {
  network_acl_id = aws_network_acl.eks_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

// Network ACL Rule - Allow all egress
resource "aws_network_acl_rule" "egress_all" {
  network_acl_id = aws_network_acl.eks_nacl.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 0
  to_port        = 0
}

// Security Group for private pod networking (optional Calico/Cilium)
resource "aws_security_group" "network_policy" {
  count       = var.enable_network_policy ? 1 : 0
  name_prefix = "${var.cluster_name}-network-policy-"
  description = "Security group for network policy enforcement"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-network-policy" }
  )
}
