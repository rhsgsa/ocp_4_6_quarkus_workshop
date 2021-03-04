#!/usr/bin/env bash

#Deploy Code Ready Worksapce
oc apply -f ./openshift/crw.yaml

oc new-project lab-infra
oc adm policy add-scc-to-user anyuid system:serviceaccount:lab-infra:default
oc apply -f ./openshift/gitea.yaml -n lab-infra
sleep 60
GIT_URL=$(oc get route gitea -n lab-infra --no-headers | awk '{print $2}')
echo $GIT_URL
oc rsync ./openshift/data/ gitea-0:/data/
oc exec gitea-0 -- bash -c " chown git:git -R /data "
oc exec gitea-0 -- bash -c " sed -i 's/DOMAIN           = localhost/DOMAIN = $GIT_URL/g' /data/gitea/conf/app.ini "
oc exec gitea-0 -- bash -c " sed -i 's/SSH_DOMAIN       = localhost/SSH_DOMAIN = $GIT_URL/g' /data/gitea/conf/app.ini "
oc exec gitea-0 -- bash -c " sed -i 's/localhost:3000/$GIT_URL/g' /data/gitea/conf/app.ini "

sleep 5
oc scale statefulset gitea --replicas=0
sleep 5
oc scale statefulset gitea --replicas=1


#Run this in workshop-appdev folder
#oc new-project workshop
#oc import-image  --confirm quay.io/openshifthomeroom/workshop-dashboard:5.0.0
#oc new-build  --name=friday-workshop  --binary --image-stream=workshop-dashboard:5.0.0 \
#-e MY_CUSTOM_VAR=abcd

#oc start-build friday-workshop   --from-dir=.  --follow

oc process -f spawner.json \
--param SPAWNER_NAMESPACE=`oc project --short` \
--param CLUSTER_SUBDOMAIN=$(oc get route -n openshift-console console -o jsonpath='{.spec.host}' | sed -e 's/^[^.]*\.//') \
--param WORKSHOP_IMAGE=kahlai/workshop-appdev | oc apply -f -
