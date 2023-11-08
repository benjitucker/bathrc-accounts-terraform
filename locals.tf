locals {
  vpc_id = module.virtual-network.vpc_id
  //  route_table_id  = module.virtual-network.route_table_id
  virtual_network = module.virtual-network

  private_subnet = local.virtual_network.private_subnet[*]
}
