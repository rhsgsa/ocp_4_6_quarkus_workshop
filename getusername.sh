#!/usr/bin/env bash
#oc new-app --name=redis --template=redis-persistent -p MEMORY_LIMIT=1Gi  -p DATABASE_SERVICE_NAME=redis -p REDIS_PASSWORD=redis -p VOLUME_CAPACITY=1Gi -p REDIS_VERSION=5
oc apply -f ./openshift/redis.yaml

export CLUSTER_SUBDOMAIN=$(oc get route -n openshift-console console -o jsonpath='{.spec.host}' | sed -e 's/^[^.]*\.//')

oc new-app quay.io/openshiftlabs/username-distribution:1.3 -n lab-infra --name=get-a-username  \
-e LAB_REDIS_HOST=redis  -e LAB_REDIS_PASS=redis -e LAB_TITLE="Openshift Developer Workshop" \
-e LAB_DURATION_HOURS=8h -e LAB_USER_COUNT=30 -e LAB_USER_ACCESS_TOKEN="openshift2021"  \
-e LAB_USER_PASS=openshift -e LAB_USER_PREFIX=user -e LAB_USER_PAD_ZERO=false -e LAB_ADMIN_PASS="openshiftadmin2021" \
-e LAB_MODULE_URLS="https://hosted-workshop-lab-infra.$CLUSTER_SUBDOMAIN;Access Lab" \
-e LAB_EXTRA_URLS="https://console-openshift-console.$CLUSTER_SUBDOMAIN;OpenShift Console"


oc expose service/get-a-username
