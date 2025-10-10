const { onCall } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ region: "southamerica-west1" });

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