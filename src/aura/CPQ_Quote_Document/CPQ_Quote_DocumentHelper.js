({
	loadTaC : function(component, event) {
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
	}
})