public class InterventoHandler {
	public static void impostaCosto(List<Intervento__c> newValue) {
		List<User> utentiConCostoOrario = [SELECT Id, Costo_orario__c FROM User];
		Map<Id, Double> utenteCostoOrario = new Map<Id, Double>();
		for (User u : utentiConCostoOrario) {
			utenteCostoOrario.put(u.Id, u.Costo_orario__c);
		}
		for (Intervento__c i : newValue) { 
			User u = [SELECT name,Costo_orario__c FROM User WHERE Id=:i.OwnerId];
			Double costoOrario = 0;
			Double utenteCosto = utenteCostoOrario.get(i.OwnerId);
			if (utenteCosto==null || utenteCosto==0) {				
				Id currentProfile = UserInfo.getProfileId();
				Impostazioni__c costoOrarioPerProfilo = Impostazioni__c.getInstance(currentProfile);
				costoOrario = costoOrarioPerProfilo.CostoOrarioMedio__c;
			} else {
				costoOrario = utenteCosto;
			}
			i.costo__c = costoOrario * i.Ore_lavorate__c;
		}
	}

	public static void aggiornaCosto(List<Intervento__c> newValue, List<Intervento__c> oldValue) {
		List<User> utentiConCostoOrario = [SELECT Id, Costo_orario__c FROM User];
		Map<Id, Double> utenteCostoOrario = new Map<Id, Double>();
		for (User u : utentiConCostoOrario) {
			utenteCostoOrario.put(u.Id, u.Costo_orario__c);
		}
		for (Intervento__c i : newValue) { 
			Double costoOrario = 0;
			Double utenteCosto = utenteCostoOrario.get(i.OwnerId);
			if (utenteCosto==null || utenteCosto==0) {
				Id currentProfile = UserInfo.getProfileId();
				Impostazioni__c costoOrarioPerProfilo = Impostazioni__c.getInstance(currentProfile);
				costoOrario = costoOrarioPerProfilo.CostoOrarioMedio__c;
			} else {
				costoOrario = utenteCosto;
			}	
			i.costo__c = costoOrario * i.Ore_lavorate__c;
		}
	}

	public static void aggiornaOreCommessaDopoAggiornamentoIntervento(List<Intervento__c> newValue, List<Intervento__c> oldValue) {
		aggiornaOreCommessaDopoEliminazioneIntervento(oldValue);
		aggiornaOreCommessaDopoCreazioneIntervento(newValue);
	}

	public static void aggiornaOreCommessaDopoCreazioneIntervento(List<Intervento__c> newValue) {
		Set<Id> idCommesseDaAggiornare = new Set<Id>();
		for (Intervento__c i : newValue) {
			idCommesseDaAggiornare.add(i.Commessa__c);
		}
		List<Commessa__c> commesseDaAggiornare = new List<Commessa__c>();
		List<Commessa__c> queryResults = [SELECT Id, Ore_Bugfix__c, Ore_sviluppo__c, Ore_training__c FROM Commessa__c WHERE Id IN :idCommesseDaAggiornare FOR UPDATE];
		commesseDaAggiornare.addAll(queryResults);				

		List<Commessa__c> commesseAggiornate = new List<Commessa__c>();
		
		for (Commessa__c c : commesseDaAggiornare) {
			for (Intervento__c i : newValue) {			
				if (i.Commessa__c == c.Id) {
					if (i.Tipologia_intervento__c == 'Bugfix') {
						c.Ore_Bugfix__c+= i.costo__c;
					}
					if (i.Tipologia_intervento__c == 'Sviluppo') {
						c.Ore_sviluppo__c += i.costo__c;
					}
					if (i.Tipologia_intervento__c == 'Training') {
						c.Ore_training__c += i.costo__c;
					}
				}
			}			
			commesseAggiornate.add(c);
		}
		update commesseDaAggiornare;
	}

	public static void aggiornaOreCommessaDopoEliminazioneIntervento(List<Intervento__c> oldValue) {
		Set<Id> idCommesseDaAggiornare = new Set<Id>();
		for (Intervento__c i : oldValue) {
			idCommesseDaAggiornare.add(i.Commessa__c);
		}
		List<Commessa__c> commesseDaAggiornare = new List<Commessa__c>();
		List<Commessa__c> queryResults = [SELECT Id, Ore_Bugfix__c, Ore_sviluppo__c, Ore_training__c FROM Commessa__c WHERE Id IN :idCommesseDaAggiornare FOR UPDATE];
		commesseDaAggiornare.addAll(queryResults);

		List<Commessa__c> commesseAggiornate = new List<Commessa__c>();

		for (Commessa__c c : commesseDaAggiornare) {
			for (Intervento__c i : oldValue) {
			
				if (i.Commessa__c == c.Id) {
					if (i.Tipologia_intervento__c == 'Bugfix') {
						c.Ore_Bugfix__c -= i.costo__c;
					}
					if (i.Tipologia_intervento__c == 'Sviluppo') {
						c.Ore_sviluppo__c -= i.costo__c;
					}
					if (i.Tipologia_intervento__c == 'Training') {
						c.Ore_training__c -= i.costo__c;
					}
				}
			}			
			commesseAggiornate.add(c);
		}
		update commesseDaAggiornare;
	}
		
}