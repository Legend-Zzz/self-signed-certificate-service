#!/bin/bash

# Define default values
DEFAULT_CA_SUBJECT="/C=CN/ST=Jiangsu/L=Wuxi/O=zzz/OU=zzz/CN=zzz"
DEFAULT_VALID_DAYS=73000
DEFAULT_SERIAL_NUMBER=1000

# Define variables with default values
CA_SUBJECT="$DEFAULT_CA_SUBJECT"
ROOT_CA_SUBJECT="$DEFAULT_CA_SUBJECT"
VALID_DAYS="$DEFAULT_VALID_DAYS"
ROOT_VALID_DAYS="$DEFAULT_VALID_DAYS"
SERIAL_NUMBER="$DEFAULT_SERIAL_NUMBER"

# Define other variables
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUT_DIR="../out"
CSR_FILE="${OUT_DIR}/server.csr.pem"
CRT_FILE="${OUT_DIR}/server.crt"
KEY_FILE="${OUT_DIR}/server.key.pem"
BUNDLE_CRT_FILE="${OUT_DIR}/server.bundle.crt"
ROOT_CRT_FILE="${OUT_DIR}/root.crt"
ROOT_KEY_FILE="${OUT_DIR}/root.key.pem"
CA_CONFIG="ca.cnf"

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to generate root certificate
generate_root_cert() {
    if ! file_exists "$ROOT_CRT_FILE" && ! file_exists "$ROOT_KEY_FILE"; then
        options=("-s" "$ROOT_CA_SUBJECT" "-d" "$ROOT_VALID_DAYS" "-sn" "$SERIAL_NUMBER")
        bash +x gen.root.sh "${options[@]}"
    else
        echo "######### Root certificate already exists, skip generating root certificate #########"
    fi
}

# Function to generate the certificate key
generate_cert_key() {
    # Generate cert key
    openssl genrsa -out "$KEY_FILE" 4096
    echo "Certificate key generated."
}

# Function to generate SAN string
generate_san() {
    SAN=""
    DOMAINS="$1"
    IP_ADDRESSES="$2"
    IFS=',' read -ra DOMAIN_LIST <<< "$DOMAINS"
    IFS=',' read -ra IP_LIST <<< "$IP_ADDRESSES"

    for domain in "${DOMAIN_LIST[@]}"; do
        SAN+="DNS:$domain,"
    done

    for ip in "${IP_LIST[@]}"; do
        SAN+="IP:$ip,"
    done

    SAN=${SAN%,}  # Remove the trailing comma
    echo "$SAN"
}

# Function to generate CSR
generate_csr() {
    SAN="$1"
    if [ -z "$SAN" ]; then
        openssl req -new -out "$CSR_FILE" \
            -key "$KEY_FILE" \
            -config <(cat "$CA_CONFIG") \
            -subj "$CA_SUBJECT"
    else
        openssl req -new -out "$CSR_FILE" \
            -key "$KEY_FILE" \
            -reqexts SAN \
            -config <(cat "$CA_CONFIG" \
                <(printf "[SAN]\nsubjectAltName=${SAN}")) \
            -subj "$CA_SUBJECT"
    fi
}

# Function to sign certificate
sign_certificate() {
    openssl ca -config "$CA_CONFIG" -batch -notext \
        -in "$CSR_FILE" \
        -out "$CRT_FILE" \
        -cert "$ROOT_CRT_FILE" \
        -keyfile "$ROOT_KEY_FILE" \
        -days "$VALID_DAYS"  # Use the specified validity period
}

# Function to chain certificate with CA
chain_certificate() {
    cat "$CRT_FILE" "$ROOT_CRT_FILE" > "$BUNDLE_CRT_FILE"
}

# Initialize variables
DOMAIN=""
IPADDR=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--domain)
      DOMAIN="$2"
      shift 2
      ;;
    -i|--ip)
      IPADDR="$2"
      shift 2
      ;;
    -s|--subject)
      CA_SUBJECT="$2"
      ROOT_CA_SUBJECT="$2"
      shift 2
      ;;
    -D|--valid-days)
      VALID_DAYS="$2"  # Set the validity period from the command line argument
      ROOT_VALID_DAYS="$2"
      shift 2
      ;;
    -rs|--root-subject)
      ROOT_CA_SUBJECT="$2"
      shift 2
      ;;
    -rD|--root-validdays)
      ROOT_VALID_DAYS="$2"  # Set the validity period from the command line argument
      shift 2
      ;;
    -sn|--serial-number)
      SERIAL_NUMBER="$2"  # Set the validity period from the command line argument
      shift 2
      ;;
    *)
      echo "Usage: $0 [-d domain, optional parameter, multiple parameters separated by commas ] 
       [-i ip, optional parameter, multiple parameters separated by commas ] 
       [-s ca subject, default: $DEFAULT_CA_SUBJECT ]
       [-D ca validity days, default: $DEFAULT_VALID_DAYS ] 
       [-rs root ca subject, If not specified same to -s ] 
       [-rD root ca validity days, If not specified same to -D ] 
       [-sn serial number, default: $DEFAULT_SERIAL_NUMBER ]" >&2
      exit 1
      ;;
  esac
done



# Main script execution
cd "$SCRIPT_DIR" || exit

# Generate root certificate
generate_root_cert

# Generate server certificate key
generate_cert_key

# Generate SAN
SAN=$(generate_san "$DOMAIN" "$IPADDR")

# Generate CSR
generate_csr "$SAN"

# Issue certificate
sign_certificate

# Chain certificate with CA
chain_certificate

# Output certificates
echo
echo "Certificates are located in:"
ls -la "$(pwd)/${OUT_DIR}"/*.**