## Prueba Técnica Encargado de Infraestructura TI

Este repositorio contiene el parte de la prueba técnica realizada para postular al cargo de Encargado de Infraestructura TI, en particular contiene el código fuente usado para levantar la infraestructura requerida (IaC, Terraform).

> Para esta prueba técnica se implementó todo en la región `us-east-1` de AWS (N. Virginia). Se puede cambiar la región a cualquier otra, siguiendo las instrucciones que se indican.

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

4. Modificar el archivo `/terraform/variables.tf` según nuestras necesidades, incluyendo el CIDR para la VPC y la misma región de AWS de los pasos anteriores (o usar un archivo `.tfvars`).
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

5. Ejecutar `terraform init` -dentro del directorio `terraform`- para inicializar el backend y descargar las dependencias del proyecto.
    ```
    terraform init
    ```

6. Ejecutar `terraform plan` para revisar los cambios que se efectuarán en la infraestructura.

7. Ejecutar `terraform apply` para aplicar los cambios a la infraestructura.

&nbsp;

### Explicación

- **VPC**: 