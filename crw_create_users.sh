#!/bin/bash

# Note: When provisioning the CRW custom resource, set
# .spec.auth.openShiftoAuth to false

KEYCLOAK_URL="https://$(oc get route/keycloak -n openshift-workspaces -o jsonpath='{.spec.host}')"
CHE_URL="https://$(oc get route/codeready -n openshift-workspaces -o jsonpath='{.spec.host}')"
API_SERVER=$(oc whoami --show-server)

USER=user1
PASSWORD=openshift


# admin password is from secret/che-identity-secret
ADMIN_PASSWORD=$(oc get secret/che-identity-secret -n openshift-workspaces -o yaml | grep -v 'f:' | grep 'password:' | awk '{ print $2 }' | base64 -d)

# Get access token for admin user
ACCESS_TOKEN=$(curl -k --silent -i -XPOST -H "Content-Type: application/x-www-form-urlencoded" ${KEYCLOAK_URL}/auth/realms/master/protocol/openid-connect/token -d 'username=admin&password='"$ADMIN_PASSWORD"'&grant_type=password&client_id=admin-cli' | grep -o '"access_token":"[^"]' | sed -e 's/."//')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Could not get admin access token"
  exit 1
fi

echo "Access Token: $ACCESS_TOKEN"

# Add user to Che
RETURN_CODE=$(curl -k --silent -o /dev/null -w "%{http_code}" -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" ${KEYCLOAK_URL}/auth/admin/realms/codeready/users -d '{"username":"'"$USER"'","enabled":"true","emailVerified":"true","firstName":"'"$USER"'","lastName":"Developer","email":"'"$USER"'@no-reply.com","credentials":[{"type":"password","value":"'"$PASSWORD"'","temporary":"false"}]}')

# 201 means that the user was created successfully, 409 means the user already exists
if [ "$RETURN_CODE" != "201" -a "$RETURN_CODE" != "409" ]; then
  echo "Could not create user $USER - return code was $RETURN_CODE"
  exit 1
fi

echo "$USER created"

# Get access token for user
ACCESS_TOKEN=$(curl -k --silent -i -XPOST -H "Content-Type: application/x-www-form-urlencoded" ${KEYCLOAK_URL}/auth/realms/codeready/protocol/openid-connect/token -d 'username='"$USER"'&password='"$PASSWORD"'&grant_type=password&client_id=admin-cli' | grep -o '"access_token":"[^"]' | sed -e 's/."//')


if [ -z "$ACCESS_TOKEN" ]; then
  echo "Could not get $USER access token"
  exit 1
fi

# Create workspace for user
#RETURN_CODE=$(curl -k --silent -o /dev/null -w "%{http_code}" -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" "${CHE_URL}/api/workspace/devfile?start-after-create=true&namespace=$USER" -d "@devfile.json")

#echo "Return code was $RETURN_CODE"

curl -k --silent -v -w "%{http_code}" -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" "${CHE_URL}/api/workspace/devfile?start-after-create=true&namespace=$USER" -d "@devfile.json"