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
** Description: Delete Application_Error__c records that are saved unit today
*/
global class SchdDeleteApplicationErrors implements Schedulable, Database.Batchable<SObject>, Database.Stateful {

    // -------------------------------------------------------------------------------------
    // ---------------- Schedulable Part ---------------------------------------------------
    // -------------------------------------------------------------------------------------

    // use this method to schedule this job
    public static void schedule() {
        String cronText = '0 0 1  ? * * *';
        String jobName = 'SchdDeleteApplicationErrors 1am';
        if(Test.isRunningtest())
        {
            jobName += 'test';
        }
        clearJob(jobName);
        system.schedule(jobName, cronText , new SchdDeleteApplicationErrors());
    }

    // use this methid to run this job once manually
    public static void manual() {
        database.executebatch(new SchdDeleteApplicationErrors());
    }



    global void execute(SchedulableContext sc) {
        try
        {
            manual();
        }
        catch(Exception ex)
        {
            Log.notify(ex, null, 'SchdDeleteApplicationErrors', Log.ErrorType.ERROR);
        }
    }

    // -------------------------------------------------------------------------------------
    // ---------------- Schedulable Part ---------------------------------------------------
    // -------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------
    // ---------------- Batchable Part ---------------------------------------------------

    global Database.QueryLocator start(Database.BatchableContext bc) {

        try
        {
            Date today = System.today();
            String query = 'Select Id from Application_Error__c where Save_Until__c <= :TODAY';

            if(Test.isRunningTest())
                query += ' limit 200';

            Database.QueryLocator ql = Database.getQueryLocator(query);
            Log.log(ql.getQuery());
            return ql;
        }
        catch(Exception ex)
        {
            Log.notify(ex, null, 'SchdDeleteApplicationErrors', Log.ErrorType.ERROR);
            return Database.getQueryLocator('Select Id from Portal_Exam_Event__c where Id = null');
        }

    }

    global void execute(Database.BatchableContext bc, List<Application_Error__c> lstErrors)
    {
        try
        {
            Log.log('Application Error records for deletion:\n' + JSON.serializePretty(lstErrors));
            delete lstErrors;
        }
        catch(Exception ex)
        {
            Log.notify(ex, null, 'SchdDeleteApplicationErrors', Log.ErrorType.ERROR);
        }
    }

    global void finish(Database.BatchableContext bc) {}
    // -------------------------------------------------------------------------------------
    // ---------------- Batchable Part ---------------------------------------------------
    // -------------------------------------------------------------------------------------


    private static void clearJob(String jobName)
    {
        CronTrigger[] lstJob = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType, State
                                FROM CronTrigger
                                where CronJobDetail.name = :jobName] ;
        for (CronTrigger cr : lstJob)
        {
            system.abortJob(cr.Id);
        }

    }
}