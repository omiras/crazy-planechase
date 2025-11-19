#!/bin/bash

# Archivo de salida
OUTPUT_FILE="planes.json"

# URL base de la API de Scryfall (planos básicos)
URL="https://api.scryfall.com/cards/search?q=t:basic+land&unique=prints"

# Inicializar archivo
echo "[]" > $OUTPUT_FILE

# Variable para paginación
NEXT_PAGE="$URL"

# Mientras haya página siguiente
while [ "$NEXT_PAGE" != "null" ]; do
  echo "Consultando: $NEXT_PAGE"
  
  # Hacer request y obtener JSON
  RESPONSE=$(curl -s "$NEXT_PAGE")
  
  # Extraer datos de cartas y append al JSON
  # Usamos jq para filtrar solo los campos que nos interesan
  # Campos: name, image_uris.normal (o small), oracle_text
  CARDS=$(echo "$RESPONSE" | jq '[.data[] | {name: .name, image: .image_uris.normal, text: .oracle_text}]')
  
  # Combinar con archivo existente
  TEMP=$(jq -s '.[0] + .[1]' $OUTPUT_FILE <(echo "$CARDS"))
  echo "$TEMP" > $OUTPUT_FILE

  # Obtener la siguiente página
  NEXT_PAGE=$(echo "$RESPONSE" | jq -r '.has_more | if . then . else "null" end')
  if [ "$NEXT_PAGE" = "true" ]; then
    NEXT_PAGE=$(echo "$RESPONSE" | jq -r '.next_page')
  else
    NEXT_PAGE="null"
  fi
done

echo "¡Listo! JSON guardado en $OUTPUT_FILE"
