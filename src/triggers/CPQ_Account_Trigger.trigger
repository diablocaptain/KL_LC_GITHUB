trigger CPQ_Account_Trigger on Account (before insert, before update, before delete, after insert, after update, after delete) {
    new CPQ_AccountTriggerHandler().run();
}