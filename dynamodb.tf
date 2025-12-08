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
