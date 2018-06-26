#Inputs
 
export NSX_MANAGER="10.173.13.82"
export NSX_USER="admin"
export NSX_PASSWORD='VMware1!'
 
 
 
#Global variables
 
export PI_NAME="pks-nsx-t-superuser"
 
export NSX_SUPERUSER_CERT_FILE="pks-nsx-t-superuser.crt"
export NSX_SUPERUSER_KEY_FILE="pks-nsx-t-superuser.key"
 
export NODE_ID=$(cat /proc/sys/kernel/random/uuid)
 
 
 
# Create Cert
openssl req \
-newkey rsa:2048 \
-x509 \
-nodes \
-keyout "$NSX_SUPERUSER_KEY_FILE" \
-new \
-out "$NSX_SUPERUSER_CERT_FILE" \
-subj /CN=pks-nsx-t-superuser \
-extensions client_server_ssl \
-config <(
cat /etc/ssl/openssl.cnf \
<(printf '[client_server_ssl]\nextendedKeyUsage = clientAuth\n')
) \
-sha256 \
-days 730
 
# Register Cert
cert_request=$(cat <<END
{
"display_name": "$PI_NAME",
"pem_encoded": "$(awk '{printf "%s\\n", $0}' $NSX_SUPERUSER_CERT_FILE)"
}
END
)
 
curl -k -X POST \
"https://${NSX_MANAGER}/api/v1/trust-management/certificates?action=import" \
-u "$NSX_USER:$NSX_PASSWORD" \
-H 'content-type: application/json' \
-d "$cert_request"

export CERTIFICATE_ID="67017e14-2814-45b1-b70a-91683275e394"
 
 
 
# Register PI
pi_request=$(cat <<END
{
"display_name": "$PI_NAME",
"name": "$PI_NAME",
"permission_group": "superusers",
"certificate_id": "$CERTIFICATE_ID",
"node_id": "$NODE_ID"
}
END
)
 
curl -k -X POST \
"https://${NSX_MANAGER}/api/v1/trust-management/principal-identities" \
-u "$NSX_USER:$NSX_PASSWORD" \
-H 'content-type: application/json' \
-d "$pi_request"
 
 
 
# Test if certificate and key can be used to communicate with NSX-T
curl -k -X GET \
"https://${NSX_MANAGER}/api/v1/trust-management/principal-identities" \
--cert $(pwd)/"$NSX_SUPERUSER_CERT_FILE" \
--key $(pwd)/"$NSX_SUPERUSER_KEY_FILE"
 