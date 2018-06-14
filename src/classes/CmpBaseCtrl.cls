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
/**
 *  Description: Controller for Lighting base component CmpBase
*/
public class CmpBaseCtrl {

    static DeviceInformation deviceInfo;
    /**
     * get device information based on user-deviceInfo
     * @param  userAgent  [user-deviceInfo]
     * @param  devicetype [mobile/tablet/desktop]
     * @param  notify     [send error email on error]
     * @return            [DeviceInformation]
     */
    @AuraEnabled
    public static DeviceInformation ctrlGetDeviceInformation(String userAgent, String devicetype, Boolean notify)
    {
        if(deviceInfo != null) return deviceInfo;

        try
        {
            Log.log('userAgent = ' + userAgent);
            deviceInfo = userAgent == null || userAgent == '' ? new DeviceInformation() : new DeviceInformation(userAgent, devicetype);

            // for test coverage
            if(Test.isRunningTest())
            {
                throw new AuraHandledException('Test Exception');
            }
        }
        catch(Exception e)
        {
            deviceInfo.handleException(e);
            if(notify)
            {
                Log.notify(e, 'CmpBaseCrtl ctrlGetDeviceInformation', deviceInfo);
            }
        }
        return deviceInfo;
    }

}