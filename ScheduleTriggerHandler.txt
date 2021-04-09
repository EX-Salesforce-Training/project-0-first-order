public class ScheduleTriggerHandler {
    public static void GetPriceForInvoice(String appointment){
        Appointment__c a = [SELECT Id, Invoice__c, Request__c FROM Appointment__c WHERE Id=:appointment];
        Invoice__c invoice = [SELECT Id, Final_Amount_Paid__c FROM Invoice__c WHERE Id=:a.Invoice__c];
        
        // update the price of invoice according to what is shown on menu.
        // also check if invoice have an amount there to begin with. 
        if(invoice.Final_Amount_Paid__c == null){
            invoice.Final_Amount_Paid__c = GetPrice(a.Request__c);
        }else{
            invoice.Final_Amount_Paid__c += GetPrice(a.Request__c);
        }
        
        update invoice;
    }
    
    // get the price from menu
    private static Double GetPrice(String requestId){
        Request__c request = [SELECT Id, Menu__c FROM Request__c WHERE Id=:requestId];
        Menu__c menuItem = [SELECT Id, Price__c FROM Menu__c WHERE Id=:request.Menu__c];
        return menuItem.Price__c;
    }
}