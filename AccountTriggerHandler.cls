public class AccountTriggerHandler{
    public static void InsertContact(List<Account> accList){
        // Query for lookup field
        Account acct = [select Id,Name from Account where Id IN : accList];
        
        //Create the list Buffer for Account
        List<Contact> conList = new List <Contact>();
        
        for (Account accObj : accList){
            AccountFullNameSolver solver = new AccountFullNameSolver();
            solver.FullNameSolver(accObj);
            
            Contact conObj = new Contact(
                AccountId = acct.Id,
                LastName = solver.GetLName(),
                FirstName = solver.GetFName(),
                Phone = accObj.Phone,
                Email=accObj.Email__c,
                Street_Address__c = accObj.Street_Address__c,
                City__c = accObj.City__c,
                State_Province__c = accObj.State_Province__c,
                Postal_Zip_Code__c = accObj.Postal_Zip_Code__c
            );
            
            
            conList.add(conObj);
            
            
            // Debug Section
            System.debug('Last Name: '+ solver.GetLName());
            System.debug('First Name: '+ solver.GetFName());
            System.debug('Phone: ' + accObj.Phone);
            System.debug('Email: '+accObj.Email__c);
        }
        try{
            insert conList;
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
        //Create the list Buffer for Account
        List<Personal_Account_Information__c> paiList = new List <Personal_Account_Information__c>();
        
        for (Account accObj : accList){
            AccountFullNameSolver solver = new AccountFullNameSolver();
            solver.FullNameSolver(accObj);
            
            Personal_Account_Information__c paiObj = new Personal_Account_Information__c(
    			//OwnerId = acct.CreatedById,
                Last_Name__c = solver.GetLName(),
                First_Name__c = solver.GetFName(),
                Phone__c = accObj.Phone,
                Email__c = accObj.Email__c,
                Street_Address__c = accObj.Street_Address__c,
                City__c = accObj.City__c,
                State_Province__c = accObj.State_Province__c,
                Postal_Zip_Code__c = accObj.Postal_Zip_Code__c
            );
            
            
            paiList.add(paiObj);
            
            
            // Debug Section
            System.debug('Last Name: '+ solver.GetLName());
            System.debug('First Name: '+ solver.GetFName());
            System.debug('Phone: ' + accObj.Phone);
            System.debug('Email: '+accObj.Email__c);
        }
        try{
            insert paiList;
        } catch (DmlException e){
            System.debug(e.getMessage());
        }    
        
    }
}
