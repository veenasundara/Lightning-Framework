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
** Description: Unit test for DeviceInformation
*/
@isTest
public class DeviceInformationTest
{

    @testSetup static void buildData()
    {
    }

    //test methods

    static testMethod void myTest1()
    {
        String useragent = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/6.0; SLCC2; ' +
                '.NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; .NET4.0C; .NET4.0E)';

        DeviceInformation deviceInfo = new DeviceInformation(useragent, 'DESKTOP');
        DeviceInformation.deserialize(JSON.serialize(deviceInfo));
        system.assertEquals(true, deviceInfo.isIE7);
        system.assertEquals(false, deviceInfo.isIE8);
        system.assertEquals(false, deviceInfo.isIE9);
        system.assertEquals(false, deviceInfo.isIOS);
        system.assertEquals(false, deviceInfo.isIPad);
        system.assertEquals(false, deviceInfo.isIPhone);


        ApexPages.currentPage().getHeaders().put('USER-AGENT', ' Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) '+
                'AppleWebKit/536.26.14 (KHTML, like Gecko) (Coda, like Safari)');
        deviceInfo = new DeviceInformation();
    }

}