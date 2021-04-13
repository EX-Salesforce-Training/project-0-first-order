@isTest
public class ScheduleTest {
	@isTest
    static void TestScheduleInsertPositive(){
        // worker->menu->request  
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
    @isTest
    static void TestScheduleNegative(){
        Worker__c worker = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert worker;
        Menu__c menu = new Menu__c(Worker__c=worker.Id, Dog_breed__c='Something', Price__c=10, Service__c='Groomer');
        insert menu;
        Request__c request = new Request__c(Menu__c=menu.Id);
        insert request;
        Customer_Account__c cAccount= new Customer_Account__c(Something_Private__c='Not a Real Person');
        insert cAccount;
        Invoice__c invoice = new Invoice__c(Customer_Account__c = cAccount.Id);
        insert invoice;
        
        Worker__c worker2 = new Worker__c(Address__c='Test Blv', Name='TestWorker2', Service__c='Groomer');
        insert worker2;
        // test if you can put in appointment with wrong worker request combo, so worker2 with worker request.
        Appointment__c appointment = new Appointment__c(Request__c=request.Id, Worker__c=worker2.id);
        insert appointment;
        Appointment__c testApp = [SELECT Worker__c FROM Appointment__c Limit 1];
        // it should change the appointmenrt to worker instead of leaving it as worker2.
        System.assertEquals(worker.Id, testApp.Worker__c);
    }
    @isTest
    static void TestScheduleBulk(){
        // set how many request will be put on one invoice
        Double numberOfRequest = 100;
        Double priceOnMenu = 10;
        
        Worker__c worker = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert worker;
        
        
        Menu__c menu = new Menu__c(Worker__c=worker.Id, Dog_breed__c='Something', Price__c=priceOnMenu, Service__c='Groomer');
        insert menu;
        
        // need customer account for there to be invoices
        Customer_Account__c cAccount= new Customer_Account__c(Something_Private__c='Not a Real Person');
        insert cAccount;
        
        Invoice__c invoice = new Invoice__c(Customer_Account__c = cAccount.Id);
        insert invoice;
        
        List<Request__c> requestL = new List<Request__c>();
        
        for(Integer i = 0; i < numberOfRequest; i++){
            requestL.add(new Request__c(Menu__c=menu.Id));
        }

        insert requestL;
        
        List<Appointment__c> appointmentL = new List<Appointment__c>();
        
        for(Request__c request: requestL){
            // same worker and invoice, but different requests
            appointmentL.add(new Appointment__c(Request__c=request.Id, Worker__c=worker.id, Invoice__c=invoice.Id));
        }
        
        System.debug(appointmentL);
        
        insert appointmentL;
        
        Integer testAppCount = [SELECT count() FROM Appointment__c];
        // as many appointments as there are requests
        System.assertEquals(numberOfRequest, testAppCount);
            
        Invoice__c testPriceTotal = [SELECT Id, Final_Amount_Paid__c FROM Invoice__c WHERE Id=:invoice.Id Limit 1];
        
        
        // expected value should be 10*numberOfRequest.
        System.assertEquals(priceOnMenu*numberOfRequest, testPriceTotal.Final_Amount_Paid__c);
    }
    @isTest
    static void TestScheduleRestrictedUser(){
        // Worker shouldn't be able to work with menu request of other worker to make their own schedule
        Profile p = [SELECT id FROM profile WHERE name = 'Worker'];
        User testUser = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail.com', 
                                 Alias = 'test', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = p.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        // put in a request relate to a menu item belong to a worker
        // then as a testUser try to create new schedule with that request and that worker 
        Worker__c worker = new Worker__c(Address__c='Test Blv', Name='TestWorker', Service__c='Groomer');
        insert worker;
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
        }catch(Exception e){
            System.debug(e);
            insertStopped = true;
        }
        System.assert(insertStopped);
    }
}