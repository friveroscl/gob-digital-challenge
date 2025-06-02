resource "aws_route53_zone" "zone" {
  name = "${var.prefix}.cl"
}