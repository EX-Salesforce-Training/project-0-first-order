@isTest
public class TestBookTrigger {
    @isTest static void CreateLibBook_Bulk() {
        // Test data setup Generate Good data for Positive Test Bulk
        //create an account
        List<Account> testAccs = new List<Account>();
        for(Integer i = 0; i < 1; i++){
            testAccs.add(new Account(Name='Test' + i, Email__c='test' + i + '@test.com', First_Name__c = 'FirstN' + i, Last_Name__c = 'LastN' + i ));
        }
        insert testAccs;
        
        List <Account> accid = [Select id from Account ];
        system.debug(accid);
        //create bulk books
        List<Book__c> lBook = new List<Book__c>();
        for(Integer i = 0; i < 1; i++){
            for(Account ac : accid){
            	lBook.add(new Book__c(Name='TestBook'+i, Account__c = ac.id));
            }
        }
        Test.startTest();
        // Perform test
        List<Database.SaveResult> results = Database.insert(lBook, false);
        Test.stopTest();
        // Verify insert Account
        Integer numFailed = 0;
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()){
                numFailed += 1;
            }
        }
        // verify insert libBook
        List <Library_book__c> libBook = [Select id from Library_book__c];
        System.assertEquals(1,libBook.size());
        
    }
}
