/*
 * Change menu availability to match worker on insert
 * Disallow menu from being update if service availability does not match worker's
 */
public class MenuTriggerHandler {
    
    public static void CheckWorkerServiceInsert(List<Menu__c> menu){
        // a map of worker and their id use to look up specific worker base on the id found in menu
        Map<Id, Worker__c>  workerM = new Map<Id, Worker__c>([SELECT id, Service__c FROM Worker__c]);
        
        for(Menu__c m: menu){
            if(workerM.get(m.Worker__c) != null){
                List<String> workerServices = workerM.get(m.Worker__c).Service__c.split(';');
                if(m.Service_Available__c==true && !workerServices.contains(m.Service__c)){
                    // update the value for that menu item.
                    m.Service_Available__c = false;
                }
            }
        }
    }
    public static void CheckWorkerServiceUpdate(List<Menu__c> menu){
        Map<Id, Worker__c>  workerM = new Map<Id, Worker__c>([SELECT id, Service__c FROM Worker__c]);
        for(Menu__c m: menu){
            if(workerM.get(m.Worker__c) != null){
                List<String> workerServices = workerM.get(m.Worker__c).Service__c.split(';');
                if(m.Service_Available__c==true && !workerServices.contains(m.Service__c)){
                    // Thrown an error
                    m.addError('Worker doesn\'t have this service');
                }
            }
        }
    }
}