trigger InvoiceTrigger on Invoice__c (before insert, before delete) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            InvoiceTriggerHandler.RegisterClass(trigger.new);
        }
        when BEFORE_DELETE{
            //Set <ID> idClassList = new Set <Id>();
            Invoice__c old;
            for(Invoice__c opp : trigger.old)
            {
                old = Trigger.oldMap.get(opp.id); 
                
            }
            //InvoiceTriggerHandler.UnregisterClass(trigger.old);
            //// Filter Class base on ID from trigger
            List<Class__c>  lstClass= [Select id,seats__c from Class__c where id =: old.Class__c];
            
            for(Class__c objClass : lstClass){
                if (objClass.Seats__c == 0){
                    objClass.Status__c = 'Available';
                }
                objClass.Seats__c ++;
                
            }
            update lstClass;       
        }   
    }
}
