module "network" {
  source                 = "./network"
  cluster-name           = var.cluster-name
  az                     = data.aws_availability_zones.available
}


module "cluster" {
  source                 = "./cluster"
  awsprofile             = var.awsprofile
  awscredentials         = var.awscredentials
  cluster-name           = var.cluster-name
  cluster-version        = var.cluster-version
  aws-vpc-id             = module.network.vpc_id
  public-subnet-ids      = module.network.public_subnet_ids
  private-subnet-ids     = module.network.private_subnet_ids
  firewall-allow-source  = module.network.workstation_addr
  node-types             = var.node-types
  size-desired           = var.nodes-desired
  size-max               = var.nodes-max
  size-min               = var.nodes-min
  key-name               = var.ssh-key-name
  public-key             = var.ssh-public-key
  cluster-region         = data.aws_region.current.name
  enable-kubedashboard   = var.enable-kubedashboard
  enable-autoscaler      = var.enable-autoscaler
  enable-cloudwatch      = var.enable-cloudwatch
  cloudwatch-retention   = var.cloudwatch-retention
  enable-externaldns     = var.enable-externaldns
  externaldns-zone-id    = var.domain_id
  externaldns-zone-name  = var.domain
  enable-certmanager     = var.enable-certmanager
  enable-nginxingress    = var.enable-nginxingress
}
