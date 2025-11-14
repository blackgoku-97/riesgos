const { setGlobalOptions } = require("firebase-functions/v2");
const { onCall } = require("firebase-functions/v2/https");
const { onUserCreated } = require("firebase-functions/v2/auth");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();
setGlobalOptions({ region: "southamerica-west1" });

// Configura el transporter con tu cuenta SMTP en cPanel
const transporter = nodemailer.createTransport({
  host: "mail.phos-chek.cl",   // servidor SMTP de tu dominio
  port: 465,                   // puerto seguro (SSL)
  secure: true,
  auth: {
    user: "rperez@phos-chek.cl", // tu cuenta en cPanel
    pass: "@B329cf36",         // contraseña de esa cuenta
  },
});

// Función 1: eliminar usuario
exports.eliminarUsuario = onCall(async (request) => {
  const context = request.auth;
  if (!context) {
    throw new Error("Debes estar autenticado para realizar esta acción.");
  }

  const callerUid = context.uid;
  const callerDoc = await admin.firestore().collection("perfiles").doc(callerUid).get();
  const callerRol = (callerDoc.data()?.rol || "").toLowerCase();

  if (!callerDoc.exists || callerRol !== "admin") {
    throw new Error("No tienes permisos para eliminar usuarios.");
  }

  const uid = request.data.uid;
  if (!uid) {
    throw new Error("Debes proporcionar el UID del usuario a eliminar.");
  }

  try {
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("perfiles").doc(uid).delete();
    return { success: true, message: "Usuario eliminado correctamente" };
  } catch (error) {
    throw new Error("Error al eliminar el usuario: " + error.message);
  }
});

// Función 2: notificar al administrador cuando se crea un usuario
exports.notificarNuevoUsuario = onUserCreated(async (event) => {
  const user = event.data;

  const mailOptions = {
    from: '"Sistema Riesgos" <rperez@phos-chek.cl>', // remitente
    to: "rperez@phos-chek.cl",                       // destinatario (admin)
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