trigger BookTrigger on Book__c (after insert, before delete) {
	switch on trigger.operationType{
        when AFTER_INSERT{
            BookTriggerHandler.AddBookToLibrary(trigger.new);
        }
    }
}
