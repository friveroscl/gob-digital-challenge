## Parte 3: Evaluar

Objetivo: Evaluar capacidad crítica, experiencia práctica y visión de mejora. Encuentre el o los errores.

&nbsp;

&nbsp;

*El SRE responsable de un producto, desplegó infraestructura en AWS usando scripts manuales no versionados. El entorno tiene Kubernetes (EKS), credenciales en texto plano, sin monitoreo centralizado, tiene autoscaling con un averageUtilization de 95, y actualizaciones manuales en pods en producción.*

**¿Qué errores técnicos identifica?**

  1. *Desplegar infraestructura usando scripts no versionados*: No es recomendable usar scripts para desplegar infraestructura -sino usar directamente herramientas de IaC como Terraform o Pulumi-, aunque podrían existir algunos contextos o casos en los cuales resulte más práctico usar scripts (por ejemplo, en la prueba técnica se usaron scripts para crear el bucket S3 y la tabla de DynamoDB). Al usar scripts no versionados podemos tener diferentes problemas:
    - Falta de trazabilidad o de responsables (¿quién es dueño de los scripts o aprueba sus cambios?)
    - Falta de consistencia en el estado de la infraestructura (¿cómo se modifica o actualiza la infraestructura creada con estos scripts?)

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

- Desplegar los recursos en diferentes zonas de disponibilidad en la región de AWS seleccionada. Si los requisitos de la aplicación lo justifican, desplegar una segunda región. 
- Desplegar VPC con 3 subredes públicas y 3 subredes privadas, Internet Gateway para las subredes públicas y NAT Gateways para las subredes privadas.
- Desplegar un clúster de Kubernetes en las subredes privadas, usar EKS Auto Mode, aplicar tags a recursos para que componentes como ALB Ingress Controller o Karpenter puedan realizar auto-discover. Usar Helm y GitOps si la madurez de la organización lo permite.
- Provisionar servicios desde cero en vez de actualizar componentes como Kubernetes o RDS, com Terraform y pipelines de CI/CD esto es posible.
- Respetar el principio de menor privilegio o permiso, tanto para permisos de aplicaciones o usuario como para controles o recursos de red.
- 


*Incluya su enfoque en la selección y configuración específica de recursos AWS, implementación de principios como 'Immutable Infrastructure' y la aplicación directa de despliegues 'Blue/Green' en bases de datos relacionales (RDS), estrategias avanzadas de gestión de secretos, políticas de gobernanza sobre IaC, y cómo integraría mecanismos demonitoreo para anticipar y mitigar fallos antes de que impacten en producción.*

&nbsp;

**¿Qué herramientas recomendarías para cambios y despliegues seguros?**


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
  - 

&nbsp;