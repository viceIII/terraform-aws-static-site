variable "site_domain" {}
variable "ci_user" {}

variable "enable_cloudfront" {
  default = false
}

variable "acm_certificate_arn" {}

variable "cors_rule" {
  type    = "list"
  default = []
}

variable "default_cache_behavior_min_ttl" {
  default = 0
}

variable "default_cache_behavior_default_ttl" {
  default = 300
}

variable "default_cache_behavior_max_ttl" {
  default = 1200
}

variable "custom_error_response_code" {
  default = "404"
}

variable "lambda_function_association" {
  type    = "list"
  default = []
}

variable "allowed_methods" {
  type    = "list"
  default = ["GET", "HEAD"]
}

variable "cached_methods" {
  type    = "list"
  default = ["GET", "HEAD"]
}

variable "not_found_response_path" {
  default = "/index.html"
}

variable "aliases" {
  type    = "list"
  default = []
}
