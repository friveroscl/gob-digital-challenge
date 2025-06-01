## Parte 3: Evaluar

Objetivo: Evaluar capacidad crítica, experiencia práctica y visión de mejora. Encuentre el o los errores.

*El SRE responsable de un producto, desplegó infraestructura en AWS usando scripts manuales no versionados. El entorno tiene Kubernetes (EKS), credenciales en texto plano, sin monitoreo centralizado, tiene autoscaling con un averageUtilization de 95, y actualizaciones manuales en pods en producción.*

- ¿Qué errores técnicos identifica?

  - *Desplegar infraestructura usando scripts no versionados*: si bien es recomendable no usar scripts para desplegar infraestructura -sino usar directamente herramientas de IaC como Terraform o Pulumi-, resulta común y práctico usar scripts para algunas tareas específicas. Por lo tanto, el error no es usar scripts, sino más bien **que no estén versionados**. Al no estar versionados podemos tener diferentes problemas:
    -  

  - Credenciales en texto plano
  - Sin monitoreo
  - AutoScaling
  - Actualizaciones manuales de pods


- ¿Cuál es el impacto de tener credenciales expuestas y qué solución propone?

  - 

- Considerando principios avanzados de infraestructura resiliente y tolerancia a fallos, detalle cómo plantearía esta infraestructura desde cero.
  *Incluya su enfoque en la selección y configuración específica de recursos AWS, implementación de principios como 'Immutable Infrastructure' y la aplicación directa de despliegues 'Blue/Green' en bases de datos relacionales (RDS), estrategias avanzadas de gestión de secretos, políticas de gobernanza sobre IaC, y cómo integraría mecanismos demonitoreo para anticipar y mitigar fallos antes de que impacten en producción.*

- ¿Qué herramientas recomendarías para cambios y despliegues seguros?

- ¿Cómo implementarías un pipeline CI/CD básico para contenedores?

- ¿Cómo involucraría al equipo en estas mejoras sin detener la operación?