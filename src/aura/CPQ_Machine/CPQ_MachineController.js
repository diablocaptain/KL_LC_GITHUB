//MachineController.js
({

    doInit:function(component,event){
        var action = component.get("c.getMachineWithSpecialOptions");
        action.setParams({"groupId": component.get("v.groupId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){

                component.set("v.quoteLines", response.getReturnValue());

                $A.createComponents([

                  ["c:CPQ_PaymentCondition",{
                      "machineId" : component.get("v.quoteLines")[0].Id
                  }],
                  ["c:CPQ_TermsAndConditions",{
                      "machineId" : component.get("v.quoteLines")[0].Id
                  }],
                    ],
                    function(components, status, errorMessage){
                        if (status === "SUCCESS") {
                            var newTacComponent = components[1];
                            var newPayConComponent = components[0];
                            var bodyTac = component.get("v.tacComponent");
                            var bodyPayCon = component.get("v.payConComponent");
                            bodyTac.push(newTacComponent);
                            bodyPayCon.push(newPayConComponent);
                            component.set("v.tacComponent", bodyTac);
                            component.set("v.payConComponent", bodyPayCon);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                        }
                        else if (status === "ERROR") {
                            //console.log("Error: " + errorMessage);
                            console.log("Error: ..... -.-");
                            // Show error message
                        }
                    }
                );

            } else {
                console.log('Error trying to get quote line records!');
            }
        });
        $A.enqueueAction(action);
    },

    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
})