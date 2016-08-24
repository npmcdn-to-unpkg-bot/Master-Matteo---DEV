@isTest
private class ExtMassEditInterventiTest {
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
	static void test() {
		Account a1 = new Account(Name = 'test1', Industry='Energy', Type='Prospect');
		Account a2 = new Account(Name = 'test2');
		insert a1;
		insert a2;
		Commessa__c c1 = new Commessa__c(Name = 'c1', Account__c = a1.Id, valore_ordine__c=1000.0);
		Commessa__c c2 = new Commessa__c(Name = 'c2', Account__c = a1.Id, valore_ordine__c=1000.0);
		insert c1;
		insert c2;
		Intervento__c i1 = new Intervento__c(Name='i1', Ore_lavorate__c=200, Tipologia_intervento__c='BugFix', Commessa__c=c2.Id);
		Intervento__c i2 = new Intervento__c(Name='i2', Ore_lavorate__c=100, Tipologia_intervento__c='Training', Commessa__c=c2.Id);
		Intervento__c i3 = new Intervento__c(Name='i3', Ore_lavorate__c=100, Tipologia_intervento__c='Training', Commessa__c=c2.Id);
		insert i1;
		insert i2;
		insert i3;

		ExtMassEditInterventi ctrl = new ExtMassEditInterventi(new ApexPages.StandardController(c2));
		List<Intervento__c> li = new List<Intervento__c>();
		li.add(i2);
		li.add(i3);
		ctrl.getInterventi();
		System.assert(compare(ctrl.interventi, li));

		ctrl = new ExtMassEditInterventi(new ApexPages.StandardController(c1));
		li = new List<Intervento__c>();
		ctrl.getInterventi();
		System.assert(compare(ctrl.interventi, li));

		ctrl = new ExtMassEditInterventi(new ApexPages.StandardController(c1));
		li = new List<Intervento__c>();
		i1.name='i11';
		i2.Ore_lavorate__c=1000;
		i3.Ore_lavorate__c = -100;
		li.add(i1);
		li.add(i2);
		li.add(i3);
		ctrl.interventi = li;
		ctrl.updateInterventi();

		i1 = [SELECT Name FROM Intervento__c WHERE Id=:i1.Id];
		i2 = [SELECT Ore_lavorate__c FROM Intervento__c WHERE Id=:i2.Id];
		i3 = [SELECT Ore_lavorate__c, Tipologia_intervento__c FROM Intervento__c WHERE Id=:i3.Id];
		System.assertEquals(i1.Name, 'i11');
		System.assertEquals(i2.Ore_lavorate__c, 1000);
		System.assertEquals(i3.Ore_lavorate__c, 100);
		System.assertEquals(i3.Tipologia_intervento__c, 'Training');
	}
}