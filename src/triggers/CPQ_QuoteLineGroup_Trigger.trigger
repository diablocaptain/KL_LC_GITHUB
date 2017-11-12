trigger CPQ_QuoteLineGroup_Trigger on SBQQ__QuoteLineGroup__c (before insert, before update, before delete, after insert, after update, after delete) {
    /*
	//disable SBQQ Triggers
    SBQQ.TriggerControl.disable();
    try {
        //try to execute quote line logic without SBQQ triggers overwriting it
        new CPQ_QuoteLineGroupTriggerHandler().run();

    } finally {
    	SBQQ.TriggerControl.enable();
    }
	*/
    System.debug('Counter queries CPQ_QuoteLineGroup_Trigger: ' + Limits.getQueries());
    System.debug('Counter DML Statements CPQ_QuoteLineGroup_Trigger: ' + Limits.getDMLStatements());
    
}