const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  host: "mail.phos-chek.cl",
  port: 465,
  secure: true,
  auth: {
    user: "rperez@phos-chek.cl",
    pass: "@B329cf36",
  },
});

// Crear usuario por administrador
exports.createUserByAdmin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Debes estar autenticado.");
  }

  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection("perfiles").doc(callerUid).get();
  const callerRol = (callerDoc.data()?.rol || "").toLowerCase();

  if (!callerDoc.exists || callerRol !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "No tienes permisos.");
  }

  const { nombre, cargo, rut, email, password } = data;
  if (!nombre || !cargo || !rut || !email || !password) {
    throw new functions.https.HttpsError("invalid-argument", "Faltan campos obligatorios.");
  }

  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: nombre,
    });

    await admin.firestore().collection("perfiles").doc(userRecord.uid).set({
      nombre,
      cargo,
      rutFormateado: rut,
      email,
      rol: "usuario",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const mailOptions = {
      from: "Sistema Riesgos Phos-Chek",
      to: "rodrigo.alvarez@phos-chek.cl, claudio.opazo@phos-chek.cl",
      subject: "Nuevo usuario creado en el sistema",
      text: `Se ha creado un nuevo usuario:\n\nNombre: ${nombre}\nCargo: ${cargo}\nEmail: ${email}\nRUT: ${rut}`,
    };

    await transporter.sendMail(mailOptions);

    return { success: true, uid: userRecord.uid };
  } catch (error) {
    throw new functions.https.HttpsError("internal", "Error al crear usuario: " + error.message);
  }
});

// Eliminar usuario
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

// Notificar cuando se crea un usuario en Auth (registro normal)
exports.notificarNuevoUsuario = functions.auth.user().onCreate(async (user) => {
  const mailOptions = {
    from: "Sistema Riesgos Phos-Chek",
    to: "rodrigo.alvarez@phos-chek.cl, claudio.opazo@phos-chek.cl",
    subject: "Nuevo usuario registrado en el sistema",
    text: `Se ha registrado un nuevo usuario:\n\nEmail: ${user.email}\nNombre: ${user.displayName || "Sin nombre"}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("✅ Notificación enviada a administradores");
  } catch (error) {
    console.error("❌ Error enviando correo:", error);
  }
});