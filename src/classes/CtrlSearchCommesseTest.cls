@isTest
private class CtrlSearchCommesseTest {

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
	static void search() {
		Account a1 = new Account(Name = 'test1', Industry='Energy', Type='Prospect');
		Account a2 = new Account(Name = 'test2');
		Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User pm = new User(TimeZoneSidKey='America/Los_Angeles',
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US',
                                  Alias = 'first',
                                  Email='pm@testorg.com',
                                  ProfileId = p1.Id, 
                                  UserName=Crypto.getRandomInteger()+'pm@test.com');
		User pm2 = new User(TimeZoneSidKey='America/Los_Angeles',
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US',
                                  Alias = 'first',
                                  Email='pm@testorg.com',
                                  ProfileId = p1.Id, 
                                  UserName=Crypto.getRandomInteger()+'pm2@test.com');
		insert a1;
		insert a2;
		insert pm;
		insert pm2;

		Commessa__c c1 = new Commessa__c(Name = 'c1', Account__c = a1.Id, valore_ordine__c=1000.0);
		Commessa__c c2 = new Commessa__c(Name = 'c2', Account__c = a1.Id, PM__c=pm.Id, valore_ordine__c=1000.0);
		Commessa__c c3 = new Commessa__c(Name = 'c3', Account__c = a2.Id, valore_ordine__c=1000.0, Data_inizio__c=Date.newInstance(2016,01,01));
		Commessa__c c4 = new Commessa__c(Name = 'c4', Account__c = a2.Id, valore_ordine__c=1000.0, Data_fine__c=Date.newInstance(2016,12,12));
		Commessa__c c5 = new Commessa__c(Name = 'commessa5', Account__c = a2.Id, valore_ordine__c=1000.0, Data_inizio__c=Date.newInstance(2016,01,01), Data_fine__c=Date.newInstance(2017,01,01));
		insert c1;
		insert c2;
		insert c3;
		insert c4;
		insert c5;

		Intervento__c i1 = new Intervento__c(Name='i1', Ore_lavorate__c=200, Tipologia_intervento__c='BugFix', Commessa__c=c1.Id);
		Intervento__c i2 = new Intervento__c(Name='i2', Ore_lavorate__c=100, Tipologia_intervento__c='Training', Commessa__c=c2.Id);
		insert i1;
		insert i2;

		//Filtri su commessa
		CtrlSearchCommesse ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.Name = 'c1';
		ctrl.search();
		List<Commessa__c> lc = new List<Commessa__c>();
		lc.add(c1);
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.Name = '';
		ctrl.search();
		lc = new List<Commessa__c>();
		System.assert(compare(ctrl.commesse, lc));

		//Filtri su Intervento
		ctrl = new CtrlSearchCommesse();
		ctrl.filtriIntervento.Tipologia_intervento__c = 'BugFix';
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c1);
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.filtriIntervento.Ore_lavorate__c = 100;
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c2);
		System.assert(compare(ctrl.commesse, lc));

		//Filtri su account
		ctrl = new CtrlSearchCommesse();
		ctrl.filtriAccount.Name = 'test1';
		ctrl.filtriAccount.Type = 'Prospect';
		ctrl.filtriAccount.Industry = 'Energy';
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c1);
		lc.add(c2);
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.filtriAccount.Type = 'Prospect';
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c1);
		lc.add(c2);
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.filtriAccount.Industry = 'Energy';
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c1);
		lc.add(c2);
		System.assert(compare(ctrl.commesse, lc));

		//Check date filters
		ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.Data_inizio__c = Date.newInstance(2016,01,01);
		ctrl.filtriCommessa.Data_fine__c = Date.newInstance(2017,01,01);
		ctrl.search();	
		lc = new List<Commessa__c>();
		lc.add(c5);
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.Data_inizio__c = Date.newInstance(2016,01,01);
		ctrl.search();	
		lc = new List<Commessa__c>();
		lc.add(c3);
		lc.add(c5);
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.Data_inizio__c = Date.newInstance(2010,01,01);
		ctrl.filtriCommessa.Data_fine__c = Date.newInstance(2011,01,01);
		ctrl.search();	
		lc = new List<Commessa__c>();
		System.assert(compare(ctrl.commesse, lc));

		//PM con commessa
		ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.PM__c = pm.Id;
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c2);
		System.assert(compare(ctrl.commesse, lc));

		//Pm senza commesse
		ctrl = new CtrlSearchCommesse();
		ctrl.filtriCommessa.PM__c = pm2.Id;
		ctrl.search();
		lc = new List<Commessa__c>();
		System.assert(compare(ctrl.commesse, lc));

		ctrl = new CtrlSearchCommesse();
		ctrl.search();
		lc = new List<Commessa__c>();
		lc.add(c1);
		lc.add(c2);
		lc.add(c3);
		lc.add(c4);
		lc.add(c5);
		System.assert(compare(ctrl.commesse, lc));


		//Ricerca su stringa vuota
		ctrl = new CtrlSearchCommesse();
		ctrl.chiaveDiRicercaTestuale = '';
		List<Id> resId = new List<Id>();
		Test.setFixedSearchResults(resId);
		ctrl.fullTextSearch();
		System.assertEquals(ctrl.commesse.size(), resId.size());

		//Ricerca su commessa
		ctrl = new CtrlSearchCommesse();
		ctrl.chiaveDiRicercaTestuale = 'commes';
		resId = new List<Id>();
		resId.add(c5.Id);
		Test.setFixedSearchResults(resId);
		ctrl.fullTextSearch();
		System.assertEquals(ctrl.commesse.get(0).Id, resId.get(0));

		//Ricerca su account
		ctrl = new CtrlSearchCommesse();
		ctrl.chiaveDiRicercaTestuale = 'test';
		resId = new List<Id>();
		resId.add(c1.Id);
		resId.add(c2.Id);
		resId.add(c3.Id);
		resId.add(c4.Id);
		resId.add(c5.Id);
		Test.setFixedSearchResults(resId);
		ctrl.fullTextSearch();
		System.assertEquals(ctrl.commesse.get(0).Id, resId.get(0));
		System.assertEquals(ctrl.commesse.get(1).Id, resId.get(1));
		System.assertEquals(ctrl.commesse.get(2).Id, resId.get(2));
		System.assertEquals(ctrl.commesse.get(3).Id, resId.get(3));
		System.assertEquals(ctrl.commesse.get(4).Id, resId.get(4));	

		//Test cambiamento PM
		System.runAs(pm2) {
			ctrl = new CtrlSearchCommesse();
			ctrl.selectedCommessa = c2.Id;
			ctrl.assegna();
			c2 = [SELECT Id, PM__c FROM Commessa__c WHERE Id=:c2.Id];
			System.assertEquals(c2.PM__c, pm2.Id);
		}

		//Test assegnamento PM
		System.runAs(pm) {
			ctrl = new CtrlSearchCommesse();
			ctrl.selectedCommessa = c3.Id;
			ctrl.assegna();
			c3 = [SELECT Id, PM__c FROM Commessa__c WHERE Id=:c3.Id];
			System.assertEquals(c3.PM__c, pm.Id);
		}
	}
}