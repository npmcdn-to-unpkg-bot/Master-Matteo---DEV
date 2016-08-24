public without sharing class CtrlSearchCommesse {
    public Commessa__c[] commesse {get; private set;}

    public Account filtriAccount {get; set;}
    public Commessa__c filtriCommessa {get; set;}
    public Intervento__c filtriIntervento {get; set;}
    public String chiaveDiRicercaTestuale {get;set;}

    /**
     *  Quando viene invocato il metodo assegnaCommessa, la commessa selezionata si troverà in questo campo
     */
    public Id selectedCommessa {get; set;}

    public CtrlSearchCommesse() {
        filtriAccount = new Account();
        filtriCommessa = new Commessa__c();
        filtriIntervento = new Intervento__c();
        commesse  = new Commessa__c[]{};
    }

    public PageReference search() {
        if (filtriIntervento.Ore_lavorate__c==0) filtriIntervento.Ore_lavorate__c=null;
        String query = QueryBuilder.newInstance('Commessa__c', new String[] {'Id', 'Name', 'Account__c'})
            .beginFilter()
                .add('Name', QBOp.QLIKE, filtriCommessa.Name)
                .add('Data_inizio__c', QBOp.QEQUAL, filtriCommessa.Data_inizio__c)
                .add('Data_fine__c', QBOp.QEQUAL, filtriCommessa.Data_fine__c)
                .add('PM__c', QBOp.QEQUAL, filtriCommessa.PM__c)
                .add('Account__r.Name', QBOp.QLIKE, filtriAccount.Name)
                .add('Account__r.Type', QBOp.QEQUAL, filtriAccount.Type)
                .add('Account__r.Industry', QBOp.QEQUAL, filtriAccount.Industry)
                .beginCrossFilter('Intervento__c', 'Commessa__c')
                    .add('Name', QBOp.QLIKE, filtriIntervento.Name)
                    .add('Tipologia_intervento__c', QBOp.QEQUAL, filtriIntervento.Tipologia_intervento__c)
                    .add('Ore_lavorate__c', QBOp.QEQUAL, filtriIntervento.Ore_lavorate__c)
                .endCrossFilter(false)
            .endFilter()
            .getQuery();  
            System.debug(query);
      	commesse = Database.query(query);
        return null;
    }

    public PageReference fullTextSearch() {
        if (!String.isBlank(chiaveDiRicercaTestuale)) {
            String q = 'FIND {'+chiaveDiRicercaTestuale+'} IN ALL FIELDS RETURNING Commessa__c(Id, Name, Account__c), Account(Id)';
            List<List<SObject>> results = Search.query(q);
            List<Commessa__c> commesseTrovate = (List<Commessa__c>) results.get(0);
            List<Account> accountTrovati = (List<Account>) results.get(1);   
            if (!accountTrovati.isEmpty()) {
                for (Account a : accountTrovati) {
                    commesseTrovate.addAll([SELECT Id,Name,Account__c FROM Commessa__c WHERE Account__c=:a.Id]);
                }                
            }
            commesse = commesseTrovate;  
       }       
        return null;
    }

    public PageReference assegna() {
        String currentUser = UserInfo.getUserId();        
        Commessa__c PMSelectedCommessa = [SELECT PM__c FROM Commessa__c WHERE Id=:selectedCommessa ];        
        PMSelectedCommessa.PM__c = currentUser;
        update PMSelectedCommessa;

        PageReference pr = Page.SearchCommesse;
        pr.setRedirect(true);
        return pr;
    }
}