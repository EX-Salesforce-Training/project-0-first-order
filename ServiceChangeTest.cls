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
        
        // update worker service by removing groomer and adding veterinarian
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
        // scheduler shouldn't be able to edit worker they can only create it
        Profile p = [SELECT id FROM profile WHERE name = 'Scheduler'];
        User testUser = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail..com', 
                                 Alias = 'test', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = p.Id, 
                                 LanguageLocaleKey = 'en_US');  
        
        // worker start as a groomer and a trainer
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer;Trainer');
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
        boolean dmlexCaught = false;
        Test.startTest();
        try{
            System.runAs(testUser) {
                insert w;
                // update worker service by removing groomer and adding veterinarian
                // something a scheduler shouldn't be able to do.
                w.Service__c='Trainer;Veterinarian';
            }
        }catch(DMLException e){
            System.debug(e);
            dmlexCaught = true;
        }
        Test.stopTest();
        System.assert(dmlexCaught);
        
    }
    
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
    static void TestMenuRestrictUser(){
        // scheduler shouldn't be able to edit or create menu
        Profile p = [SELECT id FROM profile WHERE name = 'Scheduler'];
        User testUser = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail..com', 
                                 Alias = 'test', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = p.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        Worker__c w = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert w;
        Menu__c m1 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
        insert m1;
        Menu__c m2 = new Menu__c(Worker__c=w.Id, Dog_breed__c='Something', Price__c=11, Service__c='Trainer');
        
        Test.startTest();
        boolean insertStopped = false;
        boolean updateStopped = false;
        
        try{
            System.runAs(testUser){
                insert m2;
            }
        }catch(DMLException e){
            insertStopped = true;
        }
        try{
            System.runAs(testUser){
                m1.Service__c = 'Veterinarian';
                update m1;
            }
        }catch(DMLException e){
            updateStopped = true;
        }
        Test.stopTest();
        System.assert(insertStopped);
        System.assert(updateStopped);
    }
    @isTest
    static void TestScheduleInsertPositive(){
        Worker__c worker = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert worker;
        // price of menu is set to $10.45 so invoice assertion should be the same.
        Menu__c menu = new Menu__c(Worker__c=worker.Id, Dog_breed__c='Something', Price__c=10.45, Service__c='Groomer');
        insert menu;
        Request__c request = new Request__c(Menu__c=menu.Id);
        insert request;
        Customer_Account__c cAccount= new Customer_Account__c(Something_Private__c='Not a Real Person');
        insert cAccount;
        
        Invoice__c invoice = new Invoice__c(Customer_Account__c = cAccount.Id, Final_Amount_Paid__c = 20);
        insert invoice;
        
        // test on insertion
        Appointment__c appointment = new Appointment__c(Request__c=request.Id, Worker__c=worker.id, Invoice__c=invoice.Id);
        insert appointment;
        
        Invoice__c invoiceChecker = [SELECT Id, Final_Amount_Paid__c FROM Invoice__c WHERE Id=:invoice.Id];
        // there is another charge tacked on to invoice prior to the charge for the main service, so final price should be $30.45
        System.assertEquals(30.45, invoiceChecker.Final_Amount_Paid__c);
        
    }
    @isTest
    static void TestScheduleRestrictedUser(){
        // scheduler shouldn't be able to edit or create menu
        Profile p = [SELECT id FROM profile WHERE name = 'Worker'];
        User testUser = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail..com', 
                                 Alias = 'test', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = p.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        // put in worker, menu, request, then as a different user try to create new schedule
        Worker__c worker = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert worker;
        // price of menu is set to $10.45 so invoice assertion should be the same.
        Menu__c menu = new Menu__c(Worker__c=worker.Id, Dog_breed__c='Something', Price__c=10.45, Service__c='Groomer');
        insert menu;
        Request__c request = new Request__c(Menu__c=menu.Id);
        insert request;
        Customer_Account__c cAccount= new Customer_Account__c(Something_Private__c='Not a Real Person');
        insert cAccount;
        Invoice__c invoice = new Invoice__c(Customer_Account__c = cAccount.Id, Final_Amount_Paid__c = 20);
        insert invoice;
        Boolean insertStopped = false;
        try{
            System.runAs(testUser){
                Appointment__c appointment = new Appointment__c(Request__c=request.Id, Worker__c=worker.id, Invoice__c=invoice.Id);
                insert appointment;
            }
        }catch(DMLException e){
            System.debug(e);
            insertStopped = true;
        }
        System.assert(insertStopped);
    }
    @isTest
    static void TestScheduleUpdatePositive(){
        Worker__c worker = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert worker;
        // price of menu is set to $15.50 so invoice assertion should be the same after updating schedule with an invoice.
        Menu__c menu = new Menu__c(Worker__c=worker.Id, Dog_breed__c='Something', Price__c=15.50, Service__c='Groomer');
        insert menu;
        Request__c request = new Request__c(Menu__c=menu.Id);
        insert request;
        Customer_Account__c cAccount= new Customer_Account__c(Something_Private__c='Not a Real Person');
        insert cAccount;
        Invoice__c invoice = new Invoice__c(Customer_Account__c = cAccount.Id);
        insert invoice;
        
        // test on update
        // no invoice at the creation of appointment
        Appointment__c appointment = new Appointment__c(Request__c=request.Id, Worker__c=worker.id);
        insert appointment;
        
        // update appointment with an invoice
        appointment.Invoice__c = invoice.Id;
        update appointment;
        
        Invoice__c invoiceChecker = [SELECT Id, Final_Amount_Paid__c FROM Invoice__c WHERE Id=:invoice.Id];
        System.assertEquals(15.50, invoiceChecker.Final_Amount_Paid__c);

    }
}