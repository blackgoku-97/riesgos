const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { getAuth } = require("firebase-admin/auth");

admin.initializeApp();

exports.eliminarUsuario = functions.https.onRequest(async (req, res) => {
  const authHeader = req.headers.authorization || "";
  const match = authHeader.match(/^Bearer (.*)$/);
  if (!match) {
    return res.status(401).json({ error: "Debes estar autenticado" });
  }

  try {
    const decoded = await getAuth().verifyIdToken(match[1]);
    const callerUid = decoded.uid;
    const callerDoc = await admin.firestore().collection("perfiles").doc(callerUid).get();
    const callerRol = (callerDoc.data()?.rol || "").toLowerCase();

    if (!callerDoc.exists || callerRol !== "admin") {
      return res.status(403).json({ error: "No tienes permisos para eliminar usuarios" });
    }

    const uid = req.body.uid;
    if (!uid) {
      return res.status(400).json({ error: "Debes proporcionar el UID del usuario a eliminar" });
    }

    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("perfiles").doc(uid).delete();

    return res.json({ success: true, message: "Usuario eliminado correctamente" });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});