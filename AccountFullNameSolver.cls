public class AccountFullNameSolver {
    private String fName;
    private String lName;
    public void FullNameSolver(Account accObj){
        // First Name account exist
        if (accObj.First_Name__c != null){
            fName = accObj.First_Name__c;
        }
        if (accObj.Last_Name__c != null){
            lName = accObj.Last_Name__c;
        } 
        // Last Name is a requirement to create a contact
        // if Last name account doesn't not exist, Last Name contact will name after account name
        else {
            // split up account name for contact FirstName and LastName
            List <String> fullname = accObj.Name.split(' ');
            if(fullname.size()>1){
                fName = fullname.get(0);
                lName = fullname.get(1);
            }
            // FirstName Null otherwise
            else{
                lName = fullname.get(0);
            }
        }
    }
    // Getter
    public String GetFName() {
        return fName;
    }
    public String GetLName() {
        return LName;
    }
}
