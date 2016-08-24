global with sharing class ChiudiCommessa {
	public Commessa__c commessa {get;set;}

	public ChiudiCommessa(ApexPages.StandardController stdCtrl) {
		commessa = (Commessa__c)stdCtrl.getRecord();
	}

	/*webservice static String inviaCommessa(String idcliente, String idcommessa, Double totale) {

		CaricaCommesseChiuse.WsCommesseUtil ccc = new CaricaCommesseChiuse.WsCommesseUtil();
		return ccc.uploadCommessa(idcliente, idcommessa, totale);
		
	}*/
}