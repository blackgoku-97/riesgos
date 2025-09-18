const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.eliminarUsuario = functions.https.onCall(async (data, context) => {
  // 1) Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Debes estar autenticado para realizar esta acción."
    );
  }

  // 2) Validar argumento
  const targetUid = data && data.uid ? data.uid : null;
  if (!targetUid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Debes proporcionar el UID del usuario a eliminar."
    );
  }

  // 3) Verificar que quien llama sea admin en Firestore
  try {
    const callerUid = context.auth.uid;
    const perfilCaller = await admin
      .firestore()
      .collection("perfiles")
      .doc(callerUid)
      .get();

    if (!perfilCaller.exists) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "No tienes permisos para eliminar usuarios."
      );
    }

    const perfilData = perfilCaller.data();
    const rolCaller = perfilData && perfilData.rol
      ? perfilData.rol.toString().trim().toLowerCase()
      : "";

    if (rolCaller !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "No tienes permisos para eliminar usuarios."
      );
    }
  } catch (err) {
    if (err instanceof functions.https.HttpsError) throw err;
    throw new functions.https.HttpsError(
      "internal",
      `Error validando permisos: ${err.message || err}`
    );
  }

  // 4) Eliminar usuario en Auth
  try {
    await admin.auth().deleteUser(targetUid);
  } catch (err) {
    if (err.code !== "auth/user-not-found") {
      throw new functions.https.HttpsError(
        "unknown",
        `Error al borrar en Auth: ${err.message || err}`
      );
    }
  }

  // 5) Eliminar documento en Firestore
  try {
    await admin.firestore().collection("perfiles").doc(targetUid).delete();
  } catch (err) {
    // Si no existe el doc, no es crítico
  }

  return { success: true };
});