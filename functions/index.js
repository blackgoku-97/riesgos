const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.eliminarUsuario = functions.https.onCall(async (data, context) => {
  // Verificar que el usuario que llama esté autenticado
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Debes estar autenticado para realizar esta acción."
    );
  }

  // Verificar que sea admin
  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection("perfiles").doc(callerUid).get();
  if (!callerDoc.exists || (callerDoc.data().rol || "").toLowerCase() !== "admin") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "No tienes permisos para eliminar usuarios."
    );
  }

  const uid = data.uid;
  if (!uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Debes proporcionar el UID del usuario a eliminar."
    );
  }

  try {
    // Eliminar usuario de Authentication
    await admin.auth().deleteUser(uid);

    // Eliminar documento de Firestore
    await admin.firestore().collection("perfiles").doc(uid).delete();

    return { success: true, message: "Usuario eliminado correctamente" };
  } catch (error) {
    console.error("Error eliminando usuario:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error al eliminar el usuario: " + error.message
    );
  }
});