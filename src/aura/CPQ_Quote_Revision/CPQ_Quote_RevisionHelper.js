/**
 * Created by MatsBöhler on 18.10.2017.
 */
({
    helperRevision: function(component, quoteId) {
        var action = component.get("c.revisionQuote");
        action.setParams({"quoteId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.revisedQuote", response.getReturnValue());
                component.set("v.response", "This quote has been revised. Please proceed.");
            } else {
                console.log('Error trying to revise quote. Please contact your administrator.');
            }
        });
        $A.enqueueAction(action);
    },
})