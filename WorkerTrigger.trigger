trigger WorkerTrigger on Worker__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        When AFTER_UPDATE{
			WorkerTriggerHandler.HideMenuItem(trigger.new);
        }
    }
}