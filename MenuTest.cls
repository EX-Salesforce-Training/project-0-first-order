@isTest
public class MenuTest {

    @isTest
    static void TestMenuPositive(){
        
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert w;
        Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
        insert m2;
        
        Menu__c trainerTest = [Select Service_Available__c, id FROM Menu__c Where id=:m2.Id Limit 1];
        
        System.assertEquals(false, trainerTest.Service_Available__c);
        
    }
    
    @isTest
    static void TestMenuBulk(){
        List<Worker__c> workerL = new List<Worker__c>();
        List<Menu__c> menuL = new List<Menu__c>();
        
        for(Integer i  = 0 ; i < 5; i++){
            Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker' + i, Service__c='Groomer');
            workerL.add(w);
        }
        
        Test.startTest();
        insert workerL;
        for(Worker__c w: workerL){
            Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
            
            Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
            
            Menu__c m3 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=12, Service__c='Veterinarian');
           	
            menuL.add(m1);
            menuL.add(m2);
            menuL.add(m3);
        }
        insert menuL;   
        List<Menu__c> menuTest = [SELECT Service_Available__c, Service__c FROM Menu__c];
        Boolean insertCorrected = true;
        for(Menu__c m: menuTest){
            if(m.Service__c == 'Groomer' && m.Service_Available__c == false){
                insertCorrected = false;
                break;
            }
            if((m.Service__c == 'Trainer' || m.Service__c == 'Veterinarian') && m.Service_Available__c == true){
                insertCorrected = false;
                break;
            }
        }
        System.assert(insertCorrected);
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