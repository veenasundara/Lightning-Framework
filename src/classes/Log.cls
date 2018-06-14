/**
* Copyright 2017 OpFocus, Inc
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
* IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
 */
/*
** Description: Handles logging and emailing errors
*/
public with sharing class Log
{

    @TestVisible static List<LogEntry> lstLogEntry = new List<LogEntry>();
    @TestVisible static Application_Error__c ae;
    static User ru = getRunningUser();

    public ENUM ErrorType {WARNING, ERROR}

    /**
     * stores debug statement and prints to debug log
     * @param msg [debug statement]
     */
    public static void log(String msg)
    {
        LogEntry le = new LogEntry(msg);
        log(le);
    }

    /**
     * stores debug log and prints to the debug log
     * @param msg [debug statement string]
     * @param o   [debug statement object to serialize]
     */
    public static void log(String msg, Object o)
    {
        LogEntry le = new LogEntry(msg,o);
        log(le);
    }

    /**
     * inits data
     * @param msg [debug statement]
     */
    static void log(LogEntry le){
        System.debug(le.msg);
        lstLogEntry.add(le);
    }

    /**
     * Create Application_Error__c record which will cause an email to be sent to admins
     * @param errorMessage			error message that will be stored in Application_Error__c.message__c
     * @param errorRecTypeName		Application_Error__c record type name
     * @param processName				processName name
     * @param et					ErrorType (ERROR or WARNING)
     */
    public static void notify(String errorMessage, String errorRecTypeName, String processName, ErrorType et)
    {
        notify(errorMessage, errorRecTypeName, processName, null, et);
    }
    public static void notify(String errorMessage, String processName)
    {
        notify(errorMessage, null, processName, null, ErrorType.ERROR);
    }
    public static void notify(String errorMessage, String errorRecTypeName, String processName, DeviceInformation deviceInfo, ErrorType et)
    {
        startApplicationError(errorRecTypeName, processName, et);
        createApplicationError(errorMessage, deviceInfo);
    }

    /**
     * Create Application_Error__c record for exception, which will cause an email to be sent to admins
     * @param e						Exception
     * @param errorRecTypeName		Application_Error__c record type name
     * @param processName				processName name
     * @param et					ErrorType (ERROR or WARNING)
     */
    public static void notify(Exception e, String errorRecTypeName, String processName, ErrorType et)
    {
        notify(e, errorRecTypeName, processName, null, et);
    }
    public static void notify(Exception e, String processName)
    {
        notify(e, null, processName, null, ErrorType.ERROR);
    }

    /**
     * sends email on error to email addresses defined in given app's custom metadta settings
     * @param e       [exception]
     * @param appName [name of application]
     */
    public static void notify(Exception e, String errorRecTypeName, String processName, DeviceInformation deviceInfo, ErrorType et)
    {
        log('in notify: ' + et.name());
        log('exception: ' + e.getMessage() + ' :: ' + e.getStackTraceString());
        startApplicationError(errorRecTypeName, processName, et);
        createApplicationError(e,deviceInfo);
    }
    public static void notify(Exception e, String processName, DeviceInformation deviceInfo)
    {
        notify(e, null, processName, deviceInfo, ErrorType.ERROR);
    }

    /**
     * populate basic info in the Application_Error__c record ae
     * @param errorRecTypeName		Application_Error__c record type name
     * @param processName				processName name
     * @param et					ErrorType (ERROR or WARNING)
     */
    private static void startApplicationError(String errorRecTypeName, String processName, ErrorType et)
    {
        ae = new Application_Error__c();
        Schema.RecordTypeInfo rti = SObjectType.Application_Error__c.getRecordTypeInfosByName().get(errorRecTypeName);
        if(rti != null)
        {
            ae.RecordTypeId = rti.getRecordTypeId();
        }
        ae.Log_Level__c = et.name();
        ae.Process__c = processName;
    }


    /**
     * create insert Application_Error__c record ae after populating error information
     * @param errorMessage		error message (String)
     * @param deviceInfo				DeviceInformation
     */
    static void createApplicationError(String errorMessage, DeviceInformation deviceInfo)
    {

        // get info from exception object
        ae.Message__c = errorMessage;

        createApplicationError(deviceInfo);
    }

    /**
     * creates application_error__c record
     * @param e   [exception thrown]
     * @param deviceInfo [device information from lightning]
     */
    static void createApplicationError(Exception e, DeviceInformation deviceInfo)
    {

        // get info from exception object
        ae.Type__c = e.getTypeName();
        ae.Message__c = e.getMessage();
        ae.Stack_Trace__c = e.getStackTraceString();

        createApplicationError(deviceInfo);
    }

    static void createApplicationError(DeviceInformation deviceInfo)
    {
        // get items from LogEntry list
        String bc ='';
        for(LogEntry le : lstLogEntry)
        {
            bc += '=>>>  ' + le.msg + '\n';
        }
        ae.Breadcrumbs__c = bc;

        // get running user details
        ae.Running_User_Name__c = ru.FirstName + ' ' + ru.LastName;
        ae.Running_User__c = ru.Id;
        ae.Running_User_Email__c = ru.Email;
        ae.Running_User_Profile__c = ru.Profile.Name;
        ae.Running_User_Title__c = ru.Title;
        ae.Running_User_Role__c = ru.UserRole.Name;

        // get device info
        deviceInfo = deviceInfo == null ? new DeviceInformation() : deviceInfo;
        ae.Browser__c = deviceInfo.browser;
        ae.OS__c = deviceInfo.os ;
        ae.Device__c = deviceInfo.devicetype ;

        // get url information
        if(URL.getCurrentRequestUrl() != null)
        {
            ae.Current_Page__c = URL.getCurrentRequestUrl().toExternalForm() ;
        }
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getHeaders() != null)
        {
            ae.Page_Headers__c = JSON.serializePretty(ApexPages.currentPage().getHeaders());
        }

        // allow field truncation
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.AllowFieldTruncation = true;
        // silently continue wth no error handling
        Database.insert(ae,opts);

        // if insert was successful and there are log lstLogEntry,
        // store log in attachments. breadcrumbs could be truncated
        // so this allows full debug log
        if(ae.Id != null && !lstLogEntry.isEmpty())
        {
            ae.RecalculateFormulas();
            Attachment a = new Attachment();
            a.ParentId = ae.Id;
            a.Name = ae.Id + '.log';
            a.Body = Blob.valueOf(ae.Breadcrumbs__c);
            Database.insert(a,false);
        }
    }

    /**
     * returns the running user record
     * @return [running user]
     */
    public static User getRunningUser()
    {
        if(ru == null)
        {
            ru = [SELECT
                            FirstName, LastName, Email, Title, Profile.Name, UserRole.Name
                    FROM
                            User
                    WHERE
                            Id = :UserInfo.getUserId()];
        }
        return ru;
    }


    /**
     * wrapper class for debug statements
     */
    public class LogEntry
    {
        public String msg;

        public LogEntry(String m)
        {
            this.msg = m;
        }

        public LogEntry(String m, Object o)
        {
            this.msg = m + ' ';
            try
            {
                this.msg += JSON.serializePretty(o).unescapeEcmaScript();
            }
            // if object is not serializable, parse to string instead
            catch(System.JSONException e)
            {
                this.msg += String.valueOf(e);
            }
        }
    }
}