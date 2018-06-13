# Lightning-Framework

## Main Components:
<ul>
	<li>
		<b>CmpBase</b> - Base Lightning Component that performs standard error handling. <b>All Lightning Components must extend this component</b>.
	</li>
	<li>
		<b>IntBase<b> - <b>Lightning Interface that all Lightning Components must implement<b>. This contains the method named "init" that will be called by CmpBase once it has completed its init handling.  <b>All components must create a handler for this method instead of using the standard Lightning "init" event<b>.
	</li>
	<li>
		AuraReturn.cls - All Lightning controller methods must extend this class to use as a return value to the component. This class containsa member (auraerror) that the CmpBase component checks in order to check if errors occurred in the controller. When an exception, call the "handleException" method of this this class to populate auraerror with the exception message.
	</li>
	<li>
		Log.cls - Class that has methods for logging messages and handling exceptions.  When exceptions occur, call the Log.notify method. This will create a record in the ApplicationErrorc object which has a workflow and email alert set up to send emails.  Instead of System.debug, use the Log.log method. This will do the System.debug, but also store the messages so that they can be seen on the ApplicationErrorc record and in the email sent.
	</li>
	<li>
		DeviceInformation.cls - Class that holds the information such as the browser and operation system of the running user.  This information is added to the ApplicationErrorc record by the Log.notify method.
	</li>
	<li>
		SchdDeleteApplicationErrors.cls - Schedulable, Batchable class that deletes older AppicationErrorc records. Schedule this manually from the UI, or run SchdDeleteApplicationErrors.schedule(); from anonymous apex to have it run at 1 am every night. Use SchdDeleteApplicationErrors.manual(); to run it one time manually from anonymous apex.
	</li>
	<li>
		ApplicationErrorc SObject. The Log.notify() method creates records in this Object when exceptions occur. Contains information about the running user, the user's device, debug statements that have been logged using the Log.log() method and the details of the exception.  
	</li>
	<li>
		ApplicationErrorc.Appliction Error Notify Workflow Rule. When a ercord is created, this rule causes an email to fire. NOTE - modify this rule to include the recipients and change sender if required.
	</li>
</ul>


<a href="https://githubsfdeploy.herokuapp.com?owner=veenasundara&repo=Lightning-Framework">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>
