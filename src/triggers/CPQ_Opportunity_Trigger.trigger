trigger CPQ_Opportunity_Trigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
    new CPQ_OpportunityTriggerHandler().run();
    System.debug('Counter queries CPQ_Opportunity_Trigger: ' + Limits.getQueries());
    System.debug('Counter DML Statements CPQ_Opportunity_Trigger: ' + Limits.getDMLStatements());
}