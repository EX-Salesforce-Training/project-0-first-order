public class ScheduleTriggerHandler {
    public static void CheckWorkerRequestAgreement(List<Appointment__c> appointments){
		// make map, key = request Id and value = is just a counter
		// this map will help us get the menu item while keep track of the appointments index
		Map<Id, Integer> requestIdMap = new Map<Id, Integer>();
        Integer counter = 0;
        for(Appointment__c a: appointments){
            requestIdMap.put(a.Request__c, counter);
            counter++;
        }
        
        // now key = counter and value = worker id
        // use this map to get the worker id to change the worker of appointments to the correct person.
        Map<Integer, Id> menuIdMap = new Map<Integer, Id>();
        // query for all request in the requestIdMap keyset to limit the amount of records
        for(Request__c r: [SELECT Id, Menu__r.Worker__c FROM Request__c WHERE Id IN :requestIdMap.keySet()]){
            menuIdMap.put(requestIdMap.get(r.Id), r.Menu__r.Worker__c);
        }
        
        // use menuIdMap to set the menu owner as the Worker for Appointment
        // use the counter to loop.
        for(Integer i = 0; i < counter; i++){
            appointments.get(i).Worker__c = menuIdMap.get(i);
        }
    }
    public static void GetPriceForInvoice(List<Appointment__c> appointments, Set<Id> keySet){
        // get appointments and the Menu ID relating to the Request of the appointment
        List<Appointment__c> appointmentsChangeList = [SELECT Id, Invoice__c, Request__r.Menu__c FROM Appointment__c WHERE Id IN :keySet];
        
        // use these two keyset to limit the amount of record we getting from our query
        Set<Id> invoiceKeySet = new Set<Id>();
        Set<Id> menuKeySet = new Set<Id>();
        for(Appointment__c a: appointmentsChangeList){
            invoiceKeySet.add(a.Invoice__c);
            menuKeySet.add(a.Request__r.Menu__c);
        }
        
        // use the two map to assign the correct pricing to the invoice.
        Map<Id, Invoice__c> invoices = new Map<Id, Invoice__c>([SELECT Id, Final_Amount_Paid__c FROM Invoice__c WHERE Id IN :invoiceKeySet]);
        Map<Id, Menu__c> menus = new Map<Id, Menu__c>([SELECT Id, Price__c FROM Menu__c WHERE Id IN :menuKeySet]);
        
        
        // use this map to keep track of different invoices and later for update
        // key = appointmentsChangeList Invoice Id, value = Invoice object
        Map<Id, Invoice__c> invoiceM = new Map<Id, Invoice__c>();
        
        for(Appointment__c a: appointmentsChangeList){
            // we can only alter the price of the invoice of an appointment if someone added an invoice to that appointment
            if(a.Invoice__c != null){
                // check if the invoice is already in the map
                if(invoiceM.containsKey(a.Invoice__c)){
                    // if it is in the map modify the price of the invoice
                    invoiceM.get(a.Invoice__c).Final_Amount_Paid__c += menus.get(a.Request__r.Menu__c).Price__c;
                }else{
                    // if invoice is not in the map, then we need to put it in.
                    // if invoice doesn't have an amount on it, need to set an amount first
                    // otherwise just add on top of it
                    if(invoices.get(a.Invoice__c).Final_Amount_Paid__c == null){
                        invoices.get(a.Invoice__c).Final_Amount_Paid__c = menus.get(a.Request__r.Menu__c).Price__c;
                    }else{
                        invoices.get(a.Invoice__c).Final_Amount_Paid__c += menus.get(a.Request__r.Menu__c).Price__c;
                    } 
            		invoiceM.put(a.Invoice__c, invoices.get(a.Invoice__c));
                }
            }
        }        
        if(!invoiceM.isEmpty()){
            update invoiceM.values();
        }
    }
}