# Lightning-Framework

## Main Components:
* CmpBase - Base Lightning Component that performs standard error handling. **_All Lightning Components must extend this component_**. 

* IntBase - **_Lightning Interface that all Lightning Components must implement_**. This contains the method named **_"init"_** that will be called by CmpBase once it has completed its init handling.  **_All components must create a handler for this method 
instead of using the standard Lightning "init" event_**.

* AuraReturn.cls - **_All Lightning controller methods must extend this class to use as a return value to the component._** This class containsa member **_(auraerror)_** that the CmpBase component checks in order to see if errors occurred in the controller. When an exception occurs, call the **_"handleException"_** method of this this class to populate auraerror with the exception message.

* Log.cls - Class that has methods for logging messages and handling exceptions.  When exceptions occur, call the **_Log.notify()_** method. This will create a record in the Application_Error__c object which has a workflow and email alert set up to send emails.  Instead of **_System.debug()_**, use the **_Log.log()_** method. This will do the System.debug(), but also store the messages so that they can be seen on the Application_Error__c record and in the email sent.

* DeviceInformation.cls - Class that holds the information such as the browser and operation system of the running user.  This information is added to the Application_Error__c record by the Log.notify method.

* SchdDeleteApplicationErrors.cls - Schedulable, Batchable class that deletes older Appication_Error__c records. Schedule this manually from the UI, or run **_SchdDeleteApplicationErrors.schedule()_** from anonymous apex to have it run at 1 am every night. Use **_SchdDeleteApplicationErrors.manual()_** to run it one time manually from anonymous apex.

* Application_Error__c SObject. The **_Log.notify()_** method creates records in this Object when exceptions occur. Contains information about the running user, the user's device, debug statements that have been logged using the Log.log() method and the details of the exception.  

* Application__Error_c.Appliction Error Notify - Workflow Rule. When a ercord is created, this rule causes an email to fire. **_NOTE - modify this rule to include the recipients and change sender if required._**


<a href="https://githubsfdeploy.herokuapp.com?owner=veenasundara&repo=Lightning-Framework">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>
