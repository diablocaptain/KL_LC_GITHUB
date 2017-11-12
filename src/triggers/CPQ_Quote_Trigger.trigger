trigger CPQ_Quote_Trigger on SBQQ__Quote__c (before insert, before update, before delete, after insert, after update, after delete) {
    new CPQ_QuoteTriggerHandler().run();
    System.debug('Counter queries CPQ_Quote_Trigger: ' + Limits.getQueries());
    System.debug('Counter DML Statements CPQ_Quote_Trigger: ' + Limits.getDMLStatements());
}