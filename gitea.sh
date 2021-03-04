#!/usr/bin/env bash

echo "Deploy Gitea.."
oc project lab-infra

oc adm policy add-scc-to-user anyuid system:serviceaccount:lab-infra:default

oc apply -f ./openshift/gitea.yaml -n lab-infra

sleep 20

echo "Configure app.ini"
GIT_URL=$(oc get route gitea -n lab-infra --no-headers | awk '{print $2}')
echo $GIT_URL

echo "Simulate open the git URL in browser and register the first user"
oc rsync ./openshift/data/ gitea-0:/data/

oc exec gitea-0 -- bash -c " chown git:git -R /data "

oc exec gitea-0 -- bash -c " sed -i 's/DOMAIN           = localhost/DOMAIN = $GIT_URL/g' /data/gitea/conf/app.ini "
oc exec gitea-0 -- bash -c " sed -i 's/SSH_DOMAIN       = localhost/SSH_DOMAIN = $GIT_URL/g' /data/gitea/conf/app.ini "
oc exec gitea-0 -- bash -c " sed -i 's/localhost:3000/$GIT_URL/g' /data/gitea/conf/app.ini "

oc scale statefulset gitea --replicas=0
sleep 5
oc scale statefulset gitea --replicas=1
