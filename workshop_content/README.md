#Quarkus workshop for Developer on Openshift Q1 2021
=====================

##To build docker locally
```bash
docker build . -t lab
```

##Quick development

```bash
docker run -p 10080:10080 -v $(pwd)/workshop:/opt/app-root/workshop lab
```

##Deployment to openshift

Create new project in openshift
```
oc new-project lab-infra
```
Import dashboard image
```
oc import-image   --confirm quay.io/openshifthomeroom/workshop-dashboard:5.0.0
```
Create build from binary
```
oc new-build  --name=dev-workshop  --binary --image-stream=workshop-dashboard:5.0.0 \
-e WORKSHOP_ONLY=true
```
Upload content and start build
```
oc start-build dev-workshop   --from-dir=.  --follow
```