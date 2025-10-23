// NOTE: Cross-security-group rules are intentionally omitted from the module
// to avoid creating dependency cycles when the module is consumed by other
// configurations. The module exports the security group IDs (see outputs)
// so callers can create rules referencing them. Example caller usage:

/*
resource "aws_security_group_rule" "cluster_from_nodes" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = module.vpc.eks_cluster_sg_id
  source_security_group_id = module.vpc.eks_nodes_sg_id
}

resource "aws_security_group_rule" "nodes_from_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.vpc.eks_nodes_sg_id
  source_security_group_id = module.vpc.eks_cluster_sg_id
}
*/
