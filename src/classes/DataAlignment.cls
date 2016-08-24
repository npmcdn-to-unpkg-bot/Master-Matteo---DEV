//Database.Stateful fa si che le variabili di classe vengano mantenute tra più execution. Altrimenti vengono resettate
global class DataAlignment implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

	Integer inserted = 0;
	Integer notInserted = 0;
	Boolean fatalError = false;
	String fatalErrorMsg = '';

	global List<Account> start(Database.BatchableContext bc) {
		inserted = 0;
		notInserted = 0;
		List<Account> accountDaInserire;
		String wsURL = WebService__c.getValues('WSIntegrazione').Endpoint__c;
	    Http h = new Http();
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(wsURL);
	    req.setMethod('GET');	    
	    try {
	    	HttpResponse res = h.send(req);
	    	accountDaInserire = (List<Account>) JSON.deserialize(res.getBody(), List<Account>.class);
	    	return accountDaInserire;
    	} catch (DmlException e) {
    		// Handle exceptions?
    		fatalError = true;
    		fatalErrorMsg = e.getMessage();
    		return new List<Account>();
    	}
    	
	}


	global void execute(Database.BatchableContext bc, List<Account> scope) {

		Schema.SObjectField externalId = Account.Fields.ExternalId__c;
		List<Database.UpsertResult> results = Database.upsert(scope, externalId, false);

	  	for( Integer i=0; i<results.size(); i++ ){
	  		if(results.get(i).isSuccess()){
	  			inserted ++;
	  		} else{
	  			notInserted ++;
	  		}
  		}
  	}

	global void finish(Database.BatchableContext bc){
		if (fatalError) 
			sendEmail('Sincronizzazione fallita', 'Errore: '+fatalErrorMsg);
		else {
			EmailTemplate et = [SELECT Body, Subject FROM EmailTemplate WHERE DeveloperName = 'Allineamento'];
			sendEmail(et.Subject, et.Body.replace('$$success$$', String.valueOf(inserted)).replace('$$noSuccess$$', String.valueOf(notInserted)));
		}
	}

	private void sendEmail(String subject, String text) {
		// First, reserve email capacity for the current Apex transaction
		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 

		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Salesforce Scheduler');
		mail.setSubject(subject);
		mail.setUseSignature(true);
		//mail.setTreatBodiesAsTemplate(true);
		mail.setPlainTextBody(text);
		mail.setTargetObjectId(UserInfo.getUserId());
		mail.setSaveAsActivity(false);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}


}