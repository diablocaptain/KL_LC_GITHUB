({
	doInit : function(component, event, helper) {
		var action = component.get("c.getQuoteLineWrappers");
      	action.setParams({"quoteId": component.get("v.recordId")});
      	action.setCallback(this, function(response) {
        	var state = response.getState();
         	if(component.isValid() && state == "SUCCESS"){
            	component.set("v.machines", response.getReturnValue());
         	} else {
            	console.log('Error trying to get machine records.');
         	}
      	});
      	$A.enqueueAction(action);
	},

	onSavePdf : function(component, event, helper) {
        var action = component.get("c.savePdf");
        action.setParams({"quoteId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.machines", response.getReturnValue());
                component.set("v.SaveStatus", true);
            } else {
                console.log('Error trying to save PDF.');
            }
        });
        $A.enqueueAction(action);
    },

	updateCheckboxes : function(component, event, helper) {
		var machines = component.get("v.machines");
		var checked = event.getSource().get("v.value");

		for (var i = machines.length - 1; i >= 0; i--) {
			machines[i].selected = checked;
		}

		component.set("v.machines", machines);
	},

	updateCheckboxesSingle : function(component, event, helper) {
		var machines = component.get("v.machines");
		var checked = event.getSource().get("v.value");
		var index = event.getSource().get("v.name");
        
        machines[index].selected = checked;

		component.set("v.machines", machines);
	},

	onCancel : function(component, event, helper) {
 
	    // Navigate back to the record view
	    var navigateEvent = $A.get("e.force:navigateToSObject");
	    navigateEvent.setParams({ "recordId": component.get('v.recordId') });
	    navigateEvent.fire();
	},

	onPreview : function(component, event, helper) {
 
	    var machines = component.get("v.machines");
	    console.log(JSON.stringify(machines));
	    var action = component.get("c.setQuoteLineWrappers");
      	action.setParams({"quoteLineWrappers": JSON.stringify(machines),
      					  "quoteId": component.get("v.recordId") });
      	action.setCallback(this, function(response) {
        	var state = response.getState();
         	if(component.isValid() && state == "SUCCESS"){
            	var recordId = component.get("v.recordId");
            	var url = '/apex/QuotePdf?id=' + recordId;
            	window.open(url, '_blank');
         	} else {
            	console.log('Error trying to preview document.');
         	}
      	});
      	$A.enqueueAction(action);
	},

	onSendMail : function (component, event, helper) {
	
    	var machines = component.get("v.machines");
	    var quoteLineWrappers = [];
	    for (var i = machines.length - 1; i >= 0; i--) {
	    	
			if (machines[i].quoteLine.CPQ_Print__c) {
				quoteLineWrappers.push(machines[i]);
			}
	    }

	    var action = component.get("c.setQuoteLineWrappers");
      	action.setParams({"quoteLineWrappers": JSON.stringify(quoteLineWrappers)});
      	action.setCallback(this, function(response) {
        	var state = response.getState();
         	if(component.isValid() && state == "SUCCESS"){
            	var recordId = component.get("v.recordId");
            	var url = "https://klingelnberg--cpq.cs88.my.salesforce.com/_ui/core/email/author/EmailAuthor?p3_lkid=" + recordId + "&retURL=%2F" + recordId + "&new_template=1&template_id=00X9E000000ImEy";
            	window.open(url, '_parent');
         	} else {
            	console.log('Error trying to send email.');
         	}
      	});
      	$A.enqueueAction(action);
	},

	navigateToSendEmailComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CPQ_Quote_SendEmail",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
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

    closeMessage : function(component, event, helper) {

    	    // Navigate back to the record view
    	    var navigateEvent = $A.get("e.force:navigateToSObject");
    	    navigateEvent.setParams({ "recordId": component.get('v.recordId') });
    	    navigateEvent.fire();
    	},
})