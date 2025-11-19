let planes = [];
let currentCard = null;
let translated = true; // true = mostrando texto en español (text_es) por defecto

// Cargar JSON local
fetch('planes.json')
  .then(res => res.json())
  .then(data => {
    planes = data;
    showRandomCard();
  })
  .catch(err => console.error("Error cargando JSON:", err));

// Mostrar carta aleatoria
function showRandomCard() {
  const index = Math.floor(Math.random() * planes.length);
  currentCard = planes[index];
  translated = true;
  document.getElementById('card-img').src = currentCard.artwork;
  document.getElementById('card-name').textContent = currentCard.name;
  // Mostrar la versión en español por defecto, si existe; si no, fallback al inglés
  document.getElementById('card-text').textContent = currentCard.text_es && currentCard.text_es.length ? currentCard.text_es : currentCard.text;
  // Ajustar la etiqueta del botón para que describa la acción siguiente
  const translateBtn = document.getElementById('translate-btn');
  if (translateBtn) translateBtn.textContent = 'Texto original inglés';
}

// Botón Aleatorio
document.getElementById('random-btn').addEventListener('click', showRandomCard);

// Botón Texto original inglés (alternar)
document.getElementById('translate-btn').addEventListener('click', () => {
  if (!currentCard) return;
  // Si ahora mostramos la versión en español, al pulsar mostramos el original en inglés y viceversa
  document.getElementById('card-text').textContent = translated ? (currentCard.text || "") : (currentCard.text_es || "");
  translated = !translated;
  // Actualizar etiqueta del botón para indicar la acción al siguiente click
  const translateBtn = document.getElementById('translate-btn');
  if (translateBtn) translateBtn.textContent = translated ? 'Texto original inglés' : 'Texto en español';
});
