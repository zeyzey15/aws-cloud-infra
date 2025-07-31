resource "aws_dynamodb_table" "CustomerOrders" {
    name             = "CustomerOrders"
    hash_key         = "OrderId"
    range_key        = "CustomerId"
    billing_mode     = "PAY_PER_REQUEST" 
  

   attribute {
    name = "OrderId"
    type = "S"
  }

   attribute {
    name = "CustomerId"
    type = "S"
  }
}


resource "aws_dynamodb_table_item" "ecustomer" {
    hash_key = "OrderId"
    item = <<ITEM
{
  "exampleHashKey": {"S": "something"},
  "OrderId": {"S": "ORD12345"},
  "CustomerId": {"S": "CUST7890"},
  "OrderDate": {"S": "2025-07-27"},
  "Items": {"SS": ["Avocado Salad","Quinoa Bowl"]} 
}
ITEM

table_name = aws_dynamodb_table.CustomerOrders.id

 } 

