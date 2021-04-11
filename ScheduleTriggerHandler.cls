public class ScheduleTriggerHandler {
    public static void CheckWorkerRequestAgreement(List<Appointment__c> appointment){
        for(Appointment__c a: appointment){
      
            a.Worker__c = getCorrectWorker(a.Request__c);
        }
    }
    public static void GetPriceForInvoice(String appointment){
        Appointment__c a = [SELECT Id, Invoice__c, Request__c FROM Appointment__c WHERE Id=:appointment];
        Invoice__c invoice = [SELECT Id, Final_Amount_Paid__c FROM Invoice__c WHERE Id=:a.Invoice__c];
        
        // update the price of invoice according to what is shown on menu.
        // also check if invoice have an amount there to begin with, so add on the amount rather than replace
        if(invoice.Final_Amount_Paid__c == null){
            invoice.Final_Amount_Paid__c = GetPrice(a.Request__c);
        }else{
            invoice.Final_Amount_Paid__c += GetPrice(a.Request__c);
        }
        
        update invoice;
    }
    
    // get workerId from request->menu->worker
    private static Id getCorrectWorker(String requestId){
        Request__c worker = [SELECT Id, Menu__r.Worker__r.Id FROM Request__c WHERE Id=:requestId];
        //Request__c request = [SELECT Id, Menu__c FROM Request__c WHERE Id=:requestId];
        //Menu__c menuItem = [SELECT Worker__c FROM Menu__c WHERE Id=:request.Menu__c];
        //Worker__c worker = [SELECT Id FROM Worker__c WHERE Id=:menuItem.Worker__c];
        //System.debug(worker1.Menu__r.Worker__r.Id + ' ' + worker.Id);
        return worker.Menu__r.Worker__r.Id;
    }
    // get the price from menu
    private static Double GetPrice(String requestId){
        Request__c menuItem = [SELECT Id, Menu__r.Price__c FROM Request__c WHERE Id=:requestId];
        //Request__c request = [SELECT Id, Menu__c FROM Request__c WHERE Id=:requestId];
        //Menu__c menuItem = [SELECT Id, Price__c FROM Menu__c WHERE Id=:request.Menu__c];
        //System.debug(menu.Menu__r.Price__c + ' ' + menuItem.Price__c);
        return menuItem.Menu__r.Price__c;
    }
}