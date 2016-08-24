public class CommessaHandler {

	static final String sharingReasonPM = Schema.Commessa__Share.RowCause.AggiornaPM__c;

	public static void condividiCommessa(Commessa__c[] triggerNew, Map<Id, Commessa__c> oldMap) {
		Commessa__c[] commesseDaCondividere = new Commessa__c[]{};
		List<Commessa__Share> commesseShare = new List<Commessa__Share>();

		for(Commessa__c c : triggerNew) {
			if(c.PM__c != oldMap.get(c.Id).PM__c) {
				commesseDaCondividere.add(c);
				Commessa__Share commessaShare = new Commessa__Share();
				commessaShare.parentId = c.Id;
				commessaShare.UserOrGroupId = c.PM__c;
				commessaShare.RowCause = sharingReasonPM;
				commesseShare.add(commessaShare);
			}
		}

		List<Commessa__Share> commessaRevokeList = [SELECT Id FROM Commessa__Share WHERE parentId IN :commesseDaCondividere AND RowCause=:sharingReasonPM];
		Database.delete(commessaRevokeList, false);
		Database.insert(commesseShare,false);		
		

	}
}