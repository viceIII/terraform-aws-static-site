resource "aws_iam_policy" "bucket-policy" {
  name = "bucket-${var.bucket_name}-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "${aws_s3_bucket.bucket.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:PutObjectAcl",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": "${aws_s3_bucket.bucket.arn}/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.bucket_name} access identity"
}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/templates/bucket_policy.tpl")}"

  vars {
    iam_arn     = "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_iam_user_policy_attachment" "bucket-policy-attach" {
  user = "${var.ci_user}"

  policy_arn = "${aws_iam_policy.bucket-policy.arn}"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}"
  acl           = "${var.bucket_acl}"
  force_destroy = true
  policy        = "${data.template_file.bucket_policy.rendered}"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags {
    Name = "${var.site_domain}"
  }

  cors_rule = "${var.cors_rule}"
}
