@isTest
public class MenuTest {

    @isTest
    static void TestMenuPositive(){
        // add worker and a menu item for a service the worker does not provide.
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert w;
        Menu__c m = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
        insert m;
        
        // query for the new menu that we inserted
        Menu__c trainerTest = [Select Service_Available__c, id FROM Menu__c Where id=:m.Id Limit 1];
        
        // it should be set to false, instead of the default which is true.
        System.assertEquals(false, trainerTest.Service_Available__c);
        
        // set the service to true using the same menu item that we queried
        trainerTest.Service_Available__c = true;
        
        Boolean updatePrevented = false;
        
        // try to update it with service available set to true.
        try{
            update trainerTest;
        }catch(Exception e){
            System.debug(e);
            updatePrevented = true;
        }
        
        // check if updated was prevented from happening.
        System.assert(updatePrevented);
    } 
    
    @isTest
    static void TestMenuBulk(){
        // use list to insert a large amount of worker and menuitem for each worker
        List<Worker__c> workerL = new List<Worker__c>();
        List<Menu__c> menuL = new List<Menu__c>();
        
        for(Integer i  = 0 ; i < 200; i++){
            workerL.add(new Worker__c(Address__c='Test Blv', Name='TestWorker' + i, Service__c='Groomer'));
        }
        
        insert workerL;
        
        for(Worker__c w: workerL){
           	
            menuL.add(new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer'));
            menuL.add(new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer'));
            menuL.add(new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=12, Service__c='Veterinarian'));
        }
        
        insert menuL; 
                        
        // grab the new menuitems we inserted
        // groomer service should be true, and trainer and veterinarian services are set to false
        // we query for the opposite of that and count the return
        System.assertEquals(0, [SELECT count() FROM Menu__c WHERE (Service__c='Groomer' and Service_Available__c=false)
                             or ((Service__c='Trainer' or Service__c='Veterinarian') and Service_Available__c=true)]);
        
    }
    @isTest
    static void TestMenuRestrictUser(){
        // scheduler shouldn't be able to edit or create menu
        Profile schedulerP = [SELECT id FROM profile WHERE name = 'Scheduler'];
        Profile otherWorkerP = [SELECT id FROM profile WHERE name = 'Worker'];
        User testUserInsert = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail.com', 
                                 Alias = 'test1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = schedulerP.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        User testUserUpdate = new User(LastName = 'user 2', 
                                 Username = 'user.2@sfdc.com', 
                                 Email = 'usersm@gmail.com', 
                                 Alias = 'test2', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-2', 
                                 ProfileId = otherWorkerP.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        // inserting some records
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert w;
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
        insert m1;
        Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
        
        Test.startTest();
        boolean insertStopped = false;
        boolean updateStopped = false;
        
        try{
            System.runAs(testUserInsert){
                insert m2;
            }
        }catch(Exception e){
            System.debug(e);
            insertStopped = true;
        }
        try{
            System.runAs(testUserUpdate){
                m1.Service__c = 'Veterinarian';
                update m1;
            }
        }catch(Exception e){
            System.debug(e);
            updateStopped = true;
        }
        Test.stopTest();
        System.assert(insertStopped);
        System.assert(updateStopped);
    }
    
}