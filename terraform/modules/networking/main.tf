# Networking Module for Huawei Cloud

# VPC Resource
resource "huaweicloud_vpc" "vpc" {
  name        = var.vpc_name
  cidr        = var.vpc_cidr
  description = var.vpc_description
  tags        = var.tags
}

# Subnets
resource "huaweicloud_vpc_subnet" "subnets" {
  for_each = var.subnets

  name        = each.key
  cidr        = each.value.cidr
  gateway_ip  = each.value.gateway_ip
  vpc_id      = huaweicloud_vpc.vpc.id
  description = lookup(each.value, "description", null)
  
  # Optional: DNS configuration
  primary_dns   = lookup(each.value, "primary_dns", var.primary_dns)
  secondary_dns = lookup(each.value, "secondary_dns", var.secondary_dns)
  
  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Security Groups
resource "huaweicloud_networking_secgroup" "security_groups" {
  for_each = var.security_groups

  name        = each.key
  description = lookup(each.value, "description", null)
  
  # Delete associated resources when deleting the security group
  delete_default_rules = lookup(each.value, "delete_default_rules", false)
  
  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Security Group Rules
resource "huaweicloud_networking_secgroup_rule" "security_group_rules" {
  for_each = var.security_group_rules

  security_group_id = huaweicloud_networking_secgroup.security_groups[each.value.security_group_name].id
  direction         = each.value.direction
  ethertype         = lookup(each.value, "ethertype", "IPv4")
  protocol          = lookup(each.value, "protocol", null)
  port_range_min    = lookup(each.value, "port_range_min", null)
  port_range_max    = lookup(each.value, "port_range_max", null)
  remote_ip_prefix  = lookup(each.value, "remote_ip_prefix", null)
  description       = lookup(each.value, "description", null)
}

# NAT Gateway (Optional)
resource "huaweicloud_nat_gateway" "nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  name        = var.nat_gateway_name
  description = var.nat_gateway_description
  spec        = var.nat_gateway_spec
  vpc_id      = huaweicloud_vpc.vpc.id
  subnet_id   = values(huaweicloud_vpc_subnet.subnets)[0].id  # Using the first subnet by default
  
  tags = var.tags
}

# Elastic IP for NAT Gateway (Optional)
resource "huaweicloud_vpc_eip" "nat_eip" {
  count = var.create_nat_gateway ? 1 : 0

  publicip {
    type = "5_bgp"
  }
  
  bandwidth {
    name        = "${var.nat_gateway_name}-bandwidth"
    size        = var.nat_gateway_bandwidth_size
    share_type  = "PER"
    charge_mode = "traffic"
  }
  
  tags = var.tags
}

# Associate EIP with NAT Gateway (Optional)
resource "huaweicloud_nat_snat_rule" "snat_rule" {
  count = var.create_nat_gateway ? 1 : 0

  nat_gateway_id = huaweicloud_nat_gateway.nat_gateway[0].id
  floating_ip_id = huaweicloud_vpc_eip.nat_eip[0].id
  subnet_id      = values(huaweicloud_vpc_subnet.subnets)[0].id  # Using the first subnet by default
  
  # Optional: Source CIDR for SNAT rule
  source_cidr = var.nat_gateway_source_cidr != "" ? var.nat_gateway_source_cidr : values(huaweicloud_vpc_subnet.subnets)[0].cidr
}

# VPC Peering (Optional)
resource "huaweicloud_vpc_peering_connection" "peering" {
  for_each = var.vpc_peerings

  name        = each.key
  vpc_id      = huaweicloud_vpc.vpc.id
  peer_vpc_id = each.value.peer_vpc_id
  
  # Optional: If the peer VPC is in a different tenant
  peer_tenant_id = lookup(each.value, "peer_tenant_id", null)
}

# Routes for VPC Peering (Optional)
resource "huaweicloud_vpc_route" "peering_routes" {
  for_each = var.vpc_peerings

  vpc_id      = huaweicloud_vpc.vpc.id
  destination = each.value.peer_cidr
  type        = "peering"
  nexthop     = huaweicloud_vpc_peering_connection.peering[each.key].id
}
