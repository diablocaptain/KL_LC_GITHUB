/**
 * Created by MatsBöhler on 10.10.2017.
 */
({
    sendMail: function(component, event, helper) {
        // when user click on Send button
        // First we get all 3 fields values
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        var getCC = component.get("v.cc");
        var quoteId = component.get("v.quote.Id");
        // check if Email field is Empty or not contains @ so display a alert message
        // otherwise call call and pass the fields value to helper method
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@") || $A.util.isEmpty(getCC) || !getCC.includes("@") || $A.util.isEmpty(getSubject) || $A.util.isEmpty(getbody)) {
            alert('Please validate your data and try again.');
        } else {
            helper.sendHelper(component, getEmail, getSubject, getbody, getCC, quoteId);
        }
    },

    doInit : function(component, event, helper) {
        var action = component.get("c.getQuote");
        action.setParams({"quoteId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.quote", response.getReturnValue());
                component.set("v.cc", component.get("v.quote.SBQQ__SalesRep__r.Email"));
                component.set("v.email", component.get("v.quote.SBQQ__PrimaryContact__r.Email"));

            } else {
                console.log('Error trying to get quote record.');
            }
        });
        $A.enqueueAction(action);
    },

    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },

    onCancel : function(component, event, helper) {

        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    },

    // this function automatic call by aura:waiting event
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner
        component.set("v.Spinner", true);
    },

    // this function automatic call by aura:doneWaiting event
    hideSpinner : function(component,event,helper){
       // make Spinner attribute to false for hide loading spinner
       component.set("v.Spinner", false);
    }

})