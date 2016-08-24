public with sharing class ExtMassEditInterventi {
    public Id commessaId {get;set;}
    public Intervento__c[] interventi {get;set;}

    public ExtMassEditInterventi(ApexPages.StandardController ctrl) {
    	commessaId = ctrl.getId();
    }

    public PageReference getInterventi() {
        interventi = [SELECT Id,Name,OwnerId,Tipologia_intervento__c,Ore_lavorate__c  FROM Intervento__c WHERE Commessa__c=:commessaId];
    	return null;
    }

    public PageReference updateInterventi() {
        List<Database.SaveResult> results = Database.update(interventi, false);
        for (Database.SaveResult dsr : results) {
            if (!dsr.isSuccess()) {
                for (Database.Error derr : dsr.getErrors()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, derr.getMessage()));
                }
            }
        }
        
    	//return null;
        return new PageReference('/'+commessaId);
    }
}