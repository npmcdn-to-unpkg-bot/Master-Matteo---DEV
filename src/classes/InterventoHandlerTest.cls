@isTest
private class InterventoHandlerTest {

	static boolean compare(List<sObject> l1, List<sObject> l2) {
		Map<Id, sObject> objMap1 = new Map<Id, sObject>();
		Map<Id, sObject> objMap2 = new Map<Id, sObject>();

		for(sObject o : l1) {
		    objMap1.put(o.Id, o);
		}

		for(sObject o : l2) {
		    objMap2.put(o.Id, o);
		}

		Integer count = 0;
		for (sObject o : l1)
			if (objMap2.containsKey(o.Id))
				count ++;

		if (objMap2.size()== count)
			return true;
		else
			return false;
	}

	@isTest
	static void impostaCosto() {
		Account a1 = new Account(Name = 'test1', Industry='Energy', Type='Prospect');
		Account a2 = new Account(Name = 'test2');
		Profile p1 = [SELECT Id, Name FROM Profile WHERE Name='Standard User'];
		User u1 = new User(TimeZoneSidKey='America/Los_Angeles',
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing1',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US',
                                  Alias = 'first',
                                  Email='pm@testorg.com',
                                  ProfileId = p1.Id, 
                                  UserName=Crypto.getRandomInteger()+'pm@test.com',
                                  Costo_orario__c=33);
		User u2 = new User(TimeZoneSidKey='America/Los_Angeles',
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing2',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US',
                                  Alias = 'first',
                                  Email='pm@testorg.com',
                                  ProfileId = p1.Id, 
                                  UserName=Crypto.getRandomInteger()+'pm2@test.com');
		insert a1;
		insert a2;
		insert u1;
		insert u2;

        //User con costo orario=10
        /**System.runAs(u1) {
        	Commessa__c c1 = new Commessa__c(Name = 'c1', Account__c = a1.Id, valore_ordine__c=1000.0);
			insert c1;
        	Intervento__c i1 = new Intervento__c(Name='i1', Ore_lavorate__c=200, Tipologia_intervento__c='BugFix', Commessa__c=c1.Id);
			Intervento__c i2 = new Intervento__c(Name='i2', Ore_lavorate__c=100, Tipologia_intervento__c='Training', Commessa__c=c1.Id);
			insert i1;
			insert i2;

			List<Intervento__c> interventiAggiornati = [SELECT Id, Name, costo__c FROM Intervento__c];
			System.assertEquals(interventiAggiornati.get(0).costo__c, 2000);
			System.assertEquals(interventiAggiornati.get(1).costo__c, 1000);
        }**/

	    Impostazioni__c setting = new Impostazioni__c();
	    setting.SetupOwnerId = u2.ProfileId;
	    setting.Name = u2.Name;
	    setting.CostoOrarioMedio__c = 5;
	    insert setting;

        System.runAs(u2) {
        	Commessa__c c2 = new Commessa__c(Name = 'c2', Account__c = a1.Id, valore_ordine__c=1000.0);
			insert c2;
	        System.debug(Impostazioni__c.getInstance(u2.ProfileId));
        	Intervento__c i3 = new Intervento__c(Name='i3', Ore_lavorate__c=200, Tipologia_intervento__c='BugFix', Commessa__c=c2.Id);
			Intervento__c i4 = new Intervento__c(Name='i4', Ore_lavorate__c=100, Tipologia_intervento__c='Training', Commessa__c=c2.Id);
			insert i3;
			insert i4;

			i3 = [SELECT Id, Name, costo__c FROM Intervento__c WHERE Name='i3'];
			System.assertEquals(i3.costo__c, 1000);
			i4 = [SELECT Id, Name, costo__c FROM Intervento__c WHERE Name='i4'];
			System.assertEquals(i4.costo__c, 500);
        }


        
	}
}