/**
 * Created by MatsBöhler on 02.11.2017.
 */
({

    doInit:function(component,event){
        var action = component.get("c.getTermsAndConditions");
        action.setParams({"machineId": component.get("v.machineId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){

                component.set("v.termsAndConditions", response.getReturnValue());

            } else {
                console.log('Error trying to get terms and conditions records!');
            }
        });
        $A.enqueueAction(action);
    },

    saveTaC : function(component, event, helper) {

       var action = component.get("c.updateTermsAndConditions");
        action.setParams({"tac": component.get("v.termsAndConditions")});
        action.setCallback(this, function(response) {
        var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                console.log(response.getReturnValue());
                component.set("v.TacSaved" , true);
            } else {
                console.log('Error trying to update terms and conditions.');
            }
        });
        $A.enqueueAction(action);
    },

    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'TaC');
    },

    setDoNotPrint : function(component, event, helper) {
        var tac = component.get("v.termsAndConditions");
        var checkboxValue = event.getSource().get("v.value");
        var index = event.getSource().get("v.name");

        tac[index].CPQ_Do_not_Print__c = checkboxValue;

        component.set("v.termsAndConditions", tac);
        console.log("TAC!!!!::::::" + component.get("v.termsAndConditions")[0].CPQ_Do_not_Print__c);
    },

    addTaC : function(component, event, helper) {
        var action = component.get("c.insertNewTaC");
        action.setParams({"machineId": component.get("v.machineId")});
        action.setCallback(this, function(response) {
        var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){

                helper.loadTaC(component, event);
            } else {
                console.log('Error trying to insert new TAC.');
            }
        });
        $A.enqueueAction(action);
    },

    closeMessage: function(component, event, helper) {
        component.set("v.TacSaved", false);
    },
})