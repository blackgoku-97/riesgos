# 📱 Gestión de Riesgos Laborales

Aplicación móvil desarrollada en **Flutter** para la **planificación, control y seguimiento de riesgos laborales**.  
Incluye gestión de usuarios con roles, creación y duplicación de planificaciones, historial con exportación a Excel/PDF, y validaciones en tiempo real.

---

## 🚀 Características principales

- **Autenticación con Firebase Auth** (email/contraseña).
- **Roles de usuario**: `admin` y `usuario` con permisos diferenciados.
- **Creación de planificaciones** con:
  - Selección de área, proceso y actividad.
  - Peligros, agentes materiales y medidas.
  - Cálculo automático de nivel de riesgo (solo admin).
  - Captura de ubicación GPS y fotografía.
- **Duplicación** de planificaciones existentes.
- **Historial** con filtro por año y exportación a Excel/PDF.
- **Validaciones locales** (RUT, email, campos obligatorios) y visuales (bordes verdes/rojos).
- **Almacenamiento de imágenes** en Firebase Storage.
- **Base de datos en tiempo real** con Cloud Firestore.
- **Funciones Cloud** para operaciones seguras.

---