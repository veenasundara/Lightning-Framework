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
** Description : Unit Test for Log class
 */

@isTest
public class LogTest {

    static testMethod void positive() {
        Log.log('print str');
        Log.log('print obj',new Account());
        System.assertEquals(2,log.lstLogEntry.size());

        Log.log('print unserializable object',new SelectOption('Test','Test'));
        System.assertEquals(3,log.lstLogEntry.size());
        DeviceInformation deviceInfo = new DeviceInformation();
        deviceInfo.devicetype = 'device';
        deviceInfo.os = 'os';
        deviceInfo.mobiletouch = true;
        deviceInfo.browser = 'chrome';

        try{
            throw new LogTestException('Test');
        }
        catch(LogTestException e){
            log.notify(e,'General','null', deviceInfo, Log.ErrorType.ERROR);
        }

        Application_Error__c ae = [Select Id, Running_User__c, Type__c, RecordTypeId, Process__c from Application_Error__c];
        System.assertEquals(UserInfo.getUserId(),ae.Running_User__c);
        System.assertEquals('LogTest.LogTestException',ae.Type__c);
        System.assertEquals('null',ae.Process__c);
        System.assertEquals(SObjectType.Application_Error__c.getRecordTypeInfosByName().get('General').getRecordTypeId(),ae.RecordTypeId);

        DeviceInformation lla2 = DeviceInformation.deserialize(JSON.serialize(deviceInfo));
        System.assert(deviceInfo.browser == lla2.browser);
        System.assert(deviceInfo.os == lla2.os);
        System.assert(deviceInfo.mobiletouch == lla2.mobiletouch);
        System.assert(deviceInfo.devicetype == lla2.devicetype);
        System.assert(deviceInfo.auraerror == lla2.auraerror);


        try{
            throw new LogTestException('Test');
        }
        catch(LogTestException e){
            log.notify(e.getMessage(), null, 'unitTest', Log.ErrorType.ERROR);
        }

    }

    static testMethod void negative(){
        ApexPages.currentPage().getHeaders().put('USER-AGENT', ' Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) '+
                                                                'AppleWebKit/536.26.14 (KHTML, like Gecko) (Coda, like Safari)');
        try{
            throw new LogTestException('Test');
        }
        catch(LogTestException e){
            log.notify(e,'Food Safety',null,Log.ErrorType.ERROR);
        }
    }


    public class LogTestException extends Exception{}
}