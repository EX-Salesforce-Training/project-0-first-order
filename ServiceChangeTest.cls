@isTest
public class ServiceChangeTest {

    @isTest
    static void TestWorkerPositive(){
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer;Trainer');
        insert w;
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer', Service_Available__c=true);
        insert m1;
        Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
        insert m2;
        Menu__c m3 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=12, Service__c='Veterinarian', Service_Available__c=false);
        insert m3;
        
        // update worker service by removing groomer and adding veterinarian1
        w.Service__c='Trainer;Veterinarian';
        update w;
        
        Menu__c groomerTest = [Select Service_Available__c, id FROM Menu__c Where id=:m1.Id];
        Menu__c vetTest = [Select Service_Available__c, id FROM Menu__c Where id=:m3.Id];
        
        System.assertEquals(false, groomerTest.Service_Available__c);
        System.assertEquals(true, vetTest.Service_Available__c);
    }
    @isTest
    static void TestWorkerBulk(){
        List<Worker__c> workerL = new List<Worker__c>();
        List<Menu__c> menuL = new List<Menu__c>();
        // for testing
        List<String> groomerMenuItems = new List<String>();
        for(Integer i  = 0 ; i < 5; i++){
            Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker' + i, Service__c='Groomer;Trainer');
            workerL.add(w);
        }
        
        Test.startTest();
        insert workerL;
        for(Worker__c w: workerL){
            Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer', Service_Available__c=true);
            
            Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
            
            Menu__c m3 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=12, Service__c='Veterinarian', Service_Available__c=false);
           	
        	groomerMenuItems.add(m1.Id);
            menuL.add(m1);
            menuL.add(m2);
            menuL.add(m3);
        }
        
        insert menuL;    
        // update worker service by removing groomer and adding veterinarian
        for(Worker__c w: workerL){
            w.Service__c='Trainer;Veterinarian';
        }
        update workerL;
        // if any groomer is set to true then test fail
        boolean groomerUpdated = true;
        
        Integer groomerTest = [Select count() FROM Menu__c WHERE Service_Available__c=true and Service__c='Groomer'];
        System.debug(groomerTest);
        if(groomerTest > 0){
            groomerUpdated = false;
        }
        Test.stopTest();
        System.assert(groomerUpdated);
        
    }
    @isTest
    static void TestWorkerRestrictUser(){
        // scheduler shouldn't be able to edit worker that they do not own
        // once they create it, they have to change the owner ship to worker, is the rule I decided
        Profile p = [SELECT id FROM profile WHERE name = 'Scheduler'];
        User testUser = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail.com', 
                                 Alias = 'test', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = p.Id, 
                                 LanguageLocaleKey = 'en_US');  
        
        // worker start as a groomer and a trainer
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer;Trainer');
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
        boolean exCaught = false;
        Test.startTest();
        try{
            insert w;
            System.runAs(testUser) {
                // update worker service by removing groomer and adding veterinarian
                // something a scheduler shouldn't be able to do.
                w.Service__c='Trainer;Veterinarian';
                update w;
            }
        }catch(Exception e){
            System.debug(e);
            exCaught = true;
        }
        Test.stopTest();
        System.assert(exCaught);
        
    }
    
    
}