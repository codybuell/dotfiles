#!/usr/bin/env bash

# Array of keyservers to try
KEYSERVERS=(
    "keyserver.ubuntu.com"
    "keys.openpgp.org"
    "pgp.mit.edu"
    "keyserver.pgp.com"
)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to extract email from GPG verification output
get_signer_email() {
    local verify_output="$1"

    # Try to extract email from "Good signature from" line
    local email
    email=$(echo "$verify_output" | grep -E "(Good signature from|using)" | \
            sed -n 's/.*<\([^>]*@[^>]*\)>.*/\1/p' | head -1)

    if [[ -n "$email" ]]; then
        echo "$email"
        return 0
    fi

    # Fallback: try to extract from uid line if key is in local keyring
    local key_id
    key_id=$(echo "$verify_output" | grep -E "(Good signature|using)" | \
             sed -n 's/.*key ID \([A-F0-9]*\).*/\1/p' | head -1)

    if [[ -n "$key_id" ]]; then
        email=$(gpg --list-keys --with-colons "$key_id" 2>/dev/null | \
                awk -F: '/^uid:/ {print $10}' | \
                sed -n 's/.*<\([^>]*@[^>]*\)>.*/\1/p' | head -1)
        if [[ -n "$email" ]]; then
            echo "$email"
            return 0
        fi
    fi

    return 1
}

# Function to get trusted key IDs from keyserver via HTTP
get_trusted_keys() {
    local email=$1
    local keyserver=$2

    # URL encode the email
    local encoded_email=$(printf '%s' "$email" | sed 's/@/%40/g')
    local search_url="https://${keyserver}/pks/lookup?search=${encoded_email}&op=index&options=mr"

    # Query keyserver and extract key IDs
    if ! search_result=$(curl -s --connect-timeout 10 "$search_url"); then
        echo "Failed to query keyserver $keyserver" >&2
        return 1
    fi

    # Extract key IDs from machine-readable format (lines starting with "pub:")
    echo "$search_result" | awk '/^pub:/ {split($0, fields, ":"); print fields[2]}' | grep -E '^[A-F0-9]{8,}$'
}

# Function to get all subkeys for trusted primary keys
get_all_trusted_keys() {
    local primary_keys=("$@")
    local all_keys=()

    # Add primary keys
    all_keys+=("${primary_keys[@]}")

    # Get subkeys for each primary key
    for primary_key in "${primary_keys[@]}"; do
        if gpg --list-keys --with-colons --keyid-format long "$primary_key" >/dev/null 2>&1; then

            # Get the primary key fingerprint
            local primary_fp
            primary_fp=$(gpg --list-keys --with-colons --fingerprint "$primary_key" 2>/dev/null | awk -F: '/^fpr:/ {print $10}' | head -1)
            if [[ -n "$primary_fp" && "$primary_fp" != "$primary_key" ]]; then
                all_keys+=("$primary_fp")
            fi

            # Extract actual subkey IDs and their fingerprints
            local subkey_info
            subkey_info=$(gpg --list-keys --with-colons --keyid-format long "$primary_key" 2>/dev/null | awk -F: '/^sub:/ {print $5}')

            while IFS= read -r subkey_id; do
                if [[ -n "$subkey_id" ]]; then
                    all_keys+=("$subkey_id")

                    # Get the subkey fingerprint
                    local subkey_fp
                    subkey_fp=$(gpg --list-keys --with-colons --fingerprint "$subkey_id" 2>/dev/null | awk -F: '/^fpr:/ {print $10}' | tail -1)
                    if [[ -n "$subkey_fp" && "$subkey_fp" != "$subkey_id" ]]; then
                        all_keys+=("$subkey_fp")
                    fi
                fi
            done <<< "$subkey_info"
        fi
    done

    printf '%s\n' "${all_keys[@]}"
}

# Function to import keys if not already present
import_trusted_keys() {
    local email=$1
    local keyservers=("${@:2}")

    local found_keys=""

    # Try each keyserver until we find keys
    for keyserver in "${keyservers[@]}"; do

        local key_ids
        if key_ids=$(get_trusted_keys "$email" "$keyserver"); then
            if [[ -n "$key_ids" ]]; then
                echo "Found keys for $email on $keyserver" >&2
                found_keys="$key_ids"

                # Import each key
                while IFS= read -r key_id; do
                    if [[ -n "$key_id" ]]; then
                        echo "  Importing key: ${key_id:0:16}..." >&2
                        if ! gpg --keyserver "hkps://$keyserver" --recv-keys "$key_id" >/dev/null 2>&1; then
                            echo "Warning: Failed to import key $key_id from $keyserver" >&2
                        fi
                    fi
                done <<< "$key_ids"

                break  # Stop trying other keyservers once we find keys
            fi
        fi
    done

    if [[ -z "$found_keys" ]]; then
        echo "Failed to retrieve trusted keys for $email from any keyserver" >&2
        return 1
    fi

    echo "$found_keys"
}

# Function to extract signing key ID and fingerprint from verification output
get_signing_key_info() {
    local verify_output="$1"

    # Extract signing key ID from verification output
    local key_id
    key_id=$(echo "$verify_output" | grep -E "(Good signature|using)" | \
             sed -n 's/.*key ID \([A-F0-9]*\).*/\1/p' | head -1)

    # Fallback extraction method
    if [[ -z "$key_id" ]]; then
        key_id=$(echo "$verify_output" | grep "using" | awk '{print $NF}')
    fi

    if [[ -n "$key_id" ]]; then
        echo "$key_id"

        # Also try to get the full fingerprint for this key
        local fingerprint
        fingerprint=$(gpg --list-keys --with-colons --fingerprint "$key_id" 2>/dev/null | awk -F: '/^fpr:/ {print $10}' | head -1)
        if [[ -n "$fingerprint" && "$fingerprint" != "$key_id" ]]; then
            echo "$fingerprint"
        fi
    fi
}

# Input validation
if [[ $# -ne 2 ]]; then
    echo -e "${RED}✗ FAILED${NC}: Usage: $0 <signature_file> <file_to_verify>"
    exit 1
fi

SIG_FILE=$1
FILE=$2

# Check if files exist
if [[ ! -f "$SIG_FILE" ]]; then
    echo -e "${RED}✗ FAILED${NC}: Signature file not found: $SIG_FILE"
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo -e "${RED}✗ FAILED${NC}: File to verify not found: $FILE"
    exit 1
fi

# Perform initial GPG verification to get signer info
echo "Verifying GPG signature..."
if ! VERIFY_OUTPUT=$(gpg --keyid-format long --verify "$SIG_FILE" "$FILE" 2>&1); then
    echo -e "${RED}✗ FAILED${NC}: GPG verification failed on $FILE using $SIG_FILE"
    exit 1
fi

# Extract signer email from verification output
if ! SIGNER_EMAIL=$(get_signer_email "$VERIFY_OUTPUT"); then
    echo -e "${YELLOW}⚠ WARNING${NC}: Could not extract signer email, will check signing key directly"

    # Extract signing key info for direct verification
    mapfile -t SIGNING_KEY_INFO < <(get_signing_key_info "$VERIFY_OUTPUT")

    if [[ ${#SIGNING_KEY_INFO[@]} -eq 0 ]]; then
        echo -e "${RED}✗ FAILED${NC}: Could not extract GPG key ID from verification output"
        exit 1
    fi

    echo -e "${GREEN}✓ SUCCESS${NC}: GPG verification succeeded on $FILE using key ${SIGNING_KEY_INFO[0]} (email verification skipped)"
    exit 0
fi

echo "Found signer email: $SIGNER_EMAIL"

# Get trusted primary key IDs from keyservers
echo "Fetching trusted keys for $SIGNER_EMAIL"
if ! PRIMARY_KEY_IDS=$(import_trusted_keys "$SIGNER_EMAIL" "${KEYSERVERS[@]}"); then
    echo -e "${RED}✗ FAILED${NC}: Failed to fetch trusted keys for $SIGNER_EMAIL"
    exit 1
fi

if [[ -z "$PRIMARY_KEY_IDS" ]]; then
    echo -e "${RED}✗ FAILED${NC}: No trusted keys found for $SIGNER_EMAIL"
    exit 1
fi

# Convert to array for easier handling
mapfile -t PRIMARY_KEYS <<< "$PRIMARY_KEY_IDS"

# Get all trusted keys (primary + subkeys)
echo "Collecting all trusted key identifiers..."
mapfile -t ALL_TRUSTED_KEYS < <(get_all_trusted_keys "${PRIMARY_KEYS[@]}")

echo "Found ${#ALL_TRUSTED_KEYS[@]} trusted key identifiers"

# Extract signing key info from verification output
mapfile -t SIGNING_KEY_INFO < <(get_signing_key_info "$VERIFY_OUTPUT")

if [[ ${#SIGNING_KEY_INFO[@]} -eq 0 ]]; then
    echo -e "${RED}✗ FAILED${NC}: Could not extract GPG key ID from verification output"
    exit 1
fi

# Check if any of the signing key identifiers match any trusted key (case-insensitive)
key_trusted=false
for signing_key in "${SIGNING_KEY_INFO[@]}"; do
    for trusted_key in "${ALL_TRUSTED_KEYS[@]}"; do
        # Check for exact match or if one is contained in the other (to handle long vs short format)
        if [[ "${signing_key^^}" == "${trusted_key^^}" ]] || \
           [[ "${signing_key^^}" == *"${trusted_key^^}"* ]] || \
           [[ "${trusted_key^^}" == *"${signing_key^^}"* ]]; then
            echo "✓ Signing key verified against trusted keyring"
            key_trusted=true
            break 2
        fi
    done
done

if [[ "$key_trusted" == "false" ]]; then
    echo -e "${RED}✗ FAILED${NC}: Untrusted key used to sign $SIG_FILE: ${SIGNING_KEY_INFO[0]}"
    echo "Signer email: $SIGNER_EMAIL"
    echo "All signing key identifiers: ${SIGNING_KEY_INFO[*]}"
    echo "Trusted keys: ${ALL_TRUSTED_KEYS[*]}"
    exit 1
else
    echo -e "${GREEN}✓ SUCCESS${NC}: GPG verification succeeded on $FILE using trusted key ${SIGNING_KEY_INFO[0]} from $SIGNER_EMAIL"
    exit 0
fi
