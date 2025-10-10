const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.eliminarUsuario = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Debes estar autenticado para realizar esta acción."
    );
  }

  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection("perfiles").doc(callerUid).get();
  const callerRol = (callerDoc.data()?.rol || "").toLowerCase();

  if (!callerDoc.exists || callerRol !== "admin") {
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
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("perfiles").doc(uid).delete();
    return { success: true, message: "Usuario eliminado correctamente" };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});