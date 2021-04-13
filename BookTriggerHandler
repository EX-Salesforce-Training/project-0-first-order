public class BookTriggerHandler {
	public static void AddBookToLibrary(List <Book__c> newBook){
		//Creating new Lib book record
        Library_book__c libBook = new Library_book__c();
        for(Book__c b : newBook){
			libBook.Book__c = b.id;
            libBook.Account__c = b.Account__c;       
        }
   		insert libBook;     
	}
}
