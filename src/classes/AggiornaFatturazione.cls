//TEST COMMIT TESTtesttestestatea
@RestResource(urlMapping='/aggiornaFatturazione/*')
global with sharing class AggiornaFatturazione {

    @HttpPost
    global static void aggiorna(String Id, String Stato) {
    	
    	try {
    		Commessa__c commessaDaAggiornare = [SELECT Id, Name, Stato_Fatturazione__c FROM Commessa__c WHERE ID=:Id];
    		commessaDaAggiornare.Stato_Fatturazione__c = stato;
    		update commessaDaAggiornare;
    	} catch (DmlException e) {
    		RestResponse res = RestContext.response;
            res.statusCode = 401;

    	}
    	catch (QueryException e) {
    		RestResponse res = RestContext.response;
            res.statusCode = 401;
    	}
    }
}