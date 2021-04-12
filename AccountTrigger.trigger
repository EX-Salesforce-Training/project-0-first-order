trigger AccountTrigger on Account (after insert, after update) {
    switch on trigger.operationType{
    	when AFTER_INSERT{
        	AccountTriggerHandler.InsertContact(trigger.new);
            AccountTriggerHandler.InsertPersonalInformation(trigger.new);
            
    	}
        when AFTER_UPDATE{
        	AccountTriggerHandler.UpdateContact(trigger.new);
    	}
    }
}