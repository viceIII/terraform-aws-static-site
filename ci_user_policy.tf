resource "aws_iam_policy" "cloudfront-policy" {
  count = var.ci_user == "" ? 0 : 1
  name  = "cloudfront-${var.site_domain}-policy"

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

resource "aws_iam_user_policy_attachment" "bucket-policy-attach" {
  count      = var.ci_user == "" ? 0 : 1
  user       = var.ci_user
  policy_arn = aws_iam_policy.bucket-policy.arn
}

resource "aws_iam_user_policy_attachment" "cloudfront-policy-attach" {
  count      = var.ci_user == "" ? 0 : 1
  user       = var.ci_user
  policy_arn = aws_iam_policy.cloudfront-policy[0].arn
}

