---
typora-copy-images-to: ./images
---

## 1. Getting familiar with tools

## [Red Hat CodeReady Workspaces](https://developers.redhat.com/products/codeready-workspaces/overview)

Built on the open Eclipse Che project, Red Hat CodeReady Workspaces uses Kubernetes and containers to provide any member of the development or IT team with a consistent, secure, and zero-configuration development environment. The user experience is as fast and familiar as an integrated development environment (IDE) on their laptop.

CodeReady Workspaces is included in OpenShift® and is available in the OpenShift Operator Hub. Once deployed, CodeReady Workspaces provides development teams a faster and more reliable foundation on which to work, and it gives operations centralised control and peace of mind.

Open the following link in new tab

http://codeready-openshift-workspaces.%cluster_subdomain%
<!--http://codeready-toolchain-workspaces.%cluster_subdomain%-->


### 1.1 Navigating with Red Hat CodeReady Workspaces

On day 1, you feel like exploring the IDE and tools used in the company.

1. Login using %username% / openshift

![image-20201208205847496](./images/image-20201208205847496.png)

2. When prompt, choose "Allow selected permissions".

![image-20201209115218644](./images/image-20201209115218644.png)



3. Following warning message is due to SSL is self-signed cert, Choose "Send anyway"

![image-20201209115237058](./images/image-20201209115237058.png)

4. Fill in the information about yourself. No worry, data will automatically dispose after the workshop

![image-20201209115253973](./images/image-20201209115253973.png)



5. From the left menu, choose "+ Get started"

![image-20201209115307702](./images/image-20201209115307702.png)

6. Choose "Java quarkus", a wait for the workspace to spawn.(It will take a while)

![image-20201209115319178](./images/image-20201209115319178.png)



7. You will see something familiar if you are vscode user. Choose the "Explorer" icon

![image-20201209115335604](./images/image-20201209115335604.png)



8. Expand the "quarkus-quickstarts" project by clicking the folder.

![image-20201209115349130](./images/image-20201209115349130.png)

9. Choose "Excluse globally" when prompt to excluse the project settings files from file explorer

![image-20201221135151096](./images/image-20201221135151096.png)

### 1.2 Debuggubg with Red Hat CodeReady Workspaces

1. From the top menu, choose Terminal > Open Terminal in specific container.

![image-20201208224541410](./images/image-20201208224541410.png)

2. When prompt, choose "maven"

![image-20201208224735281](./images/image-20201208224735281.png)

3. A new terminal appear at the bottom of code editor

![image-20201208224836211](./images/image-20201208224836211.png)

4. In the Terminal. Run the following command

```copy
cd /projects/quarkus-quickstarts/getting-started/
mvn compile quarkus:dev
```

![image-20201208225125354](./images/image-20201208225125354.png)

5. Wait for maven to download all the dependencies. You will see 2 message prompt, click "yes" for the message with port 8080

![image-20201208225542871](./images/image-20201208225542871.png)

6. Close the message with port 5005, you don't need to expose the port for debugger.

![image-20201221135712328](./images/image-20201221135712328.png)

7. New message appear indicating redirect is enabled to port 8080 . Click "Open Link"

![image-20201208225847683](./images/image-20201208225847683.png)

7. New windows appear from the right hand side of the workspace. Click the "Open in new windows" icon

![image-20201208230228982](./images/image-20201208230228982.png)

8. Test the API by adding "/hello/greeting/john" at the end in the browser address.

![image-20201208230614743](./images/image-20201208230614743.png)

9. Navigate to "quarkus-quikstarts/getting-started/src/main/java/org/acme/getting/started/GreetingResource.java". Right click the service.greeting() method in line 21 and choose "Go to Implementations".

![image-20201208222344637](./images/image-20201208222344637.png)


10. You should be inside GreetingService.java. Replace the greeting java method with the following code

```copy
public String greeting(String name) {
        String s = "Hola " + name.toUpperCase();
        return s;
    }
```

11. Notice that the auto complete will prompt for suggestion after you press "."

![image-20201208223144337](./images/image-20201208223144337.png)


12. Create a breakpoint at the line before exit the method. which is line with" return s;" (We will come back to this later.)

![image-20201208223621041](./images/image-20201208223621041.png)


13. From the top menu, **choose Debug > Start Debugging**

![image-20201208223827917](./images/image-20201208223827917.png)

14. The debug panel from the left will auto show up

![image-20201209115846477](./images/image-20201209115846477.png)



15. **Reload the page with the API call** (to trigger the breakpoint)

![image-20201208231643417](./images/image-20201208231643417.png)

16. Go back to the Codeready workspace and notice that the debug pointer stop at your breakpoint.

![image-20201208231922944](./images/image-20201208231922944.png)

17. **Mouseover the variable "s"** and you should able to peek the value "Hola JOHN"

![image-20201208232121017](./images/image-20201208232121017.png)

18. Notice the shortcut to "Continue", "Step Over", "Step Into", "Step Out" is now available, **Choose "Continue" to complete the request.**

![image-20201208232438546](./images/image-20201208232438546.png)

### 1.3 Coding with Red Hat CodeReady Workspaces

1. Change the greeting method inside GreetingService.java as following

```copy
public String greeting(String name) {
        int ap = Calendar.getInstance().get(Calendar.AM_PM);
        String s = null;
        if(Calendar.AM == ap){
            s = "Good morning! " + name.toUpperCase();
        }else{
            s = "Good day! " + name.toUpperCase();
        }
        return s;
    }
```

2. If you copy and paste the code, you will notice there is red line below the "Calendar" (indicating missing import).

![image-20201208233706402](./images/image-20201208233706402.png)

3. Fix the problem by importing the Calendar class

![image-20201208234531163](./images/image-20201208234531163.png)

4. Quarkus support hot-reload (Yes, you don't need to restart the service). Save the file changes and test your API again by reloading the test page.

![image-20201208234727895](./images/image-20201208234727895.png)

5. When you done. Stop the program by press Ctrl + C in the terminal.

![image-20201209001425584](./images/image-20201209001425584.png)

6. Run the unit test to make sure everything is ok.

```copy
cd /projects/quarkus-quickstarts/getting-started/
mvn test
```

![image-20201209103929989](./images/image-20201209103929989.png)

(Opps.... We forgot to change the unit test)

7. Open GreetingResourceTest.java (under /projects/quarkus-quickstarts/getting-started/test/java/org/acme/getting/started/). Replace the testGreetingEndpoint method with the following code.

```copy
@Test
    public void testGreetingEndpoint() {
        String uuid = UUID.randomUUID().toString();
        given()
                .pathParam("name", uuid)
                .when().get("/hello/greeting/{name}")
                .then()
                .statusCode(200)
                .body(
                    anyOf(
                        is("Good morning! " + uuid.toUpperCase()),
                        is("Good day! " + uuid.toUpperCase())
                    )
                );
    }
```

8. Note that codeready workspace cannot auto import the static import. you need to manually add the import for anyOf method

```copy
import static org.hamcrest.CoreMatchers.anyOf;
```

![image-20201209105437826](./images/image-20201209105437826.png)

9. Re-run the test using command **"mvn test"**, and expect to success.

![image-20201209105037480](./images/image-20201209105037480.png)

<!--
### 1.4 Upgrade the container image

1. Click on the small yellow arrow to view workspaces

![image-20201218010824606](./images/image-20201218010824606.png)



2. Click on Workspaces, follow by the current workspace

![image-20201218011014709](./images/image-20201218011014709.png)

3. Change the docker image to the latest version

```
image: 'registry.redhat.io/codeready-workspaces/plugin-java11-rhel8:latest'
```

![image-20201218011152689](./images/image-20201218011152689.png)



4. Click Save, Then apply

![image-20201218011339827](./images/image-20201218011339827.png)

-->

Congratulation. You should now familiar with the Red Hat Codeready Workspace.

### Summary

- Zero day CodeReady workspaces setup for new join developer
- Create a java application using quarkus
- Code and re-test without restart java process
- Debug the java application using CodeReady workspaces
- Edit Devfile for codeready workspaces
