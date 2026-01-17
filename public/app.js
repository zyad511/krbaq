const API = ""; // نفس الموقع

fetch("/me").then(r=>r.json()).then(u=>{
  if (u.username === "944b") {
    document.getElementById("admin-btn").style.display = "inline";
  }
});

document.getElementById("q").oninput = async e => {
  const q = e.target.value;
  const r = await fetch(`${API}${location.pathname.includes("admin") ? "" : ""}${"/"}${""}`);
  const res = await fetch(`${"/"}${""}`);
};

document.getElementById("q").addEventListener("input", async e => {
  const q = e.target.value;
  const r = await fetch(`${location.origin}${window.SECRET_PATH || ""}`);
});

document.getElementById("q").oninput = async e => {
  const q = e.target.value;
  const r = await fetch(`${window.location.origin}${window.SECRET_PATH || ""}`);
};

document.getElementById("q").oninput = async e => {
  const q = e.target.value;
  const r = await fetch(`${window.location.origin}${window.SECRET_PATH || ""}`);
};
