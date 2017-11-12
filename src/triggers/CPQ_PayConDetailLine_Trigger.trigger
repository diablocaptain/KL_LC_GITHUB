trigger CPQ_PayConDetailLine_Trigger on CPQ_Payment_Conditions_Detail_Line__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	new CPQ_PayConDetailLineTriggerHandler().run();
}