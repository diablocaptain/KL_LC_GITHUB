//MachineController.js
({

    doInit:function(component,event, helper){

        helper.loadPayCon(component, event);
    },

    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'PayCons');
    },

    addNewPayCon : function(component, event, helper) {
            var action = component.get("c.insertNewPayCon");
            action.setParams({"machineId": component.get("v.machineId")});
            action.setCallback(this, function(response) {
            var state = response.getState();
                if(component.isValid() && state == "SUCCESS"){

                    helper.loadPayCon(component, event);
                } else {
                    console.log('Error trying to insert new PayCon.');
                }
            });
            $A.enqueueAction(action);
        },
})