const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Transporter SMTP usando tu cuenta en cPanel
const transporter = nodemailer.createTransport({
  host: "mail.phos-chek.cl",
  port: 465, // si no funciona, prueba con 587 y secure: false
  secure: true,
  auth: {
    user: "rperez@phos-chek.cl",
    pass: "@B329cf36",
  },
});

// Función 1: eliminar usuario (callable)
exports.eliminarUsuario = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Debes estar autenticado.");
  }

  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection("perfiles").doc(callerUid).get();
  const callerRol = (callerDoc.data()?.rol || "").toLowerCase();

  if (!callerDoc.exists || callerRol !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "No tienes permisos.");
  }

  const uid = data.uid;
  if (!uid) {
    throw new functions.https.HttpsError("invalid-argument", "Debes proporcionar el UID.");
  }

  try {
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("perfiles").doc(uid).delete();
    return { success: true, message: "Usuario eliminado correctamente" };
  } catch (error) {
    throw new functions.https.HttpsError("internal", "Error al eliminar el usuario: " + error.message);
  }
});

// Función 2: notificar al administrador cuando se crea un usuario
exports.notificarNuevoUsuario = functions.auth.user().onCreate(async (user) => {
  const mailOptions = {
    from: "Sistema Riesgos",
    to: "rodrigo.alvarez@phos-chek.cl, claudio.opazo@phos-chek.cl",
    subject: "Nuevo usuario registrado",
    text: `Se ha registrado un nuevo usuario:\n\nEmail: ${user.email}\nUID: ${user.uid}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("✅ Notificación enviada a rperez@phos-chek.cl");
  } catch (error) {
    console.error("❌ Error enviando correo:", error);
  }
});