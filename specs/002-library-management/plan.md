# Implementation Plan: Sistema de Gestión de Biblioteca

**Branch**: `002-add-library-management` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-library-management/spec.md`

## Summary

Desarrollar un sistema full-stack de gestión de biblioteca que permita a bibliotecarios administrar ejemplares, clientes y préstamos, y a clientes consultar disponibilidad. El backend se construye con Java 21 + Spring Boot 3 siguiendo arquitectura en capas (domain / application / infrastructure / api); el frontend con React + Vite + TypeScript consumiendo la API REST. La persistencia es PostgreSQL con Flyway para migraciones. La disponibilidad de un ejemplar se define como: `estadoActivo=true AND copyrightVigente=true AND sin préstamo activo`, y el 95% de las consultas de disponibilidad deben responder en ≤ 2 segundos para un catálogo de 100.000 ejemplares y 10.000 clientes.

## Technical Context

**Language/Version**: Java 21 (backend) · TypeScript 5 (frontend)

**Primary Dependencies**:
- Backend: Spring Boot 3.x, Spring Web, Spring Data JPA, Bean Validation, Flyway, springdoc-openapi 2.x, JUnit 5, Mockito
- Frontend: React 18, Vite 5, TypeScript 5, Axios (o fetch nativo)

**Storage**: PostgreSQL 15+

**Testing**: JUnit 5 + Mockito (unit y servicio) · Spring Boot Test con Testcontainers (integración)

**Target Platform**: Servidor Linux / Docker (backend) · Navegador moderno (frontend SPA)

**Project Type**: Full-stack web application (REST API + React SPA)

**Performance Goals**: 95% de consultas de disponibilidad ≤ 2 s con 100.000 ejemplares y 10.000 clientes activos

**Constraints**:
- Paginación: máximo 100 resultados por página; página ≤ 0 normaliza a 1
- Sin lógica de negocio en controladores ni en la capa de presentación
- Sin uso innecesario de `instanceof`; sin lógica duplicada entre capas
- No se implementa autenticación de cliente en v1

**Scale/Scope**: 100.000 ejemplares · 10.000 clientes · 6 pantallas principales

## Constitution Check

*GATE: evaluado antes de Phase 0. Re-evaluado post Phase 1.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I – Spec-Driven | ✅ PASS | Todos los FRs trazados a spec.md (FR-001–FR-034) |
| II – Real OO Domain | ✅ PASS | Entidades con comportamiento: `Ejemplar.esPrestable()`, `Prestamo.registrarDevolucion()` |
| III – Separation of Concerns | ✅ PASS | Capas: domain / application / infrastructure / api bien delimitadas |
| IV – Code Quality | ✅ PASS | Restricciones explicitadas: sin lógica en controllers, sin instanceof innecesario |
| V – Value Objects & Enums | ✅ PASS | `CategoriaLibro`, `EstadoEjemplar`, `EstadoPrestamo` como enums |
| VI – Design Patterns | ✅ PASS | Strategy para `SelectorFotoPerfilAnimal`; Repository para persistencia |
| VII – TDD Business Rules | ✅ PASS | Tests unitarios definidos para reglas de dominio |
| VIII – Scalability | ✅ PASS | Índices en `titulo`, `autor`, `categoria_libro`, `estado_ejemplar` documentados en research.md |
| IX – UX First | ✅ PASS | Pantalla de búsqueda como punto de entrada principal |
| X – Design-First | ✅ PASS | Esta fase solo genera documentos de planificación |

**No hay violaciones. Plan habilitado para implementación.**

## Project Structure

### Documentation (this feature)

```text
specs/002-library-management/
├── plan.md              # Este archivo
├── research.md          # Decisiones técnicas y justificaciones
├── data-model.md        # Modelo de dominio y esquema de base de datos
├── quickstart.md        # Guía de validación end-to-end
├── contracts/
│   └── openapi.yaml     # Contrato REST completo
└── tasks.md             # Generado por /speckit.tasks (pendiente)
```

### Source Code (repository root)

```text
backend/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/com/biblioteca/
    │   │   ├── domain/
    │   │   │   ├── model/
    │   │   │   │   ├── Ejemplar.java
    │   │   │   │   ├── Cliente.java
    │   │   │   │   ├── Prestamo.java
    │   │   │   │   ├── FotoPerfilAnimal.java
    │   │   │   │   ├── CategoriaLibro.java        # enum
    │   │   │   │   ├── EstadoEjemplar.java        # enum
    │   │   │   │   └── EstadoPrestamo.java        # enum
    │   │   │   └── repository/
    │   │   │       ├── EjemplarRepository.java
    │   │   │       ├── ClienteRepository.java
    │   │   │       ├── PrestamoRepository.java
    │   │   │       └── FotoPerfilAnimalRepository.java
    │   │   ├── application/
    │   │   │   └── service/
    │   │   │       ├── EjemplarService.java
    │   │   │       ├── ClienteService.java
    │   │   │       ├── PrestamoService.java
    │   │   │       └── SelectorFotoPerfilAnimal.java
    │   │   ├── infrastructure/
    │   │   │   └── persistence/
    │   │   │       ├── JpaEjemplarRepository.java
    │   │   │       ├── JpaClienteRepository.java
    │   │   │       ├── JpaPrestamoRepository.java
    │   │   │       └── JpaFotoPerfilAnimalRepository.java
    │   │   └── api/
    │   │       ├── controller/
    │   │       │   ├── EjemplarController.java
    │   │       │   ├── ClienteController.java
    │   │       │   ├── PrestamoController.java
    │   │       │   └── DisponibilidadController.java
    │   │       └── dto/
    │   │           ├── EjemplarDto.java
    │   │           ├── ClienteDto.java
    │   │           ├── PrestamoDto.java
    │   │           └── BusquedaEjemplarRequest.java
    │   └── resources/
    │       ├── application.properties
    │       └── db/migration/
    │           ├── V1__create_clientes.sql
    │           ├── V2__create_ejemplares.sql
    │           ├── V3__create_prestamos.sql
    │           ├── V4__create_fotos_perfil_animal.sql
    │           └── V5__seed_fotos_perfil_animal.sql
    └── test/
        └── java/com/biblioteca/
            ├── domain/
            │   ├── EjemplarTest.java
            │   ├── ClienteTest.java
            │   └── PrestamoTest.java
            ├── application/
            │   ├── PrestamoServiceTest.java
            │   └── EjemplarServiceTest.java
            ├── infrastructure/
            │   └── EjemplarRepositoryTest.java
            └── api/
                ├── EjemplarControllerTest.java
                └── PrestamoControllerTest.java

frontend/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── types/
    │   ├── ejemplar.ts
    │   ├── cliente.ts
    │   └── prestamo.ts
    ├── services/
    │   ├── ejemplarService.ts
    │   ├── clienteService.ts
    │   └── prestamoService.ts
    ├── pages/
    │   ├── BusquedaEjemplaresPage.tsx
    │   ├── EjemplaresPage.tsx
    │   ├── ClientesPage.tsx
    │   ├── NuevoPrestamoPage.tsx
    │   ├── DevolucionPage.tsx
    │   └── InformePrestamosPage.tsx
    └── components/
        ├── EjemplarForm.tsx
        ├── ClienteForm.tsx
        ├── PrestamoForm.tsx
        └── PaginatedTable.tsx
```

**Structure Decision**: Opción 2 (web application) con `backend/` y `frontend/` como módulos independientes en la raíz del repositorio. El backend expone la API REST documentada en `contracts/openapi.yaml`; el frontend la consume via HTTP.

## Complexity Tracking

> Sin violaciones a la constitución. No se requieren justificaciones.
