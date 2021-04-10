trigger MenuTrigger on Menu__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        When BEFORE_INSERT{
            MenuTriggerHandler.CheckWorkerServiceInsert(trigger.new);
        }
    }
}