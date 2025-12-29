import fs from "fs";
import forge from "node-forge";

function pemToJwk(pem) {
  const privateKey = forge.pki.privateKeyFromPem(pem);

  const n = Buffer.from(privateKey.n.toByteArray()).toString("base64url");
  const e = Buffer.from(privateKey.e.toByteArray()).toString("base64url");
  const d = Buffer.from(privateKey.d.toByteArray()).toString("base64url");
  const p = Buffer.from(privateKey.p.toByteArray()).toString("base64url");
  const q = Buffer.from(privateKey.q.toByteArray()).toString("base64url");
  const dp = Buffer.from(privateKey.dP.toByteArray()).toString("base64url");
  const dq = Buffer.from(privateKey.dQ.toByteArray()).toString("base64url");
  const qi = Buffer.from(privateKey.qInv.toByteArray()).toString("base64url");

  return {
    kty: "RSA",
    use: "sig",
    alg: "RS384",
    n, e, d, p, q, dp, dq, qi
  };
}

function pemPublicToJwk(pem) {
  const publicKey = forge.pki.publicKeyFromPem(pem);

  const n = Buffer.from(publicKey.n.toByteArray()).toString("base64url");
  const e = Buffer.from(publicKey.e.toByteArray()).toString("base64url");

  return {
    kty: "RSA",
    use: "sig",
    alg: "RS384",
    n, e
  };
}

const privatePem = fs.readFileSync("epic-private.pem", "utf8");
const publicPem = fs.readFileSync("epic-public.pem", "utf8");

// Generate private JWK
const privateJwk = pemToJwk(privatePem);
fs.writeFileSync("epic-private.jwk", JSON.stringify(privateJwk, null, 2));

// Generate public JWK
const publicJwk = pemPublicToJwk(publicPem);
fs.writeFileSync("epic-public.jwk", JSON.stringify(publicJwk, null, 2));

console.log("✔ SUCCESS: Generated epic-private.jwk AND epic-public.jwk");
