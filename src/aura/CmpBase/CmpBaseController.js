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

    // get device information
    init : function(component, event, helper) {
        if(component.get('v.singleExecution')){
            return;
        }

        component.set('v.singleExecution', true);
        helper.hlpDoInit(component);
    },

    // Determines if server call was successful
    successfulResponse : function(component, event, helper){
        var r = event.getParam('arguments').res;
        var mode = event.getParam('arguments').mode || component.get('v.toastMode');
        return helper.hlpCheckForError(component.getSuper(), r, mode);
    },

    //displays success toast
    success : function(component, event, helper){
        helper.hlpShowToast(component.getSuper(), 'success', event.getParam('arguments'));
    },

    // displays error toast
    error : function(component, event, helper){
        helper.hlpShowToast(component.getSuper(), 'error', event.getParam('arguments'));
    },

    // displays warning toast
    warn : function(component, event, helper){
        helper.hlpShowToast(component.getSuper(), 'warning', event.getParam('arguments'));
    },

    // displays info toast
    info : function(component, event, helper){
        helper.hlpShowToast(component.getSuper(), 'info', event.getParam('arguments'));
    },

    // shows spinner
    showSpinner : function(component, event, helper){
        helper.hlpShowSpinner(component.getSuper(), event.getParam('arguments'));
    },

    // hides spinner
    hideSpinner : function(component, event, helper){
        helper.hlpHideSpinner(component.getSuper(), event.getParam('arguments'));
    },

    // for server call, sets server action
    setAction : function(component, event, helper){
        component.set('v.action', event.getParam('arguments').serverAction)
    },

    // for server call, sets method parameters 
    setParams : function(component, event, helper){
        var pobj = event.getParam('arguments').params;
        pobj['deviceinfojson'] = JSON.stringify(component.get('v.deviceinfo'));
        component.set('v.actionParams', pobj);
    },

    // for server call, sets onsuccess and onfail callback functions
    setCallback : function(component, event, helper){
        var args = event.getParam('arguments');
        if(args.successcb){
            component.set('v.onsuccess', $A.getCallback(args.successcb));
        }
        if(args.failcb){
            component.set('v.onfail', $A.getCallback(args.failcb));
        }
    },

    // resets variables for clean slate
    reset : function(component, event, helper){
        helper.initActionObject(component);
        // component.set('v.actionParams', null);
        component.set('v.action', null);
        component.set('v.onsuccess', null);
        component.set('v.onfail', null);
    },

    // makes call to server side controller
    run : function(component, event, helper){
        var action = component.get('v.action');

        if(component.get('v.spinner')){
            helper.hlpShowSpinner(component.getSuper(),{});
        }

        if(component.get('v.actionParams')){
            action.setParams(component.get('v.actionParams'));
        }

        action.setCallback(this, function(result){
            if(component.get('v.spinner')){
                component.hideSpinner();
            }
            var callback;
            if(!component.successfulResponse(result)){
                callback = component.get('v.onfail');
                return;
            }
            else{
                callback = component.get('v.onsuccess');
            }

            component.reset();

            if(callback){
                callback(component, result.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },

})