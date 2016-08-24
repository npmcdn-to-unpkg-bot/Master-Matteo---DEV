trigger Intervento on Intervento__c (after insert, before insert, before update, after update, after delete) {
	if(Trigger.isUpdate && Trigger.isAfter) {
		InterventoHandler.aggiornaOreCommessaDopoAggiornamentoIntervento(trigger.new, trigger.old);
	}
	if(Trigger.isUpdate && Trigger.isBefore) {
		InterventoHandler.aggiornaCosto(trigger.new, trigger.old);
	}
	if(Trigger.isInsert && Trigger.isAfter) {
		InterventoHandler.aggiornaOreCommessaDopoCreazioneIntervento(trigger.new);
	}
	if(Trigger.isInsert && Trigger.isBefore) {
		InterventoHandler.impostaCosto(trigger.new);
	}
	if(Trigger.isDelete && Trigger.isAfter) {
		InterventoHandler.aggiornaOreCommessaDopoEliminazioneIntervento(trigger.old);
	}

}