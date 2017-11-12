/**
 * Created by MatsBöhler on 17.10.2017.
 */
({
    doInit : function(component, event, helper) {
    		var action = component.get("c.getQuote");
          	action.setParams({"quoteId": component.get("v.recordId")});
          	action.setCallback(this, function(response) {
            	var state = response.getState();
             	if(component.isValid() && state == "SUCCESS"){
             	    component.set("v.quote", response.getReturnValue());
             	    var revised = component.get("v.quote.CPQ_Quote_revised__c");
             	    if(revised){
             	        component.set("v.response", "This quote has already been revised. Please return to quote record.");
                    }else {
                        helper.helperRevision(component, component.get("v.recordId"));
                    }

             	} else {
                	console.log('Error trying to revise quote. Please contact your administrator.');
             	}
          	});
          	$A.enqueueAction(action);
    	},

    	onCancel : function(component, event, helper) {

    	    // Navigate back to the record view
    	    var navigateEvent = $A.get("e.force:navigateToSObject");
    	    var revised = component.get("v.quote.CPQ_Quote_revised__c");
            if(revised){
                navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                navigateEvent.fire();
            }else {
                navigateEvent.setParams({ "recordId": component.get('v.revisedQuote.Id') });
                navigateEvent.fire();
            }



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
        },
})