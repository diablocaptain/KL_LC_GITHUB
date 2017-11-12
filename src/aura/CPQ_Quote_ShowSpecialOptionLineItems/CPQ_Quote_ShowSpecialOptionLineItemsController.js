({
	doInit : function(component, event, helper) {
		var action = component.get("c.getSpecialOptionQuoteLines");
      	action.setParams({"quoteId": component.get("v.recordId")});
      	action.setCallback(this, function(response) {
        	var state = response.getState();
         	if(component.isValid() && state == "SUCCESS"){
            	component.set("v.quoteLines", response.getReturnValue());
         	} else {
            	console.log('Error trying to get quote line records.');
         	}
      	});
      	$A.enqueueAction(action);
	},
})