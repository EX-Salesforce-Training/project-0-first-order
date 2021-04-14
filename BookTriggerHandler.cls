public class BookTriggerHandler {
	public static void AddBookToLibrary(List <Book__c> newBook){
        List <Library_book__c> libBook = new List <Library_book__c>();
        for(Book__c b : newBook){
        //Creating new Lib book record
        Library_book__c libObj = new Library_book__c(Book__c=b.id, Account__c = b.Account__c);
        libBook.add(libObj);
        }
   		insert libBook;     
	}
}
