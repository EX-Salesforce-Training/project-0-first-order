trigger ScheduleTrigger on Appointment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	switch on trigger.operationType{
        When BEFORE_INSERT{
            ScheduleTriggerHandler.CheckWorkerRequestAgreement(trigger.new);
        } 
        When AFTER_INSERT{
            // check if the insertion have an invoice associated with it
            ScheduleTriggerHandler.GetPriceForInvoice(trigger.new, trigger.newMap.keySet());
        }
        When AFTER_UPDATE{
            // check if the update have an invoice associated with it
            ScheduleTriggerHandler.GetPriceForInvoice(trigger.new, trigger.newMap.keySet());
        }
    }
}