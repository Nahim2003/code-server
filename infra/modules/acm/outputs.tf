output "certificate_arn" {
  value = aws_acm_certificate_validation.ecs_codeserver.certificate_arn
}