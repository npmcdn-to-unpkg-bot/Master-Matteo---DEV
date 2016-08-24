trigger Commessa on Commessa__c (before update) {
	if(Trigger.isUpdate && Trigger.isBefore) {
		CommessaHandler.condividiCommessa(trigger.new, trigger.oldMap);
	}
}