@isTest
private class CommessaHandlerTest {
	@isTest
	static void test() {
		Profile p1 = [SELECT Id, Name FROM Profile WHERE Name='Standard User'];
		Account a = new Account(Name = 'test');
		insert a;
		User pm1 = new User(TimeZoneSidKey='America/Los_Angeles',
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing1',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US',
                                  Alias = 'first',
                                  Email='pm@testorg.com',
                                  ProfileId = p1.Id, 
                                  UserName=Crypto.getRandomInteger()+'pm@test.com');
		insert pm1;
		User pm2 = new User(TimeZoneSidKey='America/Los_Angeles',
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing2',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US',
                                  Alias = 'first',
                                  Email='pm@testorg.com',
                                  ProfileId = p1.Id, 
                                  UserName=Crypto.getRandomInteger()+'pm2@test.com');
		insert pm2;

		Commessa__c c1 = new Commessa__c(Name = 'c1', Account__c = a.Id, valore_ordine__c=1000.0, PM__c=pm1.Id);
		insert c1;

		Commessa__c commessaBefore = [SELECT PM__c FROM Commessa__c WHERE Name='c1'];
		System.assertEquals(commessaBefore.PM__c, pm1.Id);

		commessaBefore.PM__c = pm2.Id;
		//Aggiorna commessa e verifica che il PM viene cambiato
		update commessaBefore;
		Commessa__c commessaAfter = [SELECT PM__c FROM Commessa__c WHERE Name='c1'];
		System.assertEquals(commessaAfter.PM__c, pm2.Id);
	}
}