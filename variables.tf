variable "site_domain" {
}

variable "bucket_name" {
}

variable "ci_user" {
  default = ""
}

variable "acm_certificate_arn" {
}

variable "bucket_acl" {
  default = "public-read"
}

variable "cors_rule" {
  type    = list(string)
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

variable "custom_not_found_response_code" {
  default = "404"
}

variable "custom_not_found_response_path" {
  default = "/404.html"
}

variable "custom_forbidden_response_code" {
  default = "403"
}

variable "custom_forbidden_response_path" {
  default = "/403.html"
}

variable "lambda_function_association" {
  type    = list(string)
  default = []
}

variable "forwarded_headers" {
  type    = list(string)
  default = []
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "viewer_protocol_policy" {
  default = "redirect-to-https"
}

