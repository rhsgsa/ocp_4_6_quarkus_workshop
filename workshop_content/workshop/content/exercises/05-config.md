---
typora-copy-images-to: ./images
---

## 5. Managing Parameter across Environment

A Kubernetes namespace provides a mechanism to scope resources in a cluster. In OpenShift, a [project](https://docs.openshift.com/enterprise/3.0/architecture/core_concepts/projects_and_users.html#projects) is a Kubernetes namespace with additional annotations.A *project* allows a community of users to organize and manage their content in isolation from other communities.

Namespaces provide a unique scope for:

- Named resources to avoid basic naming collisions.
- Delegated management authority to trusted users.
- The ability to limit community resource consumption.

### 5.1 Using Config Property

1. Create new branch for feature/config-map, Run the following command in CodeReady Workspace Terminal

```copy
cd /projects/quarkus-quickstarts/getting-started
git checkout -b features/config-map
```

2. Open application.properties and add the following line

```
greeting.message = This is Development Project.
```

![image-20201217235946834](./images/image-20201217235946834.png)

3. Open GreetingService.java and paste the following like

```copy
@ConfigProperty(name = "greeting.message")
String message;
```



![image-20201218000132387](./images/image-20201218000132387.png)

4. Start you application by running this command

```copy
cd /projects/quarkus-quickstarts/getting-started
mvn compile quarkus:dev
```

5. Verify the result

####  ![image-20201218004104000](./images/image-20201218004104000.png)

6. Use Ctrl + C to stop your application. Then Commit and push your changes to git

```copy
git add -A
git commit -m "CR3 - Use config map"
git push --set-upstream origin features/config-map
```

When prompt

- username : %username%
- password : openshift


7. Open http://gitea-lab-infra.%cluster_subdomain% in the browser. Click "New Pull Request".

![image-20201218005331029](./images/image-20201218005331029.png)

8. Choose "features/config-map" to create pull request

![image-20201218005430092](./images/image-20201218005430092.png)

9. Click "New Pull Request"

![image-20201218005522689](./images/image-20201218005522689.png)

10. Click "Create Pull Request"

![image-20201218005608062](./images/image-20201218005608062.png)

11. Click "Merge Pull Request" ( Click the second time if needed)

![image-20201218005650457](./images/image-20201218005650457.png)

12. Confirm the message and click "Merge Pull Request"

![image-20201218005732682](./images/image-20201218005732682.png)

Note that once you merge the pull request. It will trigger the Webhook and start a build

![image-20201221155302956](./images/image-20201221155302956.png)

Congratulation. You just did a GitOps again!

### 5.2 Using Config Map

Note : If you still have your openshift CLI session active . Skip to step 5

1. From the openshift console, look for "Copy Login Command" from the top right corner.

![image-20201209121507098](./images/image-20201209121507098-8197461.png)

2. Click "Display Token"

![image-20201209233045087](./images/image-20201209233045087-8197461.png)

3. Copy the login command with token and run in CodeReady Workspaces Terminal

![image-20201209233223909](./images/image-20201209233223909-8197461.png)

4. Login to openshift from your CodeReady Worspaces Terminal, Choose "y" to allow insecure connections

![image-20201209233422585](./images/image-20201209233422585-8197461.png)

5. Run the following command in CodeReady Workspaces Terminal to create config map from properties file.

```copy
oc project %username%-api-dev
oc create configmap app-config --from-file=/projects/quarkus-quickstarts/getting-started/src/main/resources/application.properties -n %username%-api-dev
```

![image-20201218000944251](./images/image-20201218000944251.png)

6. Run the following command in CodeReady Workspaces Terminal to path deployments

```copy
oc patch deployment.apps getting-started-git -n %username%-api-dev -p '{"spec": {"template": {"spec": {
"containers" : [{"name":"getting-started-git", "volumeMounts" : [{"name":"app-config","readOnly":true,"mountPath":"/deployments/config"}]}],"volumes": [{"name" : "app-config", "configMap" : {"name" : "app-config" , "items": [{"key": "application.properties", "path" : "application.properties"}]} }]}}}}'
```

![image-20201218002554300](./images/image-20201218002554300.png)

### 5.3 Config Map for UAT

1. Create config map in UAT project. Run the following command in CodeReady Workspaces Terminal

```copy
oc project %username%-api-uat
oc create configmap app-config --from-file=/projects/quarkus-quickstarts/getting-started/src/main/resources/application.properties -n %username%-api-uat
```

2. Patch the deployment to mount config map as file. Run the following command in CodeReady Workspace Terminal

```copy
oc patch dc/getting-started-git -n %username%-api-uat -p '{"spec": {"template": {"spec": {
"containers" : [{"name":"getting-started-git", "volumeMounts" : [{"name":"app-config","readOnly":true,"mountPath":"/deployments/config"}]}],"volumes": [{"name" : "app-config", "configMap" : {"name" : "app-config" , "items": [{"key": "application.properties", "path" : "application.properties"}]} }]}}}}'
```

3. In openshift console, Under "Developer" Mode, Navigate to "Config Map", Choose project "%username%-api-dev". , Choose the "app-config". Edit the Config Map yaml as shown below and click "Save"

```copy
    quarkus.mongodb.connection-string = mongodb://user1:openshift@mongodb:27017
    quarkus.mongodb.database = uatdb
    org.acme.getting.started.JokeService/mp-rest/url=http://api.icndb.com
    org.acme.getting.started.JokeService/mp-rest/scope=javax.inject.Singleton
    greeting.message = This is UAT Project
```

![image-20201218160500342](./images/image-20201218160500342.png)

### 5.5 Deploy to UAT

1. Tag the image for uat relase. tag your image as v1.3.0

```copy
oc tag getting-started-git:latest getting-started-git:v1.3.0 -n %username%-api-dev
```

2. Import the image to UAT namespace and tag it as "uat"

```copy
oc project %username%-api-uat
```

```copy
oc import-image getting-started-git:v1.3.0 --confirm --from=image-registry.openshift-image-registry.svc:5000/%username%-api-dev/getting-started-git:v1.3.0
```

3. Tag the v1.3.0 as uat

```copy
oc tag getting-started-git:v1.3.0 getting-started-git:uat
```

Note: The moment you apply the tag. Deployment will automatically happen in UAT.

Test your application

![image-20201218160536181](./images/image-20201218160536181.png)

Hint :

```
oc get route getting-started-git -n %username%-api-uat
```



### Summary

- Use configurable variable from application.properties
- Create config map from application.properties
- Maintain different config map in different projects/namespaces.
