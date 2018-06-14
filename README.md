# Lightning-Framework

## Main Components:
* CmpBase - Base Lightning Component that performs standard error handling. **_All Lightning Components must extend this component_**. 

* IntBase - **_Lightning Interface that all Lightning Components must implement_**. This contains the method named **_"init"_** that will be called by CmpBase once it has completed its init handling.  **_All components must create a handler for this method 
instead of using the standard Lightning "init" event_**.

* AuraReturn.cls - **_All Lightning controller methods must extend this class to use as a return value to the component._** This class containsa member **_(auraerror)_** that the CmpBase component checks in order to see if errors occurred in the controller. When an exception occurs, call the **_"handleException"_** method of this this class to populate auraerror with the exception message.

* Log.cls - Class that has methods for logging messages and handling exceptions.  When exceptions occur, call the **_Log.notify()_** method. This will create a record in the Application_Error__c object which has a workflow and email alert set up to send emails.  Instead of **_System.debug()_**, use the **_Log.log()_** method. This will do the System.debug(), but also store the messages so that they can be seen on the Application_Error__c record and in the email sent.

* DeviceInformation.cls - Class that holds the information such as the browser and operation system of the running user.  This information is added to the Application_Error__c record by the **_Log.notify()_** method.

* SchdDeleteApplicationErrors.cls - Schedulable, Batchable class that deletes older Appication_Error__c records. 

* Application_Error__c SObject. The **_Log.notify()_** method creates records in this Object when exceptions occur. Contains information about the running user, the user's device, debug statements that have been logged using the **_Log.log()_** method and the details of the exception.  

* Application__Error_c.Appliction Error Notify - Workflow Rule. When an APplication_Error__c record is created, this rule causes an email to fire. **_NOTE - modify this rule to include the recipients and change sender if required._**

## Install Steps:
* Use the botton below to deploy the code to your org:

<a href="https://githubsfdeploy.herokuapp.com?owner=veenasundara&repo=Lightning-Framework">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

* Edit the Application__Error_c.Appliction Error Notify Workflow Rule to set up the recipients and sender for the email alert

* Schedule the apex class SchdDeleteApplicationErrors. Do this manually from the UI, or run **_SchdDeleteApplicationErrors.schedule()_** from anonymous apex to have it run at 1 am every night. (You can use **_SchdDeleteApplicationErrors.manual()_** to run it one time manually from anonymous apex.)

* Optional Step - Normally, Application_Error__c records are deleted after 30 days.  If you want to change this, Edit the Application_Error__c object's field "Save Until". The default value for this field is set as "TODAY() + 30". Change this as desired to control how long Application_Error__c records are saved

* If you are using an IDE that allows templates, create the following templates:

#### Lightning Component Template

