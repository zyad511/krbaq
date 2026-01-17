const API = "/KRBx9A2QmLz"; // مسار API السري

// إظهار زر الأدمن
fetch("/me").then(r => r.json()).then(user => {
  if (user.username === "944b") {
    document.getElementById("admin-btn").style.display = "inline-block";
  }
});

const container = document.getElementById("scripts-container");
const input = document.getElementById("q");

async function searchScripts(q) {
  const res = await fetch(`${API}/search?q=${encodeURIComponent(q)}`);
  const data = await res.json();

  container.innerHTML = "";
  data.forEach(script => {
    const card = document.createElement("div");
    card.className = "card";
    card.innerHTML = `
      <img src="${script.image || 'https://i.pravatar.cc/300'}" alt="${script.title}">
      <h3>${script.title}</h3>
      <p>${script.description || 'بدون وصف'}</p>
      <button onclick="navigator.clipboard.writeText('${script.rawScript}')">
        📋 نسخ السكربت
      </button>
    `;
    container.appendChild(card);
  });
}

input.addEventListener("input", e => searchScripts(e.target.value));
