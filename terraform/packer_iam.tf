data "aws_iam_policy_document" "packer_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "packer_policy_doc" {
  statement {
    sid       = "instanceProfileAccess"
    effect    = "Allow"
    actions   = ["iam:GetInstanceProfile"]
    resources = ["arn:aws:iam::*:instance-profile/*"]
  }
  statement {
    sid       = "logAccess"
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:log-group:*"]
  }
  statement {
    sid       = "bucketAccess"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
  statement {
    sid       = "kmsAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ec2Actions"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ssmMessages"
    effect    = "Allow"
    actions   = ["ssmmessages:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy" "ssm_automation_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

data "aws_iam_policy_document" "packer_passrole_policy_doc" {
  statement {
    sid       = "passrolePolicy"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.packer_role.arn]
  }
}

resource "aws_iam_role" "packer_role" {
  name               = "packer_ssm_role"
  assume_role_policy = data.aws_iam_policy_document.packer_assume_policy.json
}

resource "aws_iam_instance_profile" "packer_profile" {
  name = "packer_instance_profile"
  role = aws_iam_role.packer_role.name
}

resource "aws_iam_policy" "packer_policy" {
  name   = "packer_policy"
  policy = data.aws_iam_policy_document.packer_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "managed_policy_attachment" {
  role       = aws_iam_role.packer_role.name
  policy_arn = data.aws_iam_policy.ssm_automation_policy.arn
}

resource "aws_iam_role_policy_attachment" "packer_policy_attachment" {
  role       = aws_iam_role.packer_role.name
  policy_arn = aws_iam_policy.packer_policy.arn
}

resource "aws_iam_policy" "packer_passrole_policy" {
  name   = "packer_passrole_policy"
  policy = data.aws_iam_policy_document.packer_passrole_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "packer_passrole_policy_attachment" {
  role       = aws_iam_role.packer_role.name
  policy_arn = aws_iam_policy.packer_passrole_policy.arn
}