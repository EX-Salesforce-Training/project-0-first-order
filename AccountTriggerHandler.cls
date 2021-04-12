public class AccountTriggerHandler{
    public static void InsertContact(List<Account> accList){
        // Query for lookup field
        Account acct = [select Id,Name from Account where Id IN : accList];
        
        //Create the list Buffer for Account
        Contact conBuffer = new Contact ();
        
        for (Account accObj : accList){
            AccountFullNameSolver solver = new AccountFullNameSolver();
            solver.FullNameSolver(accObj);
            
            conBuffer.AccountId = acct.Id;
            conBuffer.LastName = solver.GetLName();
            conBuffer.FirstName = solver.GetFName();
            conBuffer.Phone = accObj.Phone;
            conBuffer.Email=accObj.Email__c;
            conBuffer.Street_Address__c = accObj.Street_Address__c;
            conBuffer.City__c = accObj.City__c;
            conBuffer.State_Province__c = accObj.State_Province__c;
            conBuffer.Postal_Zip_Code__c = accObj.Postal_Zip_Code__c;
            
            // Debug Section
            System.debug('Last Name: '+ solver.GetLName());
            System.debug('First Name: '+ solver.GetFName());
            System.debug('Phone: ' + accObj.Phone);
            System.debug('Email: '+accObj.Email__c);
        }
        try{
            insert conBuffer;
        } catch (DmlException e){
            System.debug(e.getMessage());
        }
        
    }
    public static void UpdateContact(List<Account> accList){   
        // Query for lookup field
        Account acct = [select Id,Name from Account where Id IN : accList];
        //Create the contact Buffer for Account
        Contact conBuffer = new Contact();
        for (Account accObj : accList){
            AccountFullNameSolver solver = new AccountFullNameSolver();
            solver.FullNameSolver(accObj);
            
            // Get all the field from account trigger into the buffer
            conBuffer.AccountId = acct.Id;
            conBuffer.LastName = solver.GetLName();
            conBuffer.FirstName = solver.GetFName();
            conBuffer.Phone = accObj.Phone;
            conBuffer.Email=accObj.Email__c;
            conBuffer.Street_Address__c = accObj.Street_Address__c;
            conBuffer.City__c = accObj.City__c;
            conBuffer.State_Province__c = accObj.State_Province__c;
            conBuffer.Postal_Zip_Code__c = accObj.Postal_Zip_Code__c;
        }
        // Get the list of contacts that belong to the trigger
        List<Contact> conList = [select id from Contact where AccountId in : accList];
        //Create the ConUpdate buffer
        List<Contact> conUpdate = new List <Contact>();
        for (Contact ct : conList){
            // Getting id for buffer
            conBuffer.Id = ct.Id;
            // passing buffer to the database contact
            ct = conBuffer;
            conUpdate.add(ct);
        }
        update conUpdate;
    }
    public static void InsertPersonalInformation(List<Account> accList){
        // Query for lookup field
        Account acct = [select Id,Name from Account where Id IN : accList];
        Personal_Account_Information__c paiBuffer = new Personal_Account_Information__c();
        for (Account accObj : accList){
            AccountFullNameSolver solver = new AccountFullNameSolver();
            solver.FullNameSolver(accObj);
            
            paiBuffer.Last_Name__c = solver.GetLName();
            paiBuffer.First_Name__c = solver.GetFName();
            paiBuffer.Phone__c = accObj.Phone;
            paiBuffer.Email__c = accObj.Email__c;
            paiBuffer.Street_Address__c = accObj.Street_Address__c;
            paiBuffer.City__c = accObj.City__c;
            paiBuffer.State_Province__c = accObj.State_Province__c;
            paiBuffer.Postal_Zip_Code__c = accObj.Postal_Zip_Code__c;
            
            
            // Debug Section
            System.debug('Last Name: '+ solver.GetLName());
            System.debug('First Name: '+ solver.GetFName());
            System.debug('Phone: ' + accObj.Phone);
            System.debug('Email: '+accObj.Email__c);
        }
        try{
            insert paiBuffer;
        } catch (DmlException e){
            System.debug(e.getMessage());
        }    
        
    }
}