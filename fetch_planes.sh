#!/bin/bash

# Archivo de salida
OUTPUT_FILE="planes.json"

# URL base de la API de Scryfall (planos)
URL="https://api.scryfall.com/cards/search?q=t:plane&unique=prints"

# Inicializar archivo
echo "[]" > $OUTPUT_FILE

# Variable para paginación
NEXT_PAGE="$URL"

# Mientras haya página siguiente
while [ ! -z "$NEXT_PAGE" ] && [ "$NEXT_PAGE" != "null" ]; do
  echo "Consultando: $NEXT_PAGE"
  
  # Hacer request y obtener JSON
  RESPONSE=$(curl -s "$NEXT_PAGE")
  
  # Extraer datos de cartas y append al JSON
  # Usamos jq para filtrar solo los campos que nos interesan
  # Campos: name, full, artwork, text
  CARDS=$(echo "$RESPONSE" | jq '[.data[] | {name: .name, full: (.image_uris.normal // .image_uris.small // ""), artwork: (.image_uris.art_crop // ""), text: .oracle_text}]')
  
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
