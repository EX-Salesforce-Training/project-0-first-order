/*
 * get menu of worker and changes it availability to on or off according to the worker's services
 */
public class WorkerTriggerHandler {
    
	public static void HideMenuItem(List<Worker__c> workers){
        // menuL use to keep all the record that need to be updated.
        List<Menu__c> menuL = new List<Menu__c>();
        
        // make a Map where key is the workerID and values are lists of their menuitems
        Map<Id, List<Menu__c>> menu = new Map<Id, List<Menu__c>>();
        
        // query for the all the workers that was pass to us by the trigger.
        // key is worker__c of menuItem, values a list of the menuItem belonging to worker with the key as id
        for(Menu__c menuItem: [SELECT service_available__c, Service__c, Worker__c FROM Menu__c WHERE Worker__c IN :workers]){
            
            if(menu.get(menuItem.Worker__c) == null){
                menu.put(menuItem.Worker__c, new List<Menu__c>{menuItem});
            }else{
                menu.get(menuItem.Worker__c).add(menuItem);
            }
        }
        
        // go to each worker and update their menu.
        for(Worker__c w: workers){
            
            // split the worker service multi picklist into their own element in a list
            List<String> servicesOffer = w.Service__c.split(';');
            
            // go to each menuItem in the List of the worker that we store in our map.
            for(Menu__c menuItem: menu.get(w.Id)){
                
                // check menu item service field match with worker services
                if(servicesOffer.contains(menuItem.Service__c)){
                    // check if changes are neccessary, so we don't unneccessarily adding more to our update list
                    if(menuItem.Service_Available__c == false){
                        menuItem.Service_Available__c = true;
                        menuL.add(menuItem);
                    }
                }else{
                    if(menuItem.Service_Available__c == true){
                        menuItem.Service_Available__c = false;
                        menuL.add(menuItem);
                    }
                }
            }
        }
        
        update menuL;
    }
}