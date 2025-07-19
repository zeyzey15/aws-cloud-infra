variable "region" {
  type = string

}

variable "alias" {
  type = string
}

variable "db_password" {
  type = string 
  description = "saved in terraform cloud encrypted" 
  
}

variable "create_db" {
  type = bool
  }