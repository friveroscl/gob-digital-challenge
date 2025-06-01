resource "local_file" "ssh_script" {
  filename        = "${path.module}/ssh-to-ec2-instance.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash

    if [ ! -f ec2_instance.pem ]; then

      aws secretsmanager get-secret-value \
        --secret-id ${var.prefix}-instance \
        --query SecretString \
        --output text \
        --region ${var.aws_region} | jq -r .private_key > ec2_instance.pem

      chmod 400 ec2_instance.pem

    fi

    ssh -i ec2_instance.pem ubuntu@${aws_instance.ec2_instance.public_ip}
  EOT
}
