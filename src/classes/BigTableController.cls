public with sharing class BigTableController {

    @RemoteAction
    public static List<Account> getAllAccounts() {
        List<Account> allAccs = [SELECT Id, Name, OwnerId, CreatedDate, CreatedById, LastModifiedById, LastModifiedDate, CleanStatus FROM Account limit 2000];
        return allAccs;
    }
}