let planes = [];
let currentCard = null;
let translated = false;

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
  translated = false;
  document.getElementById('card-img').src = currentCard.artwork;
  document.getElementById('card-name').textContent = currentCard.name;
  document.getElementById('card-text').textContent = currentCard.text;
}

// Botón Aleatorio
document.getElementById('random-btn').addEventListener('click', showRandomCard);

// Botón Traducir
document.getElementById('translate-btn').addEventListener('click', () => {
  if (!currentCard) return;
  document.getElementById('card-text').textContent = translated ? currentCard.text : currentCard.text_es;
  translated = !translated;
});
