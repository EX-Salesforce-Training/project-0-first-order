@isTest
public class ServiceChangeTest {

    @isTest
    static void TestWorkerPositive(){
        // create data 1 worker and 3 menu item belong to that worker
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer;Trainer');
        insert w;
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer', Service_Available__c=true);
        insert m1;
        Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
        insert m2;
        Menu__c m3 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=12, Service__c='Veterinarian', Service_Available__c=false);
        insert m3;
        
        // update worker service by removing groomer and adding veterinarian
        w.Service__c='Trainer;Veterinarian';
        update w;
        
        // query for the menuitem that should be affected by the update
        Menu__c groomerTest = [Select Service_Available__c, id FROM Menu__c Where id=:m1.Id];
        Menu__c vetTest = [Select Service_Available__c, id FROM Menu__c Where id=:m3.Id];
        
        // Groomer no longer a service this worker offer, and they are now offering veterinarian service
        // so groomer should be false and veterinarian should be true
        System.assertEquals(false, groomerTest.Service_Available__c);
        System.assertEquals(true, vetTest.Service_Available__c);
    }
    @isTest
    static void TestWorkerBulk(){
        // use list to insert a large amount of worker and menuitem for each worker
        List<Worker__c> workerL = new List<Worker__c>();
        List<Menu__c> menuL = new List<Menu__c>();
        
        // create however many workers
        for(Integer i  = 0 ; i < 250; i++){
            workerL.add(new Worker__c(Address__c='Test Blv', Name='TestWorker' + i, Service__c='Groomer;Trainer'));
        }
        
        // need to insert the workers before their menu can be created
        insert workerL;
        
        // go through each worker and add menu item for them
        for(Worker__c w: workerL){
            menuL.add(new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer', Service_Available__c=true));
            menuL.add(new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer'));
           	menuL.add(new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=12, Service__c='Veterinarian', Service_Available__c=false));
        }
        
        // (3 * number of Worker) menu item will be inserted
        insert menuL; 
        
        // update every single worker service by removing groomer and adding veterinarian
        for(Worker__c w: workerL){
            w.Service__c='Trainer;Veterinarian';
        }
        
        update workerL;
        
        // query from menu where groomer is true and veterinarian is false.
        // use count() to get the count of what return.
        // expected result should be 0.
        System.assertEquals(0, [Select count() FROM Menu__c WHERE (Service_Available__c=true and Service__c='Groomer') 
                               or (Service_Available__c=false and Service__c='Veterinarian')]);
    }
    @isTest
    static void TestWorkerRestrictUser(){
        // scheduler can create worker, but shouldn't be able to edit worker that they do not own
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
        
        // create a worker as System admin, so scheduler shouldn't be able to make edit to worker services.
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer;Trainer');
        insert w;
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
        insert m1;
        
        // use this to see if catch block got called.
        Boolean updatePrevented = false;
        
        // as scheduler try to modifies worker services.
        try{
            System.runAs(testUser) {
                // update worker service by removing groomer and adding veterinarian
                // something a scheduler shouldn't be able to do.
                w.Service__c='Trainer;Veterinarian';
                update w;
            }
        }catch(Exception e){
            // if it catches then we change boolean to true.
            System.debug(e);
            updatePrevented = true;
        }
        
        // if catch block run then we succeed in stopping the update.
        System.assert(updatePrevented);
    }
}