trigger CPQ_QuoteLine_Trigger on SBQQ__QuoteLine__c (before insert, before update, before delete, after insert, after update, after delete) {
    //disable SBQQ Triggers
        SBQQ.TriggerControl.disable();
        try {
            //try to execute quote line logic without SBQQ triggers overwriting it
            new CPQ_QuoteLineTriggerHandler().run();

        } catch (Exception e){
            System.debug('Exeption while handling quote line trigger: ' + e);
        } finally {
            SBQQ.TriggerControl.enable();
        }

    System.debug('Counter queries CPQ_QuoteLine_Trigger: ' + Limits.getQueries());
    System.debug('Counter DML Statements CPQ_QuoteLine_Trigger: ' + Limits.getDMLStatements());
}