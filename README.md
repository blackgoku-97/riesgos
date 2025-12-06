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

## 🛠️ Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x o superior)
- [Dart SDK](https://dart.dev/get-dart)
- Cuenta en [Firebase](https://firebase.google.com/)
- Proyecto de Firebase configurado con:
  - **Authentication** (Email/Password)
  - **Cloud Firestore**
  - **Firebase Storage**
  - **Cloud Functions**

---

## 👥 Roles y permisos
- 	Admin
- 	Acceso a gestión de usuarios.
- 	Puede ver y eliminar cualquier planificación.
- 	Puede calcular y modificar nivel de riesgo.
- 	Usuario
- 	Solo puede crear y ver sus propias planificaciones.
- 	No puede acceder a gestión de usuarios.