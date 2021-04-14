public class CartTriggerHandler{
    public static void RegisterClass(List <Cart__c> cartList){
        // Exactring Class ID, account id from trigger
        // put class ID and account id in the set ID
        set <ID> cartIdClassList = new set <Id>();   
        set <ID> cartAcctId = new set <ID>();
        for(Cart__c s: CartList){
            cartIdClassList.add(s.Class__c);
            cartAcctId.add(s.Account__c);
        }
        
        // Class__c Update class list
        // Filter Class base on ID from trigger in Class__c
        List<Class__c>  lstClass= [Select id,seats__c from Class__c where id IN : cartIdClassList];
        
        // Flag to raise error if Class is full and cart can't be added
        Integer flag = 0;
        
        for(Class__c objClass : lstClass){
            // if Class is Full prevent student to add the class
            if(objClass.Seats__c == 0){
                flag = 1;
            }
            else{
                // substract class seat and set status to Full if class seat is full
                objClass.Seats__c --;
                if (objClass.Seats__c == 0){
                    objClass.Status__c = 'Full';
                }
            }
        }
        // Update the table
        update lstClass;
        
        List<Class_Roster__c> newRoster = new List<Class_Roster__c> ();
        for(Cart__c cartObj : cartList){
            // Check the flag to see if class need to be added
            if (flag ==1){
                cartObj.Class__c.addError('Class is Full');
            }
            else{
                // if class is not full
                // adding student to Roster
                Class_Roster__c objRoster= new Class_Roster__c(Account__c = cartObj.Account__c, Class__c = cartObj.Class__c);
                newRoster.add(objRoster);
            }
        }
        try{
            insert newRoster;
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
        
    }  
    public static void UnregisterClass(List <Cart__c> cartOlds, Map<id,Cart__c> cartOldM){
        // Extract old values from the old Map
        Cart__c old;
        for(Cart__c cartOld : cartOlds){
            old = cartOldM.get(cartOld.id); 
        }
        
        // Filter Class base on ID from trigger old
        List<Class__c>  lstClass= [Select id,seats__c from Class__c where id =: old.Class__c];
        
        // Update database of that class
        for(Class__c objClass : lstClass){
            if (objClass.Seats__c == 0){
                objClass.Status__c = 'Available';
            }
            objClass.Seats__c ++;
            
        }
        update lstClass; 
        
        // Class_Roster_c insert student in class Roster
        // Filter Class base on ID from trigger in Class__c
        List<Class_Roster__c>  lstClassRoster= [Select Class__c,Account__c from Class_Roster__c where Class__c=: old.Class__c and Account__c=: old.Account__c];
        for(Class_Roster__c s: lstClassRoster){
            if(s != NULL)
            {
                delete s;
            }
        }   
    }
}
