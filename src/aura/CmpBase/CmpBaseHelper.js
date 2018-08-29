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
({
    /**
     * gathers information based on user-agent string
     * @param  {[type]} component [description]
     * @return {[type]}           [description]
     */
    hlpDoInit : function(component) {
        var action = component.get('c.ctrlGetDeviceInformation');
        var dt = this.hlpGetDeviceType();
        component.set('v.devicetype',dt);

        action.setParams({
                             'userAgent' : navigator.userAgent,
                             'devicetype' : dt,
                             'notify' : component.get('v.notifyOnError')
                         })

        action.setCallback(this,function(result){
            if(!this.hlpCheckForError(component, result, component.get('v.toastMode'))){
                return;
            }
            var res = result.getReturnValue();
            component.set('v.deviceinfo',res);
            // console.log('init done');
            this.initActionObject(component);
            //console.log('deviceinfo = ' + JSON.stringify(component.get("v.deviceinfo")));
            component.getConcreteComponent().init(); // this is in IntBase interface that all components must implement
        });

        $A.enqueueAction(action);
    },

    /**
     * gets device type based on $Browser var
     * @return {[type]} [description]
     */
    hlpGetDeviceType : function(){
        var ff = $A.get('$Browser.formFactor');
        var isAndroid = $A.get('$Browser.isAndroid')
        var isIOS = $A.get('$Browser.isIOS')
        var isIPad = $A.get('$Browser.isIPad')
        var isIPhone = $A.get('$Browser.isIPhone')
        var isWindowsPhone = $A.get('$Browser.isWindowsPhone')

        var result;

        if(ff.toLowerCase() == 'phone'){
            result = 'Phone ';
            if(isIOS) result += '(iPhone)';
            else if(isAndroid) result += '(Andriod)';
            else if(isWindowsPhone) result += '(Windows)';
            else result += '(Unknown)';
        }
        else if(ff.toLowerCase() == 'tablet'){
            result = 'Tablet ';
            if(isIPad) result += '(iPad)';
            else result += '(Android)';
        }
        else{
            // is desktop
            result = ff;
        }
        return result;
    },



    /**
     * parses server response to determine if success or fail
     * @param  {[type]} response [server response]
     * @param mode [mode for displaying toast]
     * @return {[type]}          [Pass/Fail]
     */
    hlpCheckForError : function(cmp, response, mode) {
        try
        {
            var state = response.getState();
            if (state !== "SUCCESS")
            {
                var unknownError = true;
                if(state === 'ERROR')
                {
                    var errors = response.getError();
                    if (errors)
                    {
                        if (errors[0] && errors[0].message)
                        {
                            unknownError = false;
                            this.hlpShowToast(cmp,'Error', {'msg' : errors[0].message, 'mode' : mode});
                        }
                    }
                }
                if(unknownError)
                {
                    this.hlpShowToast(cmp, 'Error', {'msg' : 'Unknown error from Apex class', 'mode' : mode});
                }
                return false;
            }
            else if(response.getReturnValue() != undefined){
                var r = response.getReturnValue();
                if(r.hasOwnProperty('auraerror')){
                    this.hlpShowToast(cmp, 'Error', {'msg' : r.auraerror, 'mode' : mode})
                    return false;
                }
            }
            return true;
        }
        catch(e)
        {
            this.hlpShowToast(cmp, 'Error', {'msg' : e.message, 'mode' : mode});
            return false;
        }
    },


    /**
     * fires toast events
     * @param  {[type]} message [toast message]
     * @param  {[type]} mode    [toast mode]
     * @return {[type]}         [description]
     */
    hlpShowToast : function(component, ttype, args){
        console.log(JSON.stringify(args));
        component.find('notifierlib').showToast({
            'mode' : args.mode || 'sticky',
            'message' : args.msg,
            'duration' : args.duration,
            'variant' : ttype
        });
    },

    /**
     * show the spinner
     * @param component
     */
    hlpShowSpinner : function(component, args) {
        var sp = component.find('mySpinner');
        sp.set('v.size', args.size || 'large');
        $A.util.removeClass(sp, 'slds-hide');
    },

    /**
     * hide the spinner
     * @param component
     */
    hlpHideSpinner : function(component, args) {
        var sp = component.find('mySpinner');
        sp.set('v.size', args.size || 'large');
        $A.util.addClass(sp, 'slds-hide');
    },

    /**
     * inits the action attribute with the device info
     * @param  {[type]} component [component]
     * @return {[type]}           [description]
     */
    initActionObject : function(component) {
        var di = component.get('v.deviceinfoName')
        component.set('v.actionParams',{di : JSON.stringify(component.get('v.deviceinfo'))});
    }
})