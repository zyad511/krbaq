import express from "express";
import session from "express-session";
import fetch from "node-fetch";
import path from "path";

const app = express();
const PORT = process.env.PORT || 3000;

/* ===== إعداداتك ===== */
const ADMIN_USERNAME = "944b"; // يوزرك فقط
const SECRET_PATH = process.env.SECRET_PATH; // مسار API السري

const DISCORD_CLIENT_ID = process.env.DISCORD_CLIENT_ID;
const DISCORD_CLIENT_SECRET = process.env.DISCORD_CLIENT_SECRET;
const DISCORD_REDIRECT = process.env.DISCORD_REDIRECT;

/* ===== Session ===== */
app.use(session({
  secret: "krbaq-secret",
  resave: false,
  saveUninitialized: false
}));

/* ===== Middleware ===== */
function requireAuth(req, res, next) {
  if (!req.session.user) return res.redirect("/login");
  next();
}

function requireAdmin(req, res, next) {
  if (!req.session.user) return res.redirect("/login");
  if (req.session.user.username !== ADMIN_USERNAME)
    return res.status(403).send("⛔ للمطور فقط");
  next();
}

/* ===== Discord Login ===== */
app.get("/login", (req, res) => {
  const url =
    `https://discord.com/oauth2/authorize?client_id=${DISCORD_CLIENT_ID}` +
    `&redirect_uri=${encodeURIComponent(DISCORD_REDIRECT)}` +
    `&response_type=code&scope=identify`;
  res.redirect(url);
});

app.get("/auth/discord/callback", async (req, res) => {
  const code = req.query.code;

  const tokenRes = await fetch("https://discord.com/api/oauth2/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: DISCORD_CLIENT_ID,
      client_secret: DISCORD_CLIENT_SECRET,
      grant_type: "authorization_code",
      code,
      redirect_uri: DISCORD_REDIRECT
    })
  });

  const token = await tokenRes.json();

  const userRes = await fetch("https://discord.com/api/users/@me", {
    headers: { Authorization: `Bearer ${token.access_token}` }
  });

  const user = await userRes.json();
  req.session.user = user;
  res.redirect("/");
});

app.get("/logout", (req, res) => {
  req.session.destroy(() => res.redirect("/login"));
});

/* ===== API سكربتات (Cache) ===== */
let CACHE = [];

async function loadScripts() {
  const first = await fetch(
    "https://rscripts.net/api/v2/scripts?page=1&orderBy=date&sort=desc"
  );
  const json = await first.json();

  let all = [...json.scripts];
  for (let p = 2; p <= json.info.maxPages; p++) {
    const r = await fetch(
      `https://rscripts.net/api/v2/scripts?page=${p}&orderBy=date&sort=desc`
    );
    const d = await r.json();
    all.push(...d.scripts);
  }

  CACHE = all;
  console.log("✅ Scripts loaded:", CACHE.length);
}

loadScripts();
setInterval(loadScripts, 30 * 60 * 1000);

/* ===== API سري ===== */
app.get(`${SECRET_PATH}/search`, requireAuth, (req, res) => {
  const q = (req.query.q || "").toLowerCase();
  const results = CACHE.filter(s =>
    s.title.toLowerCase().includes(q) ||
    s.game?.title?.toLowerCase().includes(q)
  );
  res.json(results.slice(0, 50));
});

/* ===== معلومات المستخدم ===== */
app.get("/me", (req, res) => {
  if (!req.session.user) return res.json({});
  res.json(req.session.user);
});

/* ===== صفحات ===== */
app.use(express.static("public"));

app.get("/", requireAuth, (_, res) =>
  res.sendFile(path.resolve("public/index.html"))
);

app.get("/admin", requireAdmin, (_, res) =>
  res.sendFile(path.resolve("public/admin.html"))
);

app.listen(PORT, () => console.log("🚀 Server running"));
