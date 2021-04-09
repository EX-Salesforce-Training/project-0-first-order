trigger WorkerTrigger on Worker__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        When AFTER_UPDATE{
            // check if the updated field is actually the service field
            for(ID worker: Trigger.newMap.keySet()){
                if(Trigger.oldMap.get(worker).Service__c != Trigger.newMap.get(worker).Service__c){
                    WorkerTriggerHandler.HideMenuItem(trigger.new);
                }
            }
            
        }
    }
}