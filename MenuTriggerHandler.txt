public class MenuTriggerHandler {
    
    public static void CheckWorkerServiceInsert(List<Menu__c> menu){
        for(Menu__c m: menu){
            Worker__c worker = [SELECT id, Service__c FROM Worker__c WHERE id=:m.worker__c];
            List<String> workerServices = worker.Service__c.split(';');
            if(m.Service_Available__c==true && !workerServices.contains(m.Service__c)){
                // update the value for that menu item.
                m.Service_Available__c = false;
            }
        }
    }
}