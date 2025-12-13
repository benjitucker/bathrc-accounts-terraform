resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "TrainingSubmissions"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2 # We have a limited number of capacity units in the free tier
  write_capacity = 2
  hash_key       = "ID"
  #  range_key      = "Date"  # I.e. sort key

  attribute {
    name = "ID"
    type = "S"
  }

  tags = local.tags
}

# Resource to create the VPC Gateway Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb_vpce" {
  # Replace with the ID of your existing VPC
  vpc_id = module.vpc.vpc_id

  # The service name follows the format "com.amazonaws.<region>.dynamodb"
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  # Specify the endpoint type as "Gateway"
  vpc_endpoint_type = "Gateway"

  # List of IDs for the private route tables that need access to DynamoDB
  # The endpoint automatically adds a route to these tables
  route_table_ids = [
    module.vpc.private_route_table_ids,
    #    aws_route_table.private_subnet_1_rt.id,
    #    aws_route_table.private_subnet_2_rt.id,
    # Add other private route table IDs as needed
  ]

  tags = local.tags
}
