trigger CPQ_Product_Trigger on Product2 (before insert, before update, before delete, after insert, after update, after delete) {
    new CPQ_ProductTriggerHandler().run();
    System.debug('DML Limit CPQ_Product_Trigger: ' + Limits.getDMLStatements());
}