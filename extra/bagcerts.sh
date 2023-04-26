#!/bin/bash
#
# This script takes one or more x509 certificates in .PEM format (from
# stdin or files listed on command line) and adds helpful "bag
# attributes" before each certificate. This makes it easier for
# humans to identify the contents of the bundle.
#
# Requires (g)awk and openssl's x509 command line utility.
#
# Output fields included can be specified via openssl-x509 options:
#
#   subject= /C=US/O=DigiCert Inc/CN=DigiCert SHA2 Secure Server CA
#   issuer= /C=US/O=DigiCert Inc/OU=www.digicert.com/CN=DigiCert Global Root CA
#   notBefore=Mar  8 12:00:00 2013 GMT
#   notAfter=Mar  8 12:00:00 2023 GMT
#   SHA256 Fingerprint=15:4C:43:3C:49:19:29:C5:EF:68:6E:83:8E:32:36:64:A0:0E:6A:0D:82:2C:CC:95:8F:B4:DA:B0:3E:49:A0:8F
#   -----BEGIN CERTIFICATE-----
#   ...
#   -----END CERTIFICATE-----

awk -vZ="openssl x509 -subject -issuer -email -dates -sha256 -fingerprint" \
    '/^-----BEGIN/{b=Z;x=1}x{print|b}/^-----END/{close(b);x=0;print""}' "$@"

