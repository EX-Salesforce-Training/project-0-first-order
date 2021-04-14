@isTest
public class TestCartTrigger {
    @testSetup static void DataSetup(){
        // Test data setup Generate Good data for Positive Test Bulk
        //create Class bulk to register
        List<Class__c> objClass = new List<Class__c>();
        for(Integer i = 0; i < 200; i++){
            objClass.add(new Class__c(Seats__c = 1 ));
        }
        // Insert class in the test database
        insert objClass;
        
        //create account bulk to register
        List<Account> testAccs = new List<Account>();
        for(Integer i = 0; i < 1; i++){
            testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', First_Name__c = 'FirstN' + i, Last_Name__c = 'LastN' + i ));
        }
        // Insert class in the test database
        insert testAccs;     
    }
    
    
    @isTest static void TP_RegisterClass_Bulk() {
        //=====================================REGISTER CLASS=================================
        // Extract the class id in the list
        List <Class__c> idClass = [Select id from Class__c];
        // Extract the class id in the list
        List <Account> idAcct = [Select id from Account];
        
        
        // Register for the class generated
        List <Cart__c> carts = new List <Cart__c> ();
        for(Account acc: idAcct){
            for(Class__c cl: idClass){
                carts.add(new Cart__c(Class__c = cl.id,Account__c = acc.id));
            }
        }
        system.debug('carts '+ carts);
        Test.startTest();
        // Perform test Register
        List<Database.SaveResult> results = Database.insert(carts);
        Test.stopTest();
        // Verify insert Account
        Integer numFailed = 0;
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()){
                numFailed += 1;
            }
        }
        // verify insert contact
        List <Cart__c> testCarts = [Select id from Cart__c];
        system.debug('testCarts: '+testCarts);
        System.assertEquals(200,testCarts.size());
    }
    @isTest static void TP_UnregisterClass_Bulk() {
       //================================== UNREGISTER SECTION ============================================================
               // Extract the class id in the list
        List <Class__c> idClass = [Select id from Class__c];
        // Extract the class id in the list
        List <Account> idAcct = [Select id from Account];
        
        
        // Register for the class generated
        List <Cart__c> carts = new List <Cart__c> ();
        for(Account acc: idAcct){
            for(Class__c cl: idClass){
                carts.add(new Cart__c(Class__c = cl.id,Account__c = acc.id));
            }
        }
        insert carts;
        List <Cart__c> testCarts = [Select id from Cart__c];
        system.debug('TestCart size is '+testCarts.size());
        Test.startTest();
        // Perform test Register
        List<Database.deleteResult> resultRemove = Database.delete(testCarts);
        Test.stopTest();
        Integer numFailed = 0;
        // Verify delete cart
        for(Database.deleteResult sr : resultRemove){
            if(!sr.isSuccess()){
                numFailed += 1;
            }
        }
    }
}
