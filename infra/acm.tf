data "aws_route53_zone" "selected" {
  name         = "nahim-dev.com"
  private_zone = false
}

resource "aws_acm_certificate" "ecs-codeserver-cert" {
  domain_name       = "tm.nahim-dev.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ecs-codeserver-cert"
  }
}

resource "aws_acm_certificate_validation" "tm" {
  certificate_arn         = aws_acm_certificate.ecs-codeserver-cert.arn
  depends_on              = [aws_route53_record.cert_validation]
  validation_record_fqdns = [aws_route53_record.cert_validation["tm.nahim-dev.com"].fqdn]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ecs-codeserver-cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "ecs_codeserver" {
  certificate_arn = aws_acm_certificate.ecs-codeserver-cert.arn

  validation_record_fqdns = [
    for r in aws_route53_record.cert_validation : r.fqdn
  ]
}
