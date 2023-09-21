#!/bin/bash

# Define default values
DEFAULT_ROOT_CA_SUBJECT="/C=CN/ST=Jiangsu/L=Wuxi/O=zzz/OU=zzz/CN=zzz Root CA"
DEFAULT_VALID_DAYS=73000
DEFAULT_SERIAL_NUMBER=1000

# Define variables with default values
ROOT_CA_SUBJECT="$DEFAULT_ROOT_CA_SUBJECT"
VALID_DAYS="$DEFAULT_VALID_DAYS"
SERIAL_NUMBER="$DEFAULT_SERIAL_NUMBER"

# Define other variables
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUT_DIR="../out"
ROOT_KEY_FILE="$OUT_DIR/root.key.pem"
ROOT_CRT_FILE="$OUT_DIR/root.crt"
CA_CONFIG="ca.cnf"
INDEX_FILE="$OUT_DIR/index.txt"
ATTR_FILE="$OUT_DIR/index.txt.attr"
SERIAL_FILE="$OUT_DIR/serial"

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--subject)
      ROOT_CA_SUBJECT="$2"
      shift 2
      ;;
    -d|--valid-days)
      VALID_DAYS="$2"
      shift 2
      ;;
    -sn|--serial-number)
      SERIAL_NUMBER="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 [-s root ca subject, default: $DEFAULT_ROOT_CA_SUBJECT ]
       [-d validity days, default: $DEFAULT_VALID_DAYS ]
       [-sn serial number, default: $DEFAULT_SERIAL_NUMBER ]" >&2
       exit 1
       ;;
  esac
done

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to generate the root certificate and key
generate_ROOT_CRT_FILE() {
    # Check if root certificate already exists
    if file_exists "$ROOT_CRT_FILE" && file_exists "ROOT_KEY_FILE"; then
        echo "######### Root certificate already exists, skip generating root certificate #########"
        return
    fi

    # Init 'out' directory if some files doesn't exist
    mkdir -p "$OUT_DIR/newcerts"
    ! file_exists "$INDEX_FILE" && touch "$INDEX_FILE"
    ! file_exists "$ATTR_FILE" && echo "unique_subject = no" > "$ATTR_FILE"
    ! file_exists "$SERIAL_FILE" && echo "$SERIAL_NUMBER" > "$SERIAL_FILE"

    # Generate root cert along with root key
    openssl req -config "$CA_CONFIG" \
        -newkey rsa:4096 -nodes -keyout "$ROOT_KEY_FILE" \
        -new -x509 -days "$VALID_DAYS" -out "$ROOT_CRT_FILE" \
        -subj "$ROOT_CA_SUBJECT"
    
    echo "Root certificate generated."
}

# Main script execution
cd "$SCRIPT_DIR" || exit
generate_ROOT_CRT_FILE