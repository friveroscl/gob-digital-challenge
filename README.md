## Prueba Técnica Encargado de Infraestructura TI

Este repositorio contiene el parte de la prueba técnica realizada para postular al cargo de Encargado de Infraestructura TI, en particular contiene el código fuente usado para levantar la infraestructura requerida (IaC, Terraform).

### Instrucciones

1. Configurar un par de credenciales de AWS que cuenten con los permisos adecuados. Por ejemplo, usando el archivo `~/.aws/credentials`.

2. Al levantar infraestructura con Terraform, se recomienda guardar el estado de ésta en algún tipo de almacenamiento centralizado y versionado, además de aplicar bloqueos para asegurar que solo exista un proceso modificando el estado de la misma. Para esto crearemos un bucket S3 y una tabla en DynamoDB. Se adjuntan dos scripts sencillos.

  - El bucket, al estar versionado, permitirá guardar los estados de la infraestructura. Ejecutar:
    ```bash
    ./terraform/init/create_s3_bucket.sh <nombre del bucket> <region de aws>

    ./terraform/init/create_s3_bucket.sh gob-digital-terraform-state us-east-1
    ```

  - La tabla de DynamoDB servirá para aplicar bloqueos cuando la infraestructura se mofifica. Ejecutar:
    ```bash
    ./terraform/init/create_dynamo_table.sh <region de aws>

    ./terraform/init/create_dynamo_table.sh us-east-1
    ```

3. Modificar el archivo `/terraform/providers.tf` de acuerdo al bucket y región de AWS usados en el paso previo.
  ```
  backend "s3" {
    bucket         = "gob-digital-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
   ```

4. Modificar el archivo `/terraform/variables.tf` según nuestras necesidades de CIDR y región de AWS (o usar un archivo `.tfvars`).
  ```
  variable "aws_region" {
    type    = string
    default = "us-east-1"
  }

  variable "cidr_block" {
    type    = string
    default = "10.0.0.0/16"
  }
  ```