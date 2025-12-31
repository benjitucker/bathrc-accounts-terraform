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

  # GSI attributes, allowing queries that return the submissions after a date
  attribute {
    name = "submissionState"
    type = "S"
  }

  attribute {
    name = "trainingDate"
    type = "S"
  }

  global_secondary_index {
    name            = "StateDateIndex"
    hash_key        = "submissionState"
    range_key       = "trainingDate"
    projection_type = "ALL"

    // A GSI consumes units from our free allowance
    read_capacity  = 2
    write_capacity = 2
  }

  tags = local.tags
}

resource "aws_dynamodb_table" "transactions-dynamodb-table" {
  name           = "Transactions"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2 # We have a limited number of capacity units in the free tier
  write_capacity = 2
  hash_key       = "ID"
  #  range_key      = "Date"  # I.e. sort key

  attribute {
    name = "ID"
    type = "S"
  }

  # GSI attributes, allowing queries that return the transactions after a date
  attribute {
    name = "txnType"
    type = "S"
  }

  attribute {
    name = "txnDate"
    type = "S"
  }

  global_secondary_index {
    name            = "TypeDateIndex"
    hash_key        = "txnType"
    range_key       = "txnDate"
    projection_type = "ALL"

    // A GSI consumes units from our free allowance
    read_capacity  = 2
    write_capacity = 2
  }

  tags = local.tags
}

resource "aws_dynamodb_table" "members-dynamodb-table" {
  name           = "Members"
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
  route_table_ids = module.vpc.private_route_table_ids

  tags = local.tags
}
