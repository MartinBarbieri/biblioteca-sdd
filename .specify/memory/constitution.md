# Biblioteca SDD Constitution

Sistema de biblioteca educativo para enseñanza de programación orientada a objetos, Software-Driven Development y desarrollo full-stack.

## Core Principles

### I. Specification-Driven Development
La especificación manda sobre la implementación. No se debe programar funcionalidad que no esté trazada a una historia de usuario o requisito. Toda implementación debe ser verificable contra sus requisitos documentados.

### II. Real Object-Oriented Domain Modeling
El dominio debe modelarse con orientación a objetos real. Evitar clases anémicas cuando haya reglas de negocio claras. El dominio debe capturar y expresar las reglas del negocio de forma natural y declarativa en el código.

### III. Separation of Concerns
Separar responsabilidades entre capas:
- **Dominio**: reglas de negocio y entidades
- **Aplicación/Servicios**: casos de uso y coordinación
- **Infraestructura**: base de datos, repositorios, persistencia
- **Presentación/API**: endpoints y DTOs
- **Frontend**: interfaz de usuario

Cada capa debe tener una responsabilidad clara y no invadir el espacio de otras.

### IV. Code Quality and Clarity
En el backend Java se debe evitar lógica duplicada, métodos gigantes, validaciones mezcladas con controladores y uso innecesario de instanceof. El código debe ser legible, mantenible y expresar la intención claramente.

### V. Value Objects and Enums
Usar enums o value objects cuando representen valores cerrados. Por ejemplo, la categoría de libro es un enum cerrado, no una string. Esto mejora type-safety y claridad del dominio.

### VI. Design Patterns Applied Pragmatically
Aplicar patrones de diseño solo si simplifican el diseño. No forzar patrones por forzarlos. Todo patrón debe justificarse por el beneficio que aporta.

### VII. Test-Driven Business Rules
Toda regla de negocio importante debe tener tests. Los tests son la especificación viva de cómo funciona el sistema y garantizan que el dominio está modelado correctamente.

### VIII. Scalability and Performance
El sistema debe poder crecer a 100.000 libros y 10.000 clientes. Las búsquedas de disponibilidad no deben depender de recorrer listas completas en memoria. Se deben diseñar índices y estructuras de datos eficientes desde el inicio.

### IX. User Experience First
La interfaz debe priorizar usabilidad. Encontrar libros disponibles debe ser simple, rápido y claro. La UX es parte integral de la calidad del producto, no un afterthought.

### X. Design-First Development Workflow
No implementar código durante las fases de especificación, aclaración, checklist, planificación y generación de tareas. Solo crear o actualizar los documentos correspondientes. La implementación ocurre únicamente en la fase de ejecución.

## Architecture and Technology Stack

- **Backend**: Java con Spring Boot (o equivalente)
- **Frontend**: Interfaz web moderna (React, Vue, o similar)
- **Database**: RDBMS (PostgreSQL recomendado) con índices para búsquedas eficientes
- **API**: REST siguiendo estándares de industria

## Development Workflow

1. **Specification Phase**: Especificar requerimientos, historias de usuario, criterios de aceptación.
2. **Clarification Phase**: Resolver ambigüedades sin escribir código.
3. **Checklist Phase**: Crear listas de validación y criterios de éxito.
4. **Planning Phase**: Descomponer en tareas, diseñar solución, identificar riesgos.
5. **Task Generation Phase**: Generar tareas detalladas, ordenadas por dependencias.
6. **Implementation Phase**: Escribir código siguiendo TDD, principios de diseño y esta constitución.
7. **Validation Phase**: Ejecutar tests, validar funcionalidad, verificar usabilidad.

En fases 1-5, solo documentar. En fase 6, implementar. En fase 7, validar.

## Code Review Standards

- Toda funcionalidad debe rastrearse a un requisito
- Las pruebas deben validar comportamiento del dominio
- La arquitectura debe respetar la separación de capas
- Los nombres deben ser claros y expresivos
- Sin lógica duplicada o métodos gigantes

## Governance

Esta constitución define los principios vinculantes para el desarrollo de Biblioteca SDD. Todo código y decisión de diseño debe ser evaluado contra estos principios.

- **Amendments**: Requieren documentación de la razón del cambio, impacto, y aprobación del equipo.
- **Versioning**: Cambios en principios = MAJOR; nuevas secciones/restricciones = MINOR; clarificaciones = PATCH.
- **Compliance**: Los PRs deben verificar conformidad con estos principios. Las desviaciones deben justificarse y documentarse.

**Version**: 1.0.0 | **Ratified**: 2026-06-07 | **Last Amended**: 2026-06-07
