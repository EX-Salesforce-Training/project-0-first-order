trigger InvoiceTrigger on Invoice__c (before insert, before delete) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            InvoiceTriggerHandler.RegisterClass(trigger.new);
        }
        when BEFORE_DELETE{
            Set <ID> idClassList = new Set <Id>();
            for(Invoice__c opp : trigger.old)
            {
                Invoice__c old = Trigger.oldMap.get(opp.id);             
                idClassList.add(old.Class__c);

            }
            //InvoiceTriggerHandler.UnregisterClass(trigger.old);
            
            System.debug(idClassList);
            System.debug('Print');           
        }   
    }
}