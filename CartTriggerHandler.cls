public class CartTriggerHandler{
    public static void RegisterClass(List <Cart__c> cartList){
        // Exactring Class ID from trigger
        // put class ID in the set ID
        set <ID> idClassList = new set <Id>();     
        for(Cart__c s: CartList){
            idClassList.add(s.Class__c);
        }
        
        // Class__c Update class list
        // Filter Class base on ID from trigger in Class__c
        List<Class__c>  lstClass= [Select id,seats__c from Class__c where id IN : idClassList];
        for(Cart__c cartObj : cartList){
            for(Class__c objClass : lstClass){
                // if Class is Full prevent student to add the class
                if(objClass.Seats__c == 0){
                    CartObj.Class__c.addError('Class is Full');
                }
                else{
                    // substract class seat and set status to Full if class seat is full
                    objClass.Seats__c --;
                    if (objClass.Seats__c == 0){
                        objClass.Status__c = 'Full';
                    }
                }
            }
        }
        update lstClass;
        
        // Class_Roster_c insert student in class Roster
        // Filter Class base on ID from trigger in Class__c
        Class_Roster__c objRoster= new Class_Roster__c();
        for(Cart__c s: CartList){
            for(Class__c objClass : lstClass){
                // Assign the account to class roster from the account table
                // Assign The class to thhe Class Roster from the class table
                objRoster = new Class_Roster__c();
                objRoster.Class__c = objClass.Id;
                objRoster.Account__c = s.Account__c;
            }
        }
        insert objRoster;
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
