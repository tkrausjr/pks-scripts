#Inputs
 
NSX_MANAGER="10.173.13.82"
NSX_USER="admin"
NSX_PASSWORD='VMware1!'
 
 
 
#Global variables
 
PI_NAME="pks-nsx-t-superuser"
 
NSX_SUPERUSER_CERT_FILE="pks-nsx-t-superuser.crt"
NSX_SUPERUSER_KEY_FILE="pks-nsx-t-superuser.key"
 
NODE_ID=$(cat /proc/sys/kernel/random/uuid)
 
 
 
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
 