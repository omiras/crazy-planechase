#!/bin/bash

# Archivo de salida
OUTPUT_FILE="planes.json"

# URL base de la API de Scryfall (planos)
URL="https://api.scryfall.com/cards/search?q=t:plane&unique=prints"

# Inicializar archivo
echo "[]" > $OUTPUT_FILE

# Variable para paginación
NEXT_PAGE="$URL"

# Función para traducir texto a español usando LibreTranslate
translate_to_es() {
  local text="$1"
  if [ -z "$text" ] || [ "$text" = "null" ]; then
    echo ""
    return
  fi

  # Petición a LibreTranslate (instancia pública). Si falla, devuelve cadena vacía.
  TRANSLATED=$(curl -s -X POST "https://libretranslate.com/translate" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg q "$text" --arg source "en" --arg target "es" '{q:$q,source:$source,target:$target,format:"text"}')")

  echo "$TRANSLATED" | jq -r '.translatedText // ""' 2>/dev/null || echo ""
}

# Mientras haya página siguiente
while [ ! -z "$NEXT_PAGE" ] && [ "$NEXT_PAGE" != "null" ]; do
  echo "Consultando: $NEXT_PAGE"
  
  # Hacer request y obtener JSON
  RESPONSE=$(curl -s "$NEXT_PAGE")
  
  # Extraer datos de cartas, traducir el texto y crear array con campo adicional text_es
  CARDS=$(
    echo "$RESPONSE" | jq -c '.data[] | {name: .name, full: (.image_uris.normal // .image_uris.small // ""), artwork: (.image_uris.art_crop // ""), text: .oracle_text}' \
    | while read -r card; do
        name=$(echo "$card" | jq -r '.name')
        full=$(echo "$card" | jq -r '.full')
        artwork=$(echo "$card" | jq -r '.artwork')
        text=$(echo "$card" | jq -r '.text // ""')
        text_es=$(translate_to_es "$text")
        jq -n --arg name "$name" --arg full "$full" --arg artwork "$artwork" --arg text "$text" --arg text_es "$text_es" \
          '{name:$name, full:$full, artwork:$artwork, text:$text, text_es:$text_es}'
      done | jq -s '.'
  )
  
  # Combinar con archivo existente
  TEMP=$(jq -s '.[0] + .[1]' $OUTPUT_FILE <(echo "$CARDS"))
  echo "$TEMP" > $OUTPUT_FILE

  # Obtener la siguiente página
  HAS_MORE=$(echo "$RESPONSE" | jq -r '.has_more')
  if [ "$HAS_MORE" = "true" ]; then
    NEXT_PAGE=$(echo "$RESPONSE" | jq -r '.next_page')
  else
    NEXT_PAGE="null"
  fi
done

echo "¡Listo! JSON guardado en $OUTPUT_FILE"
