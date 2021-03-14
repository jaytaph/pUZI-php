#!/bin/bash

source supporting_functions.sh

export CERTTYPE=${CERTTYPE:-vertrouwelijkheidcertificaat}

export TITLE="${TITLE:-physician}"
export SERIALNUMBER="${SERIALNUMBER:-1337}"
export GIVENNAME="${GIVENNAME:-Jan}"
export SURNAME="${SURNAME:-Zorg}"

export I_NAMESPACE="UZI-register_Zorgverlener_CA_G21_intermediate"
export NAMESPACE="UZI-register_Zorgverlener_CA_G21_GENERIC_USER_${PASSTYPE}_${CERTTYPE}_${SERIALNUMBER}_${TITLE}_${SPECIALISM:-none}_${GIVENNAME}_${SURNAME}"


openssl genrsa -out "${NAMESPACE}.key" ${CERTKEYSIZE:-2048}
openssl req -new \
    -key "${NAMESPACE}.key" \
    -subj "/C=NL/O=GBIC/serialNumber=${SERIALNUMBER}/title=${TITLE}/SN=${SURNAME}/GN=${GIVENNAME}/CN=${GIVENNAME} ${SURNAME}" \
    -nodes \
    -set_serial 0x$(openssl rand -hex 16) \
    -out "${NAMESPACE}.csr" || exit 1

echo -n "CSR Generated: "
openssl req -noout -subject -in "${NAMESPACE}.csr"


# Run support script to create OpenSSL config
./test_script_support_create_config.sh


openssl x509 -req \
    -in "${NAMESPACE}.csr" \
    -CA "${I_NAMESPACE}.pem" \
    -CAkey "${I_NAMESPACE}.key" \
    -CAcreateserial \
    -days 898 \
    -set_serial 0x$(openssl rand -hex 16) \
    -extensions uzi_main \
    -extfile "${NAMESPACE}.config" \
    -out "${NAMESPACE}.pem" || exit 1

display_certificate "${NAMESPACE}.pem"
