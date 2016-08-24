public with sharing class CtrlIntegrazioneGestionale {

	//Utilizzare Endpoint
	private final String wsURL = 'http://demo6276045.mockable.io/newaccount';

	public void avviaIntegrazione() {
	    // Instantiate a new http object
	    Http h = new Http();
	     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(wsURL);
	    req.setMethod('GET');
	    // Send the request, and return a response
	    HttpResponse res = h.send(req);

	    //NEW
	    Account[] accountDaInserire = (Account[]) JSON.deserialize(res.getBody(), Account[].class);
	    upsert accountDaInserire ExternalId__c;

	    try {
	    	upsert accountDaInserire;
	    	} catch (DmlException e) {
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Si è verificato un errore durante la procedura di aggiornamento.'));	    		
	    	}
	}

}