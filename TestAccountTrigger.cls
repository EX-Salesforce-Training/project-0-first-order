@isTest
public class TestAccountTrigger {
    @isTest static void TestCreateAccount() {
        // Test data setup
        // Manually create an account
        Account acct = new Account(Name='test account',Email__c='test@test.com');
        
        // Get the contact just created
        //Contact ct = [SELECT id,Name,Email FROM Contact WHERE AccountId=:acct.Id];
        Test.startTest();
        // Perform test
        Database.SaveResult insertResult = Database.insert(acct);
		Test.stopTest();
        // Verify 
   		//System.assert(insertResult.isSuccess());
        if(!insertResult.isSuccess()){
            for(Database.Error err : insertResult.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }
        }
        //System.assertEquals(acct.Name,ct.Name);
        //System.assertEquals(acct.Email__c,ct.Email);
	}
    @isTest static void UpdateAccount() {
		// Test data setup
        // Manually create an account
        //Account acct = new Account(Name='test account',Email__c='test@test.com');
        
        // Get the contact just created
        //Contact ct = [SELECT id,Name,Email FROM Contact WHERE AccountId=:acct.Id];
        
        // Perform test
        //Database.upsertertResult = Database.upsert(acct, false);

        // Verify 
   		//System.assert(!insertResult.isSuccess());
        //System.assertEquals(acct.Name,ct.Name);
        //System.assertEquals(acct.Email__c,ct.Email);
}
}