## Prueba Técnica Encargado de Infraestructura TI

Este repositorio contiene el parte de la prueba técnica realizada para postular al cargo de Encargado de Infraestructura TI, en particular contiene el código fuente usado para levantar la infraestructura requerida (IaC, Terraform).

### Instrucciones

1. Configurar un par de credenciales de AWS que cuenten con los permisos adecuados. Por ejemplo, usando el archivo `~/.aws/credentials`.
2. Al levantar infraestructura con Terraform, se recomienda guardar el estado de ésta en algún tipo de almacenamiento centralizado y versionado, además de aplicar bloqueos para asegurar que solo exista un proceso modificando el estado de la misma. Para esto crearemos un bucket S3 y una tabla en DynamoDB:
  - El bucket, al estar versionado, nos permitirá guardar los estados de la infraestructura. Ejecutar:
  ```bash
  ./terraform/init/create_s3_bucket.sh gob-digital-terraform-state us-east-1
  ```