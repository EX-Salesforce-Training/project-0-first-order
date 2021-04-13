trigger CartTrigger on Cart__c (before insert, after delete) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            CartTriggerHandler.RegisterClass(trigger.new);
        }
        when AFTER_DELETE{
            CartTriggerHandler.UnregisterClass(trigger.old,trigger.oldMap);
        }  
   }
}
