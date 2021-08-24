module "core" {
  source = "../modules/core"

  ip_to_bastion = var.ip_to_bastion
}

module "cluster" {
  source = "../modules/cluster"

  vpc_id = module.core.vpc_id

  public_id = module.core.public_id

  private_subnet_id = module.core.private_subnet_id

  sg_cluster_id = module.core.sg_cluster_id
  sg_alb_id     = module.core.sg_alb_id
}
