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
