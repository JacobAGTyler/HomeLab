#!/bin/bash

# Declare other secrets as key=op://path
secrets=(
  "redis-username=op://Developer/BunkerWebWAF/Redis/redis-username"
  "redis-password=op://Developer/BunkerWebWAF/Redis/redis-password"
  "admin-username=op://Developer/BunkerWebWAF/Admin/admin-username"
  "admin-password=op://Developer/BunkerWebWAF/Admin/admin-password"
  "flask-secret=op://Developer/BunkerWebWAF/UI/flask-secret"
  "totp-secrets=op://Developer/BunkerWebWAF/UI/totp-secrets"
  "mariadb-user=op://Developer/BunkerWebWAF/MariaDB/mariadb-user"
  "mariadb-password=op://Developer/BunkerWebWAF/MariaDB/mariadb-password"
)

# Retrieve DB credentials
db_user=$(op read "op://Developer/BunkerWebWAF/MariaDB/mariadb-user")
db_pass=$(op read "op://Developer/BunkerWebWAF/MariaDB/mariadb-password")

# Define other parts of the URI
db_host="mariadb-bw-jt-waf.bunkerweb.svc.cluster.local"
db_port="3306"
db_name="db"

# Construct URI
db_uri="mariadb+pymysql://${db_user}:${db_pass}@${db_host}:${db_port}/${db_name}"

# Encode URI
db_uri_b64=$(echo -n "$db_uri" | base64 | tr -d '\n')

# Start YAML output
cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jt-waf-secret
  namespace: bunkerweb
type: Opaque
data:
  database-uri: $db_uri_b64
EOF

# Loop through the remaining secrets
for entry in "${secrets[@]}"; do
  key="${entry%%=*}"
  path="${entry#*=}"
  value=$(op read "$path" 2>/dev/null)

  if [[ -z "$value" ]]; then
    echo "  $key: MISSING" >&2
  else
    encoded=$(echo -n "$value" | base64 | tr -d '\n')
    echo "  $key: $encoded"
  fi
done