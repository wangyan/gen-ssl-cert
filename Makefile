####################################################################
# 
# OpenSSL Self-signed Certificate configuration file.
# Copy to `/tmp/gen-ssl-cert/Makefile`.
# By WangYan <me@wangyan.org>
#
####################################################################

# Prepare Certificate directory
init:
	rm -rf ca/ ica/ && \
	mkdir -p  ca/certs  ca/crl  ca/csr  ca/newcerts  ca/ocsp  ca/private && \
	mkdir -p ica/certs ica/crl ica/csr ica/newcerts ica/ocsp ica/private && \
	chmod 700 ca/private ica/private && \
	touch ca/index.txt   ica/index.txt && \
	echo 1000 > ca/serial && \
	echo 01 > ica/serial && \
	echo 01 > ica/crlnumber

####################################################################
# Command List
####################################################################
##
# Self-signed Root CA Certificate
# make init
# make gen-ca-key
# make gen-ca-csr
# make gen-ca-cert
# make view-ca-cert
##
# Intermediate CA Certificate
# make gen-ica-key
# make gen-ica-csr
# make gen-ica-cert
# make view-ica-cert
# make gen-ica-chain
##
# make gen-server-key
# make gen-server-csr
# make gen-server-cert
# make view-server-cert
# make gen-server-full
##
# make gen-client-key
# make gen-client-csr
# make gen-client-cert
# make view-client-cert
# make gen-client-pkcs12
##
# make gen-ica-crl
# make gen-ica-revoke-client
##
# make gen-ocsp-key
# make gen-ocsp-csr
# make gen-ocsp-cert
# make run-ocsp-server
# make chk-ocsp-cert
##
####################################################################
# Self-signed Root CA Certificate
####################################################################

# Create CA Certificate Key
gen-ca-key:
	openssl genrsa -out ca/private/ca-key.pem 4096
	chmod 400 ca/private/ca-key.pem

# Create CA Certificate CSR file
gen-ca-csr:
	openssl req -config ca.cnf \
		-new -sha256 \
        -key ca/private/ca-key.pem \
		-subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=Selfsigned Root Certificate Authority" \
        -out ca/csr/ca-csr.pem

# Create Self-signed CA Certificate
gen-ca-cert:
	openssl ca -selfsign -config ca.cnf \
		-extensions v3_ca \
		-days 3650 -notext \
		-in ca/csr/ca-csr.pem \
		-out ca/certs/ca-cert.crt

# Verify CA Certificate
view-ca-cert:
	openssl x509 -noout -text -in ca/certs/ca-cert.crt

####################################################################
# Intermediate CA Certificate
####################################################################

# Create Intermediate CA Key
gen-ica-key:
	openssl genrsa -out ica/private/ica-key.pem 4096
	chmod 400 ica/private/ica-key.pem

# Create Intermediate CA CSR File 
gen-ica-csr:
	openssl req -config ica.cnf \
		-new -sha256 \
        -key ica/private/ica-key.pem \
		-subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=Selfsigned Intermediate Certificate Authority" \
        -out ica/csr/ica-csr.pem

# Create Intermediate CA Certificate
gen-ica-cert:
	openssl ca -config ca.cnf \
		-extensions v3_intermediate_ca \
		-days 3650 -notext \
		-in ica/csr/ica-csr.pem \
		-out ica/certs/ica-cert.crt

# Verify Intermediate CA Certificate
view-ica-cert:
	openssl x509 -noout -text -in ica/certs/ica-cert.crt
	openssl verify -CAfile ca/certs/ca-cert.crt ica/certs/ica-cert.crt

# Create CA Certificate Chain
gen-ica-chain:
	cat ica/certs/ica-cert.crt ca/certs/ca-cert.crt > \
    	ica/certs/ica-chain-cert.crt
	chmod 444 ica/certs/ica-chain-cert.crt

####################################################################
# Server Certificate
####################################################################

# Create Server Key
gen-server-key:
	openssl genrsa -out ica/private/server-key.pem -traditional 4096

# Create Server CSR File
gen-server-csr:
	openssl req -config ica.cnf \
		-new -sha256 \
        -key ica/private/server-key.pem \
		-subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=wangyan.cloud" \
        -out ica/csr/server-csr.pem \
		-addext "subjectAltName = IP:119.29.17.197,IP:101.32.204.113,DNS:wangyan.cloud,DNS:*.wangyan.cloud"

# Create Server Certificate
gen-server-cert:
	openssl ca -config ica.cnf \
		-extensions server_cert \
		-days 3650 -notext \
		-in ica/csr/server-csr.pem \
		-out ica/certs/server-cert.crt

# Verify Server Certificate
view-server-cert:
	openssl x509 -noout -text -in ica/certs/server-cert.crt
	openssl verify -CAfile ica/certs/ica-chain-cert.crt ica/certs/server-cert.crt

# Create CA Certificate Chain
gen-server-full:
	cat ica/certs/server-cert.crt ica/certs/ica-cert.crt ca/certs/ca-cert.crt > \
    	ica/certs/server-full-cert.crt
	chmod 444 ica/certs/server-full-cert.crt

####################################################################
# Client Certificate
####################################################################

# Create Client Key
gen-client-key:
	openssl genrsa -out ica/private/client-key.pem -traditional 4096

# Create Client CSR File
gen-client-csr:
	openssl req -config ica.cnf \
		-new -sha256 \
        -key ica/private/client-key.pem \
		-subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=wangyan.cloud" \
        -out ica/csr/client-csr.pem \
		-addext "subjectAltName = IP:119.29.17.197,IP:101.32.204.113,DNS:wangyan.cloud,DNS:*.wangyan.cloud"

# Create Client Certificate
gen-client-cert:
	openssl ca -config ica.cnf \
		-extensions usr_cert \
		-days 3650 -notext \
		-in ica/csr/client-csr.pem \
		-out ica/certs/client-cert.crt

# Verify Client Certificate
view-client-cert:
	openssl x509 -noout -text -in ica/certs/client-cert.crt
	openssl verify -CAfile ica/certs/ica-chain-cert.crt ica/certs/client-cert.crt

# Create PKCS12 Certificate
gen-client-pkcs12:
	openssl pkcs12 -export -out ica/certs/client-full.pfx \
    -inkey ica/private/client-key.pem -in ica/certs/client-cert.crt \
    -certfile ica/certs/ca-cert.crt -certfile ca/certs/ca-cert.crt

####################################################################
# Certificate revocation
####################################################################

# Create the CRL
gen-ica-crl:
	openssl ca -config ica.cnf -gencrl \
    	-out ica/crl/ica-crl.pem

# Revoke server certificate
gen-ica-revoke-client:
	openssl ca -config ica.cnf -revoke \
    ica/certs/client-cert.crt

####################################################################
# Online Certificate Status Protocol
####################################################################

# Create OCSP Server Key
gen-ocsp-key:
	openssl genrsa -out ica/private/ocsp-key.pem 4096

# Create OCSP Server CSR File 
gen-ocsp-csr:
	openssl req -config ica.cnf \
		-new -sha256 \
        -key ica/private/ocsp-key.pem \
		-subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=ocsp.wangyan.cloud" \
        -out ica/csr/ocsp-csr.pem

# Create OCSP Server Certificate
gen-ocsp-cert:
	openssl ca -config ica.cnf \
		-extensions ocsp \
		-days 3650 -notext \
		-in ica/csr/ocsp-csr.pem \
		-out ica/certs/ocsp-csr.crt

# Runing OCSP Server
run-ocsp-server:
	openssl ocsp -host 127.0.0.1 -port 2560 -text  \
    	-index ica/index.txt -CA ica/certs/ica-chain-cert.crt \
    	-rkey ica/private/ocsp-key.pem \
    	-rsigner ica/certs/ocsp-csr.crt

# Cheaking Client certificate
chk-ocsp-cert:
	openssl ocsp -CAfile ica/certs/ica-chain-cert.crt \
    	-url http://127.0.0.1:2560 -resp_text \
    	-issuer ica/certs/ica-cert.crt \
    	-cert ica/certs/client-cert.crt
