trigger CPQ_TaC_Trigger on CPQ_Terms_and_Conditions__c (before insert, before update, before delete, after insert, after update, after delete) {
	new CPQ_TaCTriggerHandler().run();
}