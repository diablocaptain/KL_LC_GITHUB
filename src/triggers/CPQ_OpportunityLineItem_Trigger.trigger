trigger CPQ_OpportunityLineItem_Trigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete) {
	new CPQ_OpportunityLineItemTriggerHandler().run();
    System.debug('DML Limit CPQ_OpportunityLineItem_Trigger: ' + Limits.getDMLStatements());
}