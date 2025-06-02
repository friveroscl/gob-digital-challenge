## Prueba Técnica Encargado de Infraestructura TI

Este repositorio contiene parte de la prueba técnica realizada para postular al cargo de Encargado de Infraestructura TI, en particular contiene el código fuente usado para levantar la infraestructura requerida (IaC, Terraform).

> Para esta prueba técnica se implementó todo en la región `us-east-1` de AWS (N. Virginia). Se puede cambiar la región a cualquier otra, siguiendo las instrucciones que se indican.

&nbsp;

### Parte 1. Desplegar / Instrucciones

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

6. Ejecutar `terraform plan` para revisar los cambios que se efectuarán en la infraestructura.

7. Ejecutar `terraform apply` para aplicar los cambios a la infraestructura.

&nbsp;

---

### Parte 2. Explicar

- **VPC**: Se implementa una VPC tradicional, con **3 subnets públicas** y **3 subnets privadas**, desplegadas en **3 zonas de disponibilidad** (a, b y c). Las subnets públicas comparten **1 Internet Gateway** -que es un recurso regional redundante y con alta disponibilidad- mientras que para las subnets privadas se implementa **1 NAT Gateway para cada una**. Al ser este último un recurso zonal, se recomienda tener uno por cada zona. Además, se crea una tabla de rutas para las subnets públicas y 3 tablas de rutas para las subnets privadas, donde cada una usa un NAT Gateway distinto.

- **EKS**: Se implementa **un clúster EKS en [modo auto](https://docs.aws.amazon.com/eks/latest/userguide/automode.html)**. Para efectos de la prueba se disponibiliza públicamente el endpoint de la API de Kubernetes, de lo contrario se necesitaría una instancia pivote o una VPN para acceder.

- **EC2**: Se despliega **una instancia EC2** según lo requerido. Se levanta en una red pública pero se restringe el acceso por SSH a la dirección IP del usuario creador de la infraestructura. Se ejecuta bajo un rol de IAM que le permite acceder al clúster de Kubernetes. La llave de acceso se guarda en Secrets Manager y se genera un script para conectarse de manera fácil a la instancia: `ssh-to-ec2-instance.sh`. También podemos conectarnos por AWS Systems Manager.

- **S3**: Se crea un bucket sin mayores pretensiones.

- **Route 53**: Se crea una zona pero no se crean registros adicionales.

---

## Parte 3: Evaluar

Objetivo: Evaluar capacidad crítica, experiencia práctica y visión de mejora. Encuentre el o los errores.

&nbsp;

*El SRE responsable de un producto, desplegó infraestructura en AWS usando scripts manuales no versionados. El entorno tiene Kubernetes (EKS), credenciales en texto plano, sin monitoreo centralizado, tiene autoscaling con un averageUtilization de 95, y actualizaciones manuales en pods en producción.*

**¿Qué errores técnicos identifica?**

  1. *Desplegar infraestructura usando scripts no versionados*: No es recomendable usar scripts para desplegar infraestructura -sino usar directamente herramientas de IaC como Terraform o Pulumi-, aunque podrían existir algunos contextos o casos en los cuales resulte más práctico usar scripts (por ejemplo, en la prueba técnica se usaron scripts para crear el bucket S3 y la tabla de DynamoDB). Al usar scripts no versionados podemos tener diferentes problemas como: falta de trazabilidad o de responsables (¿quién es dueño de los scripts o aprueba sus cambios?) y falta de consistencia en el estado de la infraestructura (¿cómo se modifica o actualiza la infraestructura creada con estos scripts?).

  2. *Credenciales en texto plano*: en EKS existen diferentes mecanismos para trabajar con credenciales u otra información considerada como secreto, cada uno con distinto nivel de seguridad. Desde algo básico como usar el recurso Secret de Kubernetes, hasta soluciones más complejas como gestores o bóvedas de secretos ([Vault](https://www.hashicorp.com/en/products/vault) / [AWS Secret Manager](https://aws.amazon.com/es/secrets-manager/)) que incluyan secretos temporales o con rotación. 

  3. *Sin monitoreo*: al no tener monitoreo, será imposible anticipar problemas (o generar avisos o alertas cuando algo salga de la norma) o aprender de los que se presenten o incluso saber cuáles son sus métricas normales de uso. 

  4. *AutoScaling al 95%*: el umbral de autoscaling es demasiado alto, por lo general se usan valores **entre 50% y 70%**, lo que permite tener un margen para manejar respuestas ante peaks inesperados. Al 95% -tanto en CPU como en memoria- es muy probable que el sistema ya esté degradado y esté mostrando errores, timeouts, cuellos de botella u otras señales. 

  5. *Actualizaciones manuales de pods*: no se deberían administrar los pods de manera manual en Kubernetes, existe riesgo de generar indisponibilidad al editar los manifiestos a mano, como también de perder su trazabilidad o de no poder realizar rollback.

&nbsp; 

**¿Cuál es el impacto de tener credenciales expuestas y qué solución propone?**

Una credencial expuesta puede ser obtenida por terceros y podría llegar a ser usada de forma inapropiada. Si sabemos que una credencial fue expuesta, se le debe negar el acceso lo más pronto que sea posible. Si es una contraseña se puede actualizar o resetear, si es una API key se debe generar una nueva, etc.

Hay distintas alternativas para manejar credenciales. Mi recomedación es NO usar credenciales cuando sea posible, por ejemplo: es posible ejecutar instancias EC2 bajo un rol de IAM, usando Instance Profile y también es posible ejecutar pods en Kubernetes bajo un rol de IAM, pero en este caso usando Pod Identity Agent. En ambos casos, lo que se busca es tener acceso a recursos cloud como RDS, S3, etc. sin llegar a usar credenciales o AWS Keys.

Para los casos en que lo anterior no sea factible, usar una bóveda o gestor de secretos, como Vault o AWS Secrets Manager permitirá que incluso se pueda configurar rotación de credenciales o establecer algún cifrado propio.

&nbsp;

**Considerando principios avanzados de infraestructura resiliente y tolerancia a fallos, detalle cómo plantearía esta infraestructura desde cero.**

Una infraestructura tradicional no debería tener problemas, es decir:

- Uso de Terraform o CloudFormation como base.
- Desplegar los recursos en diferentes zonas de disponibilidad en la región de AWS seleccionada. Si los requisitos de la aplicación lo justifican, desplegar una segunda región. 
- Desplegar VPC con 3 subredes públicas y 3 subredes privadas, Internet Gateway para las subredes públicas y NAT Gateways para las subredes privadas.
- Desplegar un clúster de Kubernetes en las subredes privadas, usar EKS Auto Mode, aplicar tags a recursos para que componentes como ALB Ingress Controller o Karpenter puedan realizar auto-discover.
- Usar flotas Spot o instancias reservadas para EC2.
- Desplegar balanceadores de carga en subredes públicas.
- Desplegar bases de datos en subredes privadas.
- Principio de provisionar servicios desde cero en vez de actualizar componentes como Kubernetes o RDS. Al actualizar un cluster de Kubernetes se deben tener tantas consideraciones, por todos los controladores y add-ons que el clúster requiere de base, que es mejor desplegar uno nuevo y mover las aplicaciones hacia el nuevo clúster. Algo similar ocurre con RDS y otros recursos cloud.
- Respetar el principio de menor privilegio o permiso, tanto para permisos de aplicaciones o usuario como para controles o recursos de red.
- Uso cuentas de servicio o roles IAM para acceder a recursos cloud.
- Todo secreto se guarda en AWS Secret Manager, Vault u otro similar.
- Establecer rotación para los secretos.
- Inyección de secretos en pod o archivo, para evitar uso de variables de entorno o Kubernetes Secrets.
- Uso de mecanismos de despliegue como Blue/Green o Canary cuando se deban realizar cambios en RDS o Kubernetes. 

*Incluya su enfoque en la selección y configuración específica de recursos AWS, implementación de principios como 'Immutable Infrastructure' y la aplicación directa de despliegues 'Blue/Green' en bases de datos relacionales (RDS), estrategias avanzadas de gestión de secretos, políticas de gobernanza sobre IaC, y cómo integraría mecanismos demonitoreo para anticipar y mitigar fallos antes de que impacten en producción.*

&nbsp;

**¿Qué herramientas recomendarías para cambios y despliegues seguros?**

Para cambios y despliegues seguros existen varias herramientas con las que he podido trabajar y cumplen bien su propósito:

- **Terraform o Pulumi** para generar infraestructura como código.
- **Helm** para la gestión de aplicaciones en Kubernetes.
- **ArgoCD o FluxCD** para implementat GitOps.
- **Vault o AWS Secrets Manager** para la gestión de secretos.
- **Snyk o SonarQube** para escanear calidad y vulnerabilidades en código fuente.
- **APMs** para conocer el rendimiento o cuellos de botella de las aplicaciones.
- **GitHub Actions o Gitlab CI** para workflows de CI/CD.

&nbsp;

**¿Cómo implementarías un pipeline CI/CD básico para contenedores?**

Un pipeline básico para contendores podría implementar las siguientas etapas:

  - Ejecutar un linter
  - Escanear con un herramienta de calidad de código como SonarQube
  - Ejecutar pruebas unitarias
  - Construir imagen de contenedor 
  - Subir imagen de contenedor a algún registro (como ECR)
  - Actualizar imagen de contenedor en Kubernetes (con Helm)

&nbsp;

**¿Cómo involucraría al equipo en estas mejoras sin detener la operación?**

Para involucrar al equipo sin detener la operación, consideraría:

  - Pequeñas sesiones sobre IaC, Kubernetes, GitOps, y CI/CD.
  - Crear entorno sandbox para que prueben los cambios antes de producción.
  - Despliegues controlados y granulares, no realizar muchos cambios al mismo tiempo.
  - Definir quién revisa PRs, quién aprueba despliegues.
  - Incluir logs de cambios y revisiones en cada paso.

&nbsp;