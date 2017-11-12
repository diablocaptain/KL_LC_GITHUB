/**
 * Created by MatsBöhler on 10.10.2017.
 */
({
    sendHelper: function(component, getEmail, getSubject, getbody, getCC, quoteId) {
        // call the server side controller method
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'mCC': getCC,
            'quoteId': quoteId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                component.set("v.mailStatus", true);
            }

        });
        $A.enqueueAction(action);
    },
})