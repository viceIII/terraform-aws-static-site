resource "aws_iam_policy" "cloudfront-policy" {
  name = "cloudfront-${var.site_domain}-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:ListDistributions"
      ],
      "Resource": "arn:aws:cloudfront:::*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig"
      ],
      "Resource": "${aws_cloudfront_distribution.website_cdn.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:ListCloudFrontOriginAccessIdentities",
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Resource": "${aws_cloudfront_distribution.website_cdn.arn}/*"
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
  http_version = "http1.1"

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.bucket.id}"
    domain_name = "${aws_s3_bucket.bucket.bucket_domain_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    # custom_header {
    #   name  = "User-Agent"
    #   value = "${var.duplicate_content_penalty_secret}"
    # }
  }

  default_root_object = "index.html"

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "200"
    response_page_path    = "${var.not_found_response_path}"
  }

  "default_cache_behavior" {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    "forwarded_values" {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl          = "0"
    default_ttl      = "300"                                      //3600
    max_ttl          = "1200"                                     //86400
    target_origin_id = "origin-bucket-${aws_s3_bucket.bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
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
