({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMachineQuoteLines");
        action.setParams({"quoteId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){

                component.set("v.quoteLines", response.getReturnValue());

                var machines = response.getReturnValue();

                //dynamically create sub lightning component for every machine to control aura:ids separately
                for (var i = machines.length - 1; i >= 0; i--) {

                   //Create component dynamically
                   $A.createComponent(
                       "c:CPQ_Machine",{
                           "groupId" : component.get("v.quoteLines")[i].SBQQ__Group__c
                       },
                       function(newcomponent){
                           if (component.isValid()) {
                               var body = component.get("v.body");
                               body.push(newcomponent);
                               component.set("v.body", body);
                           }
                       }
                   );
                }

            } else {
                console.log('Error trying to get quote line records!');
            }
        });
        $A.enqueueAction(action);
    },
})