public class InvoiceTriggerHandler{
    public static void RegisterClass(List<Invoice__c> invoList){
        // Exactring Class ID from trigger
        // put class ID in the set ID
        set <ID> idClassList = new set <Id>(); 
        for(Invoice__c s: invoList){
            idClassList.add(s.Class__c);
        }
        
        // Filter Class base on ID from trigger
        List<Class__c>  lstClass= [Select id,seats__c from Class__c where id IN : idClassList];
        for(Invoice__c invoObj : invoList){
            for(Class__c objClass : lstClass){
                if(objClass.Seats__c == 0){
                    invoObj.Class__c.addError('Class is Full');
                }
                else{
                    objClass.Seats__c --;
                    if (objClass.Seats__c == 0){
                        objClass.Status__c = 'Full';
                    }
                }
            }
        }
        update lstClass;
    }
    /*public static void UnregisterClass(List<Invoice__c> invoList){
        // Exactring Class ID from trigger
        // put class ID in the set ID
        //Set <ID> idClassList = new Set <Id>(); 
        //for(Invoice__c s: invoList){
         //   idClassList.add();
        //}
        
        // Filter Class base on ID from trigger
        //List<Class__c>  lstClass= [Select id,seats__c from Class__c where id IN : idClassList];
        /*for(Invoice__c invoObj : invoList){
            for(Class__c objClass : lstClass){
                objClass.Seats__c ++;
                if (objClass.Seats__c == 0){
                    objClass.Status__c = 'Available';
                }
            }
        }
        //update lstClass;
    }
*/
}