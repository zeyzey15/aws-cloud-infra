variable "region" {
  type = string

}

variable "alias" {
  type = string
}

variable "db_password" {
  type        = string
  description = "saved in terraform cloud encrypted"

}

variable "create_db" {
  type = bool
}

variable "subnets_public" {
  type = list(string)
}

variable "create_jumphost" {
  type = bool
}

variable "vpc_zey" {
  type = string
}

variable "sns_topic_name" {
  type        = string
  description = "Optional SNS topic name. If empty, a default name is used."
  default     = ""
}


variable "email" {
  type = string
}

