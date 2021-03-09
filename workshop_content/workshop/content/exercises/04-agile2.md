---
typora-copy-images-to: ./images
---

## 4. Agile Development - Part 2

In Part 1 , you've received change request  from user.
The requirements is as following :
1. Tell a joke after you greet.
2. Remember the joke you told before, apologies if you repeated your joke.

You have done first features and deploy into UAT as v1.1.0

- features/joke  <-- v1.1.0
- features/remember-joke

### 4.2.1 Self service for Database

Next features release is to remember the joke.

You will need some data persistence mechanism. For this, we will use mongodb for our data. Openshift leverage the kurbertes container orchestration capability. With the rich variety of docker image available in quay.io and docker hub. It is easy to find a suitable DB docker image to quickly spin up and use to development. (Note : This approach is for development and quick POC purpose. For production, it is recommended to use mongo operator that come with openshift to manage the mongo cluster, version upgrade and many more) For more information please refer to [mongo operator in openshift](https://www.mongodb.com/partners/redhat),


Note : If your openshift session in CodeReady Workspaces Terminal is disconnected. You and obtain a new token using the following steps.
Otherwise, proceed to step 4

1.From the openshift console, look for "Copy Login Command" from the top right corner.

![image-20201209121507098](./images/image-20201209121507098-8043387.png)

Click "Display Token"

![image-20201209233045087](./images/image-20201209233045087-8043387.png)

2. Copy the login command with token and run in CodeReady Workspaces Terminal

![image-20201209233223909](./images/image-20201209233223909-8043387.png)

3. Login to openshift from your CodeReady Worspaces Terminal, Choose "y" to allow insecure connections

![image-20201209233422585](./images/image-20201209233422585-8043387.png)

4. To create a mongodb using "oc apply -f", run the following command in CodeReady Workspaces Terminal

```copy
oc project %username%-codeready
oc process -f https://raw.githubusercontent.com/kahlai/sample/master/mongo-template.yaml -p user=%username% -p password=openshift | oc apply -f -
```

Note : This is a quick and dirty way of creating any kind of database in development environment. For production, please use operators of the database come with Openshift Marketplace.

5. Check and verify the pod are running (wait for all pods to turn into running state.)

```copy
oc get pods
```

![image-20201217140836167](./images/image-20201217140836167.png)

Note : What you just did was install a mongoDB and mongo-express web client using docker container image.

6. Copy the url to the mongo-expres. Open it in the web browser
```copy
oc get route mongo-express
```

![image-20201217143844422](./images/image-20201217143844422.png)

You should be able to see mongo-express

![image-20201217143934788](./images/image-20201217143934788.png)

Leave it there for now. We will use to inspect the data later.

### 4.2.2 Start Coding


1. Create new branch for new feature

```copy
cd /projects/quarkus-quickstarts/getting-started
git checkout -b features/remember-joke
```




1. You will need a mongo client library to connect to mongodb. Open pom.xml (under /projects/quarkus-quickstart/getting-started/ folder). Then add the following section into maven dependencies

```copy
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-mongodb-panache</artifactId>
</dependency>
```

![image-20201217144403033](./images/image-20201217144403033.png)

1. To define the mongo connection string. Copy and paste the following properties into "**application.properties**" file (under /projects/quarkus-quickstart/getting-started/main/resources/ folder)

```copy
quarkus.mongodb.connection-string = mongodb://%username%:openshift@mongodb:27017
quarkus.mongodb.database = devdb
```

![image-20201217144546660](./images/image-20201217144546660.png)

1. Create a new File name "**PersonJoke.java**"  (under /projects/quarkus-quickstart/getting-started/main/java/org/acme/getting/started/ folder)

```copy
package org.acme.getting.started;

import java.util.List;
import java.time.LocalDate;
import java.util.ArrayList;

import org.bson.codecs.pojo.annotations.BsonId;
import org.bson.codecs.pojo.annotations.BsonProperty;

import io.quarkus.mongodb.panache.MongoEntity;
import io.quarkus.mongodb.panache.PanacheMongoEntityBase;

@MongoEntity(collection="person_jokes")
public class PersonJoke extends PanacheMongoEntityBase{

    @BsonId
    public String name;

    public List<String> oldJokes;

    @BsonProperty("created_date")
    public LocalDate createdDate;

    public PersonJoke() {
      oldJokes = new ArrayList<String>();
      createdDate = LocalDate.now();
    }

}

```

![image-20201217145423251](./images/image-20201217145423251.png)

9. Now you ready to save some record into mongodb. Copy and replace the content into GreetingService.java

```copy
package org.acme.getting.started;


import java.util.Calendar;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.rest.client.inject.RestClient;

@ApplicationScoped
public class GreetingService {


    @Inject
    @RestClient
    JokeService jokeService;

    String message="";

    public String greeting(String name) {

        int ap = Calendar.getInstance().get(Calendar.AM_PM);
        String s = message;
        if(Calendar.AM == ap){
            s =  s + " Good morning! " + name.toUpperCase();
        }else{
            s = s + " Good day! " + name.toUpperCase();
        }

        s = tellJoke(name,s);
        return s;
    }

    public String tellJoke(String name, String s){
        Joke joke = jokeService.random();
        if(joke!=null && joke.value!=null && joke.value.joke!=null ){

            PersonJoke pj = PersonJoke.findById(name.toUpperCase());
            if(pj==null){
                pj = new PersonJoke();
                pj.name = name.toUpperCase();
            }
            if(pj.oldJokes.contains(joke.value.id)){
                s = s + ". Sorry for the old jokes but..." + joke.value.joke;
            }else{
                pj.oldJokes.add(joke.value.id);
                s = s + ". " + joke.value.joke;
            }
            PersonJoke.persistOrUpdate(pj);            
        }   
        return s;
    }

}

```

![image-20201217145533714](./images/image-20201217145533714.png)

Start the application in CodeReady Workspace Terminal using command

```copy
cd /projects/quarkus-quickstarts/getting-started/
mvn compile quarkus:dev
```

Try and fire a request. Get some jokes.

Go back to the mongo-express in your browser. You notice a new DB appear.

![image-20201217150052988](./images/image-20201217150052988.png)

Click into the collection "**person_jokes**" and inpect the content.

![image-20201217150422253](./images/image-20201217150422253.png)

Notice that john now received joke with id "62" (Result may vary depends which joke you got)

![image-20201217150603295](./images/image-20201217150603295.png)



Do not forget to commit your change to git branch features/remember_jokes

```copy
git add -A
git commit -m "CR2 - Remember old joke"
git push --set-upstream origin features/remember-joke
```



14. When prompt for username and password

- Username : %username%
- Password : openshift

![image-20201209182917844](./images/image-20201209182917844.png)

Note : Since you are pushing to features branch. Build will not happen yet.



### 4.2.2 New version release, rolling out!

1. Create the mongoDB and express in development namespace

```
oc project %username%-api-dev
oc process -f https://raw.githubusercontent.com/kahlai/sample/master/mongo-template.yaml -p user=%username% -p password=openshift | oc apply -f -
```

Now that you are ready to release your second features, create a pull request and merge it to master branch.

2. Open http://gitea-lab-infra.%cluster_subdomain% in the browser. Click "New Pull Request".

![image-20201217165525154](./images/image-20201217165525154.png)

3. Choose "features/joke/" to create pull request

![image-20201217165744787](./images/image-20201217165744787.png)

4. Click "New Pull Request"

![image-20201217165919386](./images/image-20201217165919386.png)

5. Click "Create Pull Request"

![image-20201217170101551](./images/image-20201217170101551.png)

6. Click "Merge Pull Request" ( Click the second time if needed)

![image-20201217170234480](./images/image-20201217170234480.png)

7. Confirm the message and click "Merge Pull Request"

![image-20201217170406589](./images/image-20201217170406589.png)

Note that once you merge the pull request. It will trigger the Webhook and start a build

![image-20201221153309195](./images/image-20201221153309195.png)

Congratulation. You just did a GitOps again!

8. Get your url,open your browser and test your application and make sure changes is deployed.

```copy
oc project %username%-api-dev
```

```copy
oc get route getting-started-git
```


### 4.2.3 Deploy to UAT


1. Create the mongoDB and express in UAT

```copy
oc project %username%-api-uat
oc process -f https://raw.githubusercontent.com/kahlai/sample/master/mongo-template.yaml -p user=%username% -p password=openshift | oc apply -f -
```

2. Prepare the latest the image for uat relase,  tag your latest image as v1.2.0

```copy
oc tag getting-started-git:latest getting-started-git:v1.2.0 -n %username%-api-dev
```

4. Import the image to UAT namespace and tag it as "uat"

```copy
oc project %username%-api-uat
```

```copy
oc import-image getting-started-git:v1.2.0 --confirm --from=image-registry.openshift-image-registry.svc:5000/%username%-api-dev/getting-started-git:v1.2.0
```

5. Tag the v1.2.0 as uat

```copy
oc tag getting-started-git:v1.2.0 getting-started-git:uat
```

Note: The moment you apply the tag. Deployment will automatically happen in UAT.

![image-20201221154726976](./images/image-20201221154726976.png)




(Optional) You can always rollback to previous version v1.1.0 (Without remember jokes)

```copy
oc tag getting-started-git:v1.1.0 getting-started-git:uat
```

6. Get your uat url, open your browser and test your application and make sure changes is deployed.

```copy
oc project %username%-api-dev
```

```copy
oc get route getting-started-git
```



### Summary

- You manage to self provision a mongodb
- You manage to self provision a mongo-express
- You connect your application to the mongodb and insert new record.
- You completed and delivered user change request and user is happy.
