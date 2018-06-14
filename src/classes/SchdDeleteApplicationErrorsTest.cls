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
** Description: Unit test for SchdDeleteApplicationErrors
*/
@isTest
public class SchdDeleteApplicationErrorsTest {

    @testSetup static void buildData(){
        Application_Error__c ae1 = createGeneralApplicationError(null);
        Application_Error__c ae2 = createGeneralApplicationError(null);
        Application_Error__c ae3 = createGeneralApplicationError(null);
        Application_Error__c ae4 = createGeneralApplicationError(null);
        Application_Error__c ae5 = createGeneralApplicationError(null);
        Application_Error__c ae6 = createGeneralApplicationError(null);
        Application_Error__c ae7 = createGeneralApplicationError(null);
        insert new Application_Error__c[]{ae1,ae2,ae3,ae4,ae5,ae6,ae7};
        ae1.Save_Until__c = System.today();
        ae2.Save_Until__c = System.today();
        ae3.Save_Until__c = System.today();
        ae4.Save_Until__c = System.today();
        ae5.Save_Until__c = System.today().addDays(1);
        ae6.Save_Until__c = System.today().addDays(-10);
        ae7.Save_Until__c = System.today();
        update new Application_Error__c[]{ae1,ae2,ae3,ae4,ae5,ae6,ae7};


        Attachment a1 = createAttachment(ae1.Id);
        Attachment a2 = createAttachment(ae2.Id);
        Attachment a3 = createAttachment(ae3.Id);
        insert new Attachment[]{a1,a2,a3};
    }
    /**
     * instanciates new Application Error record
     * @param  processName [Business process name]
     * @return             [Application_Error__c]
     */
    private static Application_Error__c createGeneralApplicationError(String processName){
        Application_Error__c ae = new Application_Error__c();
        ae.Log_Level__c = 'ERROR';
        ae.Type__c = null;
        ae.Process__c = processName;
        ae.Stack_Trace__c = 'Test';
        ae.Browser__c = 'OS';
        ae.Current_Page__c = 'test';
        ae.Message__c = 'test';
        ae.Running_User__c = UserInfo.getUserId();
        ae.Running_User_Name__c = 'Test User';
        ae.Running_User_Email__c = UserInfo.getUserEmail();
        ae.Running_User_Profile__c = 'Test Profile';
        return ae;
    }
    /**
     * instanciates new attachment
     * @param  parent [related record id]
     * @return        [Attachment]
     */
    public static Attachment createAttachment(Id parent){
        Attachment a = new Attachment();
        a.Name = 'test.txt';
        a.ParentId = parent;
        a.Body = Blob.valueOf('Test');
        return a;
    }

    //test methods

    static testMethod void runbatch() {
        Test.startTest();
        SchdDeleteApplicationErrors.manual();
        Test.stopTest();

        System.assertEquals(1,[Select count() from Application_Error__c]);
        System.assertEquals(0,[Select count() from Attachment]);
    }

    static testMethod void schedulebatch() {
        Test.startTest();
        SchdDeleteApplicationErrors.schedule();
        Test.stopTest();
    }

}