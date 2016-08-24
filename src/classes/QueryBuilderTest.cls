@isTest
private class QueryBuilderTest {
	@isTest
	static void test() {
		Account acc = new Account(Name = 'Burlington');

		String query = QueryBuilder.newInstance('Account', new String[] {'Name', 'Id', 'Industry'})
			.beginFilter()
				.add('Industry', QBOp.QNOT_EQUAL, 'pippo')
				.add('CreatedDate', QBOp.QEQUAL, Datetime.newInstance(Date.today(), Time.newInstance(10, 2, 3, 123)))
				.beginOr()
					.add('Name', QBOp.QLIKE, acc.Name)
					.add('Name', QBOp.QIN, new Set<String>{'a','b'})
				.end()
				.beginOr()
					.add('Name', QBOp.QLIKE, acc.Name)
					.add('Industry', QBOp.QNOT_EQUAL, 'pippo')
				.end()
			.endFilter()
			.orderBy(new String[]{'Name','Id'})
			.setLimit(10)
			.getQuery();

		System.assertEquals('SELECT Name, Id, Industry FROM Account WHERE Industry != \'pippo\' AND CreatedDate = 2016-03-23T10:02:03.123+0100 AND (Name LIKE \'Burlington\' OR Name IN (\'a\',\'b\')) AND (Name LIKE \'Burlington\' OR Industry != \'pippo\') ORDER BY Name, Id LIMIT 10', query);
	}

	@isTest
	static void testComplex() {
		Account filtriAccount = new Account(Name = 'Account*');
		Contact c = new Contact(LastName = 'pippo');

		String query = QueryBuilder.newInstance('Account', new String[] {'Id', 'Name', 'Account__c'})
			.beginFilter()
				.add('Parent.Name', QBOp.QLIKE, filtriAccount.Name)
				.add('Parent.Type', QBOp.QEQUAL, filtriAccount.Type)
				.add('Parent.Industry', QBOp.QEQUAL, filtriAccount.Industry)
				.add('Name', QBOp.QLIKE, filtriAccount.Name)
				.beginCrossFilter('AccountId', 'Contact')
					.add('LastName', QBOp.QLIKE, c.LastName)
				.endCrossFilter(false)
			.endFilter()
			.getQuery();

		System.assertEquals('SELECT Id, Name, Account__c FROM Account WHERE Parent.Name LIKE \'Account%\' AND Name LIKE \'Account%\' AND Id IN (SELECT Contact FROM AccountId WHERE LastName LIKE \'pippo\')', query);
	}
}