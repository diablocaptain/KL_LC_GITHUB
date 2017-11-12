trigger CPQ_SpecialOption_Trigger on CPQ_Special_Options__c (before insert, before update, before delete, after insert, after update, after delete) {
	new CPQ_SpecialOptionTriggerHandler().run();
    System.debug('DML Limit CPQ_SpecialOption_Trigger: ' + Limits.getDMLStatements());
}