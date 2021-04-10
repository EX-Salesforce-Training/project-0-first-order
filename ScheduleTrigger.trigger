trigger ScheduleTrigger on Appointment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	switch on trigger.operationType{
        When AFTER_INSERT{
            // check if the insertion have an invoice associated with it
            for(ID appointment : trigger.newMap.keySet()){
                if(trigger.newMap.get(appointment).Invoice__c != null){
                    ScheduleTriggerHandler.GetPriceForInvoice(appointment);
                }
            }
            
        }
        When AFTER_UPDATE{
            // check if the update have an invoice associated with it
            for(ID appointment : trigger.newMap.keySet()){
                if(trigger.newMap.get(appointment).Invoice__c != null){
                    ScheduleTriggerHandler.GetPriceForInvoice(appointment);
                }
            }
        }
    }
}