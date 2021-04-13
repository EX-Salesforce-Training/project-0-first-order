@isTest
public class TestAccountTrigger {
    @isTest static void TP_CreateContactPersonal_Bulk() {
        // Test data setup
        //create an account
        List<Account> testAccs = new List<Account>();
        for(Integer i = 0; i < 200; i++){
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', First_Name__c = 'FirstN' + i, Last_Name__c = 'LastN' + i ));
        }

        Test.startTest();
        // Perform test
        List<Database.SaveResult> results = Database.insert(testAccs, false);
        Test.stopTest();
        // Verify insert Account
        Integer numFailed = 0;
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()){
                numFailed += 1;
            }
        }
        // verify insert contact
        List <Contact> contacts = [Select id,LastName from Contact];
        system.debug('Table From test :'+contacts);
        System.assertEquals(200,contacts.size());
    }
    @isTest static void TN_CreateContactPersonal_Bulk() {
        // Test data setup
        //create an account
        List<Account> testAccs = new List<Account>();
        for(Integer i = 0; i < 200; i++){
            // Just email
            if ( math.mod(i,2) ==0){
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com'));
            }
            // Missing LastName
            else if (math.mod(i,3) ==0){
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', First_Name__c='Test' + i));
            } else {
               // Missing FirstName
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', Last_Name__c='Test' + i));
            } 
        }

        Test.startTest();
        // Perform test
        List<Database.SaveResult> results = Database.insert(testAccs, false);
        Test.stopTest();
        // Verify insert Account
        Integer numFailed = 0;
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()){
                numFailed += 1;
            }
        }
        // verify insert contact
        List <Contact> contacts = [Select id,LastName from Contact];
        system.debug('Table From test :'+contacts);
        System.assertEquals(200,contacts.size());
    }
    @isTest static void UpdateAccount() {
        // Test data setup
        //create an account
        List<Account> testAccs = new List<Account>();
        for(Integer i = 0; i < 200; i++){
            // Just email
            if ( math.mod(i,2) ==0){
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com'));
            }
            // Missing LastName
            else if (math.mod(i,3) ==0){
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', First_Name__c='Test' + i));
            } else {
               // Missing FirstName
                testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', Last_Name__c='Test' + i));
            } 
        }


        // update account
        List <Account> accts = [Select id,Last_Name__c,First_Name__c,Email__c from Account];
        Integer change = 200;
        for (contact acct : accts){
                acct.First_Name__c= 'Test' + change;
                acct.Email__c= 'test' + change + '@test.com';
                acct.Last_Name__c='Test' + change;
            change ++;
        }

        
                Test.startTest();
        // Perform test
        List<Database.SaveResult> results = Database.update(accts);
        Test.stopTest();
        // Verify insert Account
        Integer numFailed = 0;
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()){
                numFailed += 1;
            }
        }
    }
    
}
