resource "aws_iam_policy" "cloudfront-policy" {
  name = "cloudfront-${var.site_domain}-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "cloudfront:ListDistributions",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:GetDistribution",
                "cloudfront:GetDistributionConfig"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:ListCloudFrontOriginAccessIdentities",
                "cloudfront:ListInvalidations",
                "cloudfront:GetInvalidation",
                "cloudfront:CreateInvalidation"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "cloudfront-policy-attach" {
  user       = "${var.ci_user}"
  policy_arn = "${aws_iam_policy.cloudfront-policy.arn}"
}

// Create a Cloudfront distribution for the static website
resource "aws_cloudfront_distribution" "website_cdn" {
  count = "${var.enable_cloudfront ? 1 : 0}"

  enabled = true

  price_class  = "PriceClass_200"
  http_version = "http2"

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.bucket.id}"
    domain_name = "${aws_s3_bucket.bucket.bucket_domain_name}"
  }

  default_root_object = "index.html"

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "${var.custom_error_response_code}"
    response_page_path    = "${var.not_found_response_path}"
  }

  default_cache_behavior {
    allowed_methods = ["${var.allowed_methods}"]
    cached_methods  = ["${var.cached_methods}"]

    "forwarded_values" {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl          = "${var.default_cache_behavior_min_ttl}"
    default_ttl      = "${var.default_cache_behavior_default_ttl}"
    max_ttl          = "${var.default_cache_behavior_max_ttl}"
    target_origin_id = "origin-bucket-${aws_s3_bucket.bucket.id}"

    // This redirects any HTTP request to HTTPS.
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    lambda_function_association = "${var.lambda_function_association}"
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  "viewer_certificate" {
    acm_certificate_arn = "${var.acm_certificate_arn}"

    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["${var.site_domain}", "www.${var.site_domain}", "${compact(var.aliases)}"]
}
