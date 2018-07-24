# Lightning-Framework
Using a base Lightning Component, a Lightning interface, Apex Classes and an SObject to store apex errors, this framework provides a way to speed up lightning develpment while providing robust error handling that will aid debugging.


## Main Components:
* CmpBase - Base Lightning Component that performs standard error handling. **_All Lightning Components must extend this component_**. 

* IntBase - **_Lightning Interface that all Lightning Components must implement_**. This contains the method named **_"init"_** that will be called by CmpBase once it has completed its init handling.  **_All components must create a handler for this method 
instead of using the standard Lightning "init" event_**.

* AuraReturn.cls - **_All Lightning controller methods must extend this class to use as a return value to the component._** This class contains a member **_(auraerror)_** that the CmpBase component checks in order to see if errors occurred in the controller. When an exception occurs, call the **_"handleException"_** method of this this class to populate auraerror with the exception message.

* Log.cls - Class that has methods for logging messages and handling exceptions.  When exceptions occur, call the **_Log.notify()_** method. This will create a record in the Application_Error__c object which has a workflow and email alert set up to send emails.  Instead of **_System.debug()_**, use the **_Log.log()_** method. This will do the System.debug(), but also store the messages so that they can be seen on the Application_Error__c record and in the email sent.

* DeviceInformation.cls - Class that holds the information such as the browser and operation system of the running user.  This information is added to the Application_Error__c record by the **_Log.notify()_** method.

* SchdDeleteApplicationErrors.cls - Schedulable, Batchable class that deletes older Appication_Error__c records. 

* Application_Error__c SObject. The **_Log.notify()_** method creates records in this Object when exceptions occur. Contains information about the running user, the user's device, debug statements that have been logged using the **_Log.log()_** method, and the details of the exception.  

* Application__Error_c.Application Error Notify - Workflow Rule. When an Application_Error__c record is created, this rule causes an email to fire. **_NOTE - modify this rule to set up the recipients (and change sender if required)._**

## Install Steps:
* Use the botton below to deploy the code to your org:

<a href="https://githubsfdeploy.herokuapp.com?owner=veenasundara&repo=Lightning-Framework">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

* Assign permission set **_OpFocus Lightning Framework_** to users who will view the Applcation_Error__c Object and run the scheduled job to clear errors

* Edit the **_Application__Error_c.Application Error Notify_** Workflow Rule to set up the recipients and sender for the email alert. These recipients will receive errors when Application_Error__c records with **_Log Level_** of **_ERROR_** are created.

* Schedule the apex class **_SchdDeleteApplicationErrors_**. Do this manually from the UI, or run **_SchdDeleteApplicationErrors.schedule()_** from anonymous apex to have it run at 1 am every night. (You can use **_SchdDeleteApplicationErrors.manual()_** to run it one time manually from anonymous apex).

* Optional Step - Normally, Application_Error__c records are deleted after 30 days.  If you want to change this, Edit the **_Application_Error__c_** object's field **_Save Until_**. The default value for this field is set as **_TODAY() + 30_**. Change this as desired to control how long Application_Error__c records are retained.

* In your Lightning components that are developed using this framework, use the method **_component.success(message, mode)_** in your helper to display success toasts. Values for mode are the same as for the **_force:showToast_** event (pester','sticky','dismissible'). 'dismissible' is the default, so if you want that mode, you do not need to pass the second argument (**_component.success(message)_**). Similary, to show error toasts, use the method **_component.error(message, mode)_**.

* Use the templates below to begin coding. 

#### Lightning Component Template
```
<!-- Component: 	 -->
<!-- Created by: 	YOUR NAME HERE on <Date> -->
<!-- Description: 	 -->
<aura:component extends="c:CmpBase" <!-- Base Component that performs error handling -->
                implements="c:Intbase" <!-- Interface that defines init method that CmpBase calls after it completes its "init" work -->
                access="global">

    <!-- default toast message mode to "dismissable" -->
    <aura:attribute name="toastMode" type="String" default="dismissable"/>
</aura:component>
```

#### Lightning Javascript Controller Template
```
({
    init : function(component, event helper) {
    	// DO YOUR INIT PROCESSING HERE
    	helper.hlpInit(component);
    },
})
```

#### Lightning Helper Template
```
({
    hlpInit : function(component) {

        try
        {   
            // set server-side method
            component.setAction(component.get('c.ctrlInit'));

            // set callbacks
            component.setCallback(
                // successful callback
                function(cmp, res){
                    this.handleSuccessInitResult(cmp, res);
                },
                // error callback
                function(cmp, res){
                    this.handleErrorInitResult(cmp, res);
                }
            )

            // fire server-side method
            component.run();
            
        }
        catch(e)
        {
    	    // CmpBase method that will show an error toast. If you do not want it to
    	    // stick, eliminate the second argument
            component.error('hlpInit - ' + e.message, 'sticky');
        }
    },

    handleSuccessInitResult(component, result)
    {
        component.success('Success!', 'dismissable')
        // handle result from server
    },

    handleErrorInitResult(component, result)
    {
        // handle result from server
    }
})
```

#### Lightning Apex Controller Template
```
/* Class:       
** Created by:  YOUR NAME HERE on <Date>
** Description: Controller for Lightning Component <Lightning Component Name>
*/
public with sharing class CompCtrl
{
    // All controller methods MUST include the deviceInfoStr parameter to pass to the
    // Log.notify() method to populate in Application_Error__c when exceptions occur.
    // All Lightning components must return a class that extends the AuraReturn Class
    @AuraEnabled
    public static CompReturn ctrlInit(String deviceInfoStr)
    {
        CompReturn retVal = new CompReturn();
        try
        {
            // ADD YOUR CODE HERE
            
            return retVal;
        }
        catch(Exception e)
        {
            // Populates auraerror which is used by CmpBase to detect errors
            retVal.handleException(e); 

            // Creates an Application_Error__c record which will cause email to be sent
            Log.notify(e, 'CompCtrl ctrlInit', DeviceInformation.deserialize(deviceInfoStr));
        }
        return retVal;
    }

    // All Lightning components must return a class that extends the AuraReturn Class
    public class CompReturn extends AuraReturn
    {
        // ADD MEMBERS FOR YOUR RETURN VALUES HERE
    }
}
```

#### Available Methods

* success(msg [,toastMode])         => success toast message
* info(msg [,toastMode])            => info toast message
* warn(msg [,toastMode])            => warning toast message
* error(msg [,toastMode])           => error toast message
* showSpinner(size)                 => shows lightning spinner
* hideSpinner()                     => hides lightning spinner
* setAction(action)                 => sets server-side controller method
* setParams(params)                 => sets action parameters
* setCallback([onsuccess, onfail])  => sets function callbacks after server response is parsed
* run()                             => enqueues action to server


#### Available Attributes
* keepSpinnerInside (boolean)       => Keeps the lightning spinner inside the component body. defaults to true
* spinner (boolean)                 => Whether to use spinner when waiting for response from server. defaults to true
* deviceInfoName (string)           => Name of the server method parameter for device information json string. defaults to "deviceInfoStr"
* toastMode (string)                => defaulted toast message mode. defaults to "sticky"