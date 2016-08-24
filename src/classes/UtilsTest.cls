@isTest
private class UtilsTest {
    @isTest
    static void testJoin() {
        System.assertEquals('', Utils.join(null, ';'));
        System.assertEquals('item1;item2', Utils.join(new Set<String>{'item1','item2'}, ';'));

        System.assertEquals('item2', Utils.join(null, 'item2', ';'));
        System.assertEquals('item1', Utils.join('item1', null, ';'));
        System.assertEquals('item1;item2', Utils.join('item1', 'item2', ';'));
    }

    @isTest
    static void testSplit() {
        System.assertEquals(true, Utils.split(null, ';').isEmpty());
        String[] sL = Utils.split('item1;item2', ';');
        System.assertEquals('item1', sL[0]);
        System.assertEquals('item2', sL[1]);
    }

    @isTest
    static void testSubstring() {
        System.assertEquals(null, Utils.substring(null, 0, 10));
        System.assertEquals('iao', Utils.substring('ciao', 1, 4));
        System.assertEquals('iao', Utils.substring('ciao', 1, 10));
    }

    @isTest
    static void testFilterBy() {
        Account[] aL = new Account[]{
            new Account(Name = 'a1', BillingStreet = 'street'),
            new Account(Name = 'a2', BillingStreet = 'street'),
            new Account(Name = 'a3', BillingStreet = 'plaza')
        };

        Account[] filteredAL = Utils.filterBy(aL, 'BillingStreet', 'street');
        System.assertEquals(2, filteredAL.size());
        System.assertEquals('a1', filteredAL[0].Name);
        System.assertEquals('a2', filteredAL[1].Name);

        filteredAL = Utils.filterBy(aL, 'BillingStreet', 'street', false);
        System.assertEquals(1, filteredAL.size());
        System.assertEquals('a3', filteredAL[0].Name);

        filteredAL = Utils.filterBy(aL, 'BillingStreet', new Set<String>{'street','plaza'});
        System.assertEquals(3, filteredAL.size());
        System.assertEquals('a3', filteredAL[2].Name);

        Object objectSet = new Set<String>{'street'};
        filteredAL = Utils.filterBy(aL, 'BillingStreet', objectSet, false);
        System.assertEquals(1, filteredAL.size());
        System.assertEquals('a3', filteredAL[0].Name);
    }

    @isTest
    static void testAddCapitalLetters() {
        System.assertEquals(null, Utils.addCapitalLetters(null));
        System.assertEquals('Giorgio Galli', Utils.addCapitalLetters('gIoRgIo GALLI'));
        System.assertEquals('Giorgio Dell\'Adamino', Utils.addCapitalLetters('gIoRgIo deLl\'aDAMINO'));
    }

    @isTest
    static void testToUppercaseOrVoid() {
        System.assertEquals('', Utils.toUppercaseOrVoid(null));
        System.assertEquals('ITEM', Utils.toUppercaseOrVoid('itEm'));
    }

    @isTest
    static void testExtractMap() {
        Account[] aL = new Account[]{
            new Account(Name = 'a1', BillingStreet = 'street1'),
            new Account(Name = 'a2', BillingStreet = 'street2'),
            new Account(Name = 'a3', BillingStreet = 'street3')
        };

        Map<String, SObject> testMap = Utils.extractMap(aL, '{BillingStreet}');
        System.assertEquals(3, testMap.size());
        System.assertEquals(true, testMap.containsKey('street1'));
        System.assertEquals(true, testMap.containsKey('street2'));
        System.assertEquals(true, testMap.containsKey('street3'));
        System.assertEquals('a1', testMap.get('street1').get('name'));
        System.assertEquals('a2', testMap.get('street2').get('name'));
        System.assertEquals('a3', testMap.get('street3').get('name'));

        testMap = Utils.extractMap(aL, '{BillingStreet}_{nAmE}');
        System.assertEquals(3, testMap.size());
        System.assertEquals(true, testMap.containsKey('street1_a1'));
        System.assertEquals(true, testMap.containsKey('street2_a2'));
        System.assertEquals(true, testMap.containsKey('street3_a3'));
        System.assertEquals('a1', testMap.get('street1_a1').get('name'));
        System.assertEquals('a2', testMap.get('street2_a2').get('name'));
        System.assertEquals('a3', testMap.get('street3_a3').get('name'));
    }

    @isTest
    static void testExtractGroupedMap() {
        Account[] aL = new Account[]{
            new Account(Name = 'a1', BillingStreet = 'street1'),
            new Account(Name = 'a1', BillingStreet = 'street1'),
            new Account(Name = 'a2', BillingStreet = 'street1')
        };

        Map<String, SObject[]> testMap = Utils.extractGroupedMap(aL, '{BillingStreet}');
        System.assertEquals(1, testMap.size());
        System.assertEquals(true, testMap.containsKey('street1'));
        System.assertEquals('a1', testMap.get('street1')[0].get('name'));
        System.assertEquals('a1', testMap.get('street1')[1].get('name'));
        System.assertEquals('a2', testMap.get('street1')[2].get('name'));

        testMap = Utils.extractGroupedMap(aL, '{BillingStreet}_{nAmE}');
        System.assertEquals(2, testMap.size());
        System.assertEquals(true, testMap.containsKey('street1_a1'));
        System.assertEquals(true, testMap.containsKey('street1_a2'));
        System.assertEquals('a1', testMap.get('street1_a1')[0].get('name'));
        System.assertEquals('a1', testMap.get('street1_a1')[1].get('name'));
        System.assertEquals('a2', testMap.get('street1_a2')[0].get('name'));

        //Test estrazione su campo non definito in datamodel
        testMap = Utils.extractGroupedMap(aL, '{BillingStreet}_{campoInesistente__c}');
        System.assertEquals(1, testMap.size());
        System.assertEquals(true, testMap.containsKey('street1_null'));
        System.assertEquals('a1', testMap.get('street1_null')[0].get('name'));
        System.assertEquals('a1', testMap.get('street1_null')[1].get('name'));
        System.assertEquals('a2', testMap.get('street1_null')[2].get('name'));
    }

    @isTest
    static void testAddToMultiselect() {
        System.assertEquals('item1', Utils.addToMultiselect(null, 'item1'));
        System.assertEquals('item1;item2', Utils.addToMultiselect('item1;item2', null));
        System.assertEquals('item1;item2;item3', Utils.addToMultiselect('item1;item3', 'item2'));
        System.assertEquals('item1;item2;item3;item4', Utils.addToMultiselect('item4;item3', 'item2;item1'));
    }

    @isTest
    static void testTriggerUtils() {
        Account[] aL = new Account[]{
            new Account(Id = '001g000000CxTGm', Name = 'a1', BillingStreet = 'changedStreet1'),
            new Account(Id = '001g000000CxTGn', Name = 'a2', BillingStreet = 'changedStreet2'),
            new Account(Id = '001g000000CxTGo', Name = 'a3', BillingStreet = 'street3')
        };

        Map<Id, Account> oldAL = new Map<Id, Account>(aL.deepClone(true));
        oldAL.get('001g000000CxTGm').BillingStreet = 'CHANGEDStreet1';
        oldAL.get('001g000000CxTGn').BillingStreet = 'street2';

        Utils.TriggerUtils tu = new Utils.TriggerUtils(aL, oldAL);
        Account[] changedAccounts = tu.getChanged(new String[]{'billingStreet'});
        System.assertEquals(1, changedAccounts.size()); //1 e non 2 perchè i controlli stringa su SFDC sono case insensitive. Attenzione!!
        System.assertEquals('changedStreet2', changedAccounts[0].BillingStreet);

        System.assertEquals(true, tu.getFields() != null);

        Account[] changedAndFilteredAccounts = tu.filterByOld('BillingStreet', 'street2').getChanged(new String[]{'BillingStreet'});
        System.assertEquals(1, changedAndFilteredAccounts.size());
        System.assertEquals('changedStreet2', changedAndFilteredAccounts[0].BillingStreet);

        Utils.TriggerUtils tuFilterByChanged = tu.filterByChanged(new String[]{'billingStreet'});
        System.assertEquals(1, tuFilterByChanged.triggerNew.size());
        System.assertEquals(3, tuFilterByChanged.oldMap.values().size());

        Utils.TriggerUtils tuFilterBy = tu.filterBy('BillingStreet', 'changedStreet2');
        System.assertEquals(1, tuFilterBy.triggerNew.size());
        System.assertEquals(3, tuFilterBy.oldMap.values().size());

        System.assertEquals('Account', tu.getObjectName());
    }

    @isTest
    static void testGetSelectAllQuery() {
        String query = Utils.getSelectAllQuery('Contract', ' AND Id = \'800g000000CxTGm\'', null, '', true);
        System.debug('1:' + query);
        query = Utils.getSelectAllQuery('Contract', ' AND Id = \'800g000000CxTGm\'', null, 'ActivatedBy.Name', false);
        System.debug('2:' + query);
        query = Utils.getSelectAllQuery('Account', ' AND Id = \'0011100000bzZLe\'', null, 'ActivatedBy.Name', false, true);
        System.debug('3:' + query);
        query = Utils.getSelectAllQuery('Account', ' AND Id = \'0011100000bzZLe\'', null, 'ActivatedBy.Name', false, true, new Set<String>{'accountnumber','agenziadiaggiornamento__c'});
        System.debug('4:' + query);
        query = Utils.getSelectAllQueryForPA(' AND Id = \'0011100000bzZLe\'', null, true, true);
        System.debug('5:' + query);
        query = Utils.getSelectAllQuery('Account', ' AND Id = \'0011100000bzZLe\'', null, 'ActivatedBy.Name', false, true, new Set<String>{'accountnumber','agenziadiaggiornamento__c'}, true);
        System.debug('6:' + query);
        /*
        String query = Utils.getSelectAllQuery('Contract', ' AND Id = \'800g000000CxTGm\'', null, '', true);
        System.assertEquals('SELECT accountid,activatedbyid,activateddate,billingcity,billingcountry,billinglatitude,billinglongitude,billingpostalcode,billingstate,billingstreet,companysigneddate,companysignedid,contractterm,currencyisocode,customersigneddate,customersignedid,customersignedtitle,description,ownerexpirationnotice,ownerid,shippingcity,shippingcountry,shippinglatitude,shippinglongitude,shippingpostalcode,shippingstate,shippingstreet,specialterms,startdate,status FROM Contract WHERE AND Id = \'800g000000CxTGm\'', query);
        query = Utils.getSelectAllQuery('Contract', ' AND Id = \'800g000000CxTGm\'', null, 'ActivatedBy.Name', false);
        System.assertEquals('SELECT accountid,activatedby.name,activatedbyid,activateddate,billingaddress,billingcity,billingcountry,billinglatitude,billinglongitude,billingpostalcode,billingstate,billingstreet,companysigneddate,companysignedid,contractnumber,contractterm,createdbyid,createddate,currencyisocode,customersigneddate,customersignedid,customersignedtitle,description,enddate,id,isdeleted,lastactivitydate,lastapproveddate,lastmodifiedbyid,lastmodifieddate,lastreferenceddate,lastvieweddate,ownerexpirationnotice,ownerid,shippingaddress,shippingcity,shippingcountry,shippinglatitude,shippinglongitude,shippingpostalcode,shippingstate,shippingstreet,specialterms,startdate,status,statuscode,systemmodstamp FROM Contract WHERE AND Id = \'800g000000CxTGm\'', query);
        query = Utils.getSelectAllQuery('Account', ' AND Id = \'0011100000bzZLe\'', null, 'ActivatedBy.Name', false, true);
        System.assertEquals('SELECT abitazioneprincipale__pc,abitazionitenuteadisposizione__pc,accountnumber,accountsource,activatedby.name,agenziadiaggiornamento__c,agenziafinanziariaassociata__c,agenziainserprivacy__c,agenziaultimocontattoimmobiliare__c,agfinconsharing__c,agimmconsharing__c,allegatoprivacyid__c,allegatoprivacyid__pc,allegatoprivacyidimm__c,allegatoprivacyinvalidato__c,allegatoprivacyinvalidato__pc,allegatoprivacyinvalidatoimm__c,allegatoprivacypresente__c,allegatoprivacypresenteimm__c,altrotelefono__c,altrotelefononormalizzato__c,altrotelefononormalizzato__pc,ambito__c,annidilavoroimpiegoattuale__pc,anniinitalia__pc,annualrevenue,areamanager__c,attivo__c,attivo__pc,billingaddress,billingcity,billingcountry,billinglatitude,billinglongitude,billingpostalcode,billingstate,billingstreet,cancellatoperprivacyfinanziaria__c,cancellatoperprivacyimmobiliare__c,cancellatoperscartoimmobile__c,cancellazionedabdt__c,cancellazionedamatrix__c,cancellazionedaportale__c,cancellazionigiornaliererimanenti__c,cap__c,capsecondario__c,causaprotestieosofferenze__pc,ccara__c,ccara__pc,cellulare__c,cellularenormalizzato__c,cellularenormalizzato__pc,cittadinanza__pc,clientecondiviso__c,clientetelefonico__c,clientetelefoniconascosto__c,codiceagenziaassociata__c,codicebdt__c,codicecatastale__c,codicecatastalecittadinanza__pc,codicecatastalenascita__pc,codicecatastalesecondario__c,codicecatastaleutente__pc,codiceente__c,codiceente__pc,codiceenteowner__c,codiceenteportale__c,codicefigura__pc,codicefinanziario__c,codicefiscale__c,codicefiscale__pc,codicegruppo__pc,codicegruppoowner__c,codicematrix__c,codiceportale__c,codicereferente__pc,codicerete__c,codicerete__pc,codiceutente__pc,codiceutenteowner__c,compagniapolizzafurtoeincendio__pc,compagniapolizzainfortuni__pc,compagniapolizzalongtermcare__pc,compagniapolizzamalattia__pc,compagniapolizzaprotezionereddito__pc,compagniapolizzaresponsabilitacivile__pc,compagniapolizzatemporaneacasomorte__pc,consensoindexedfield__c,consensoindexedfield__pc,consensoindexedfieldimm__c,consensoinviodatiretetctr__c,consensoinviodatiretetctr__pc,consensomarketing__c,consensomarketing__pc,consensoprivacy1imm__c,consensoprivacy2imm__c,consensoprivacy3imm__c,consensoprivacy4imm__c,consensoprofilazione__c,consensoprofilazione__pc,consulenterete__c,contrattoagenzia__c,coordinate__c,coordinate__latitude__s,coordinate__longitude__s,countdownprivacyattivo__c,countdownprivacyrichiesta__c,createdbyid,createddate,currencyisocode,customeridkironvista__c,daflussoazienda__c,damigrazione__c,dataassunzione__pc,datacancellazioneprivacy__c,datacancellazioneprivacyimm__c,datacreazioneprimarichiesta__c,datadisattivazioneutente__pc,dataelabtalendi01b__c,dataelabtalendi01b__pc,datafidiinessere__pc,dataimportazionedaimmobiliare__c,datainizioattivitautente__pc,datainizioprimoappuntamento__pc,datainserimentostima__c,dataiscrizionealrea__pc,dataprimoappuntamento__pc,dataprivacy__c,dataprossimoappuntamento__pc,datascadenzaaffitto__c,dataultimaattivita__c,dataultimoappuntamento__pc,dataultimocontattoimmobiliare__c,dataupdatecancellazionirimanenti__c,datoredilavoro__pc,description,dicuiportatoridireddito__pc,disattivazioneperprivacy__c,email__c,emailformula__c,emailsecondaria__c,esecutorecancellazioneprivacy__c,esecutorecancellazioneprivacyimm__c,eta__pc,etafigliacarico__pc,eventualifidiinessere__pc,eventualiprotestieosofferenze__pc,extracomunitario__c,famiglia__pc,fax,firmatario__c,firstname,giornidaultimocontattoimmobiliare__c,giornixdisattivazioneimm__c,hasnotizia__c,hasrichiesta__c,hobbyesport__pc,id,idcontratto__c,idnominativo__pc,idtitolarefin__c,idutentifin__c,importofidiinessere__pc,indirizzo__c,indirizzoagenzia__c,indirizzoagenzia__pc,indirizzoformula__c,indirizzosecondario__c,indirizzoutente__pc,insegna__c,internoresidenza__c,iscustomerportal,isdeleted,ispartner,ispersonaccount,istitolare__c,jigsawcompanyid,lastactivitydate,lastmodifiedbyid,lastmodifieddate,lastname,lastnameragionesociale__c,lastreferenceddate,lastvieweddate,lavoro__pc,localita__c,localitasecondaria__c,localitautente__pc,luogodinascita__pc,mailupsender__c,mailupsenderdisplayname__c,marchio__c,masterrecordid,mktdataerogazioneultimaassicurazione__pc,mktdataerogazioneultimaconsulenza__pc,mktdataerogazioneultimacq__pc,mktdataerogazioneultimomutuo__pc,mktdatafirmacontrattoultimaassicurazione__pc,mktdatafirmacontrattoultimaconsulenza__pc,mktdatafirmacontrattoultimacq__pc,mktdatafirmacontrattoultimomutuo__pc,mktimportoultimaassicurazione__pc,mktimportoultimaconsulenza__pc,mktimportoultimacq__pc,mktimportoultimomutuo__pc,mktistitutoprecedenteultimapratica__pc,mktistitutoultimaassicurazione__pc,mktistitutoultimaconsulenza__pc,mktistitutoultimacq__pc,mktistitutoultimomutuo__pc,mktlabelprofessione__pc,mktlocalitaubicazioneimmultimapratica__pc,mktprodottoprincipaleultimaassicurazione__pc,mktsettoreultimapratica__pc,mktuserultimapratica__pc,mktuserultimapraticaindirizzo__pc,modulogestione__c,modulomarketing__c,motivocancellazioneprivacy__c,motivocancellazioneprivacyimm__c,motivodisattivazioneutente__pc,nazione__c,nazionedinascita__pc,nazionerete__c,nazionesecondaria__c,nazioneutente__pc,nomiutentifin__c,noniscrittoalrea__pc,notacreditoprestamovigentes__pc,noteeappunti__pc,numberofemployees,numerocivico__c,numerocivicosecondario__c,numerocivicoutente__pc,numerofamiliaridelnucleo__pc,numerofigliacarico__pc,numeroimmobili__c,numeroiscrizionealrea__pc,numeroiscrruoloutente__pc,numerolicenze__c,numerolicenzeattive__c,numeromaximmobili__c,numeromensilita__pc,nuovaagenzia__c,oldagimmconsharing__c,oldowner__c,originebdt__pc,ownerid,ownership,pacchettopubblicitario__c,partitaiva__c,passwordscarto__c,personassistantname,personassistantphone,personbirthdate,personcontactid,persondepartment,personemail,personemailbounceddate,personemailbouncedreason,personhomephone,personlastcurequestdate,personlastcuupdatedate,personleadsource,personmailingaddress,personmailingcity,personmailingcountry,personmailinglatitude,personmailinglongitude,personmailingpostalcode,personmailingstate,personmailingstreet,personmobilephone,personotheraddress,personothercity,personothercountry,personotherlatitude,personotherlongitude,personotherphone,personotherpostalcode,personotherstate,personotherstreet,persontitle,phone,photourl,polizzafurtoeincendio__pc,polizzainfortuni__pc,polizzalongtermcare__pc,polizzamalattia__pc,polizzaprotezionereddito__pc,polizzaresponsabilitacivile__pc,polizzatemporaneacasomorte__pc,potenzialedacostruire__pc,potenzialeimmediato__pc,premiopolizzafurtoeincendio__pc,premiopolizzainfortuni__pc,premiopolizzalongtermcare__pc,premiopolizzamalattia__pc,premiopolizzaprotezionereddito__pc,premiopolizzaresponsabilitacivile__pc,premiopolizzatemporaneacasomorte__pc,prezzoaffitto__c,privacy__c,privacy__pc,privacyfinindexedstatus__c,privacyimm__c,privacyimmindexedstatus__c,privacykironvista__pc,privacyvalorizzata__c,privacyvalorizzataimm__c,professione__pc,professionees__pc,professionekironvista__pc,provenienzaabitativa__pc,provincia__c,provinciadinascita__pc,provinciasecondaria__c,provinciautente__pc,rating,recordtypeid,redditoannuonetto__pc,redditofamigliare__pc,redditomensilenetto__pc,regione__c,registroimprese__pc,rete__c,richiesteincorsopressoterzi__pc,rivistedigitali__c,saldopendienteprestamos__pc,salutation,scalaresidenza__c,secondocognome__pc,secondonome__pc,sesso__pc,settoreattivita__pc,settoreattivitaes__pc,settoreazienda__c,shippingaddress,shippingcity,shippingcountry,shippinglatitude,shippinglongitude,shippingpostalcode,shippingstate,shippingstreet,sicdesc,sportpraticati__pc,statoattivo__c,statocivile__pc,statocontrattuale__c,studi__pc,superatolimiteimmobili__c,superatolimitelicenze__c,systemmodstamp,telefononormalizzato__c,telefononormalizzato__pc,telefonopreferito__c,telefonopreferitoformula__c,telefonoufficio__c,tipocontratto__pc,tipocontrattoes__pc,tipodocumento__pc,tipologiacliente__c,tipoultimocontattoimmobiliare__c,titolare__c,titolodistudio__pc,titolodistudioes__pc,totalcuotaprestamo__pc,type,utenteccara__pc,utenteinserprivacy__c,utenticonsharing__c,utentivisualizzatomodifiche__c,website,zona__c FROM Account WHERE AND Id = \'0011100000bzZLe\'', query);
        query = Utils.getSelectAllQuery('Account', ' AND Id = \'0011100000bzZLe\'', null, 'ActivatedBy.Name', false, true, new Set<String>{'accountnumber','agenziadiaggiornamento__c'});
        System.assertEquals('SELECT abitazioneprincipale__pc,abitazionitenuteadisposizione__pc,accountsource,activatedby.name,agenziafinanziariaassociata__c,agenziainserprivacy__c,agenziaultimocontattoimmobiliare__c,agfinconsharing__c,agimmconsharing__c,allegatoprivacyid__c,allegatoprivacyid__pc,allegatoprivacyidimm__c,allegatoprivacyinvalidato__c,allegatoprivacyinvalidato__pc,allegatoprivacyinvalidatoimm__c,allegatoprivacypresente__c,allegatoprivacypresenteimm__c,altrotelefono__c,altrotelefononormalizzato__c,altrotelefononormalizzato__pc,ambito__c,annidilavoroimpiegoattuale__pc,anniinitalia__pc,annualrevenue,areamanager__c,attivo__c,attivo__pc,billingaddress,billingcity,billingcountry,billinglatitude,billinglongitude,billingpostalcode,billingstate,billingstreet,cancellatoperprivacyfinanziaria__c,cancellatoperprivacyimmobiliare__c,cancellatoperscartoimmobile__c,cancellazionedabdt__c,cancellazionedamatrix__c,cancellazionedaportale__c,cancellazionigiornaliererimanenti__c,cap__c,capsecondario__c,causaprotestieosofferenze__pc,ccara__c,ccara__pc,cellulare__c,cellularenormalizzato__c,cellularenormalizzato__pc,cittadinanza__pc,clientecondiviso__c,clientetelefonico__c,clientetelefoniconascosto__c,codiceagenziaassociata__c,codicebdt__c,codicecatastale__c,codicecatastalecittadinanza__pc,codicecatastalenascita__pc,codicecatastalesecondario__c,codicecatastaleutente__pc,codiceente__c,codiceente__pc,codiceenteowner__c,codiceenteportale__c,codicefigura__pc,codicefinanziario__c,codicefiscale__c,codicefiscale__pc,codicegruppo__pc,codicegruppoowner__c,codicematrix__c,codiceportale__c,codicereferente__pc,codicerete__c,codicerete__pc,codiceutente__pc,codiceutenteowner__c,compagniapolizzafurtoeincendio__pc,compagniapolizzainfortuni__pc,compagniapolizzalongtermcare__pc,compagniapolizzamalattia__pc,compagniapolizzaprotezionereddito__pc,compagniapolizzaresponsabilitacivile__pc,compagniapolizzatemporaneacasomorte__pc,consensoindexedfield__c,consensoindexedfield__pc,consensoindexedfieldimm__c,consensoinviodatiretetctr__c,consensoinviodatiretetctr__pc,consensomarketing__c,consensomarketing__pc,consensoprivacy1imm__c,consensoprivacy2imm__c,consensoprivacy3imm__c,consensoprivacy4imm__c,consensoprofilazione__c,consensoprofilazione__pc,consulenterete__c,contrattoagenzia__c,coordinate__c,coordinate__latitude__s,coordinate__longitude__s,countdownprivacyattivo__c,countdownprivacyrichiesta__c,createdbyid,createddate,currencyisocode,customeridkironvista__c,daflussoazienda__c,damigrazione__c,dataassunzione__pc,datacancellazioneprivacy__c,datacancellazioneprivacyimm__c,datacreazioneprimarichiesta__c,datadisattivazioneutente__pc,dataelabtalendi01b__c,dataelabtalendi01b__pc,datafidiinessere__pc,dataimportazionedaimmobiliare__c,datainizioattivitautente__pc,datainizioprimoappuntamento__pc,datainserimentostima__c,dataiscrizionealrea__pc,dataprimoappuntamento__pc,dataprivacy__c,dataprossimoappuntamento__pc,datascadenzaaffitto__c,dataultimaattivita__c,dataultimoappuntamento__pc,dataultimocontattoimmobiliare__c,dataupdatecancellazionirimanenti__c,datoredilavoro__pc,description,dicuiportatoridireddito__pc,disattivazioneperprivacy__c,email__c,emailformula__c,emailsecondaria__c,esecutorecancellazioneprivacy__c,esecutorecancellazioneprivacyimm__c,eta__pc,etafigliacarico__pc,eventualifidiinessere__pc,eventualiprotestieosofferenze__pc,extracomunitario__c,famiglia__pc,fax,firmatario__c,firstname,giornidaultimocontattoimmobiliare__c,giornixdisattivazioneimm__c,hasnotizia__c,hasrichiesta__c,hobbyesport__pc,id,idcontratto__c,idnominativo__pc,idtitolarefin__c,idutentifin__c,importofidiinessere__pc,indirizzo__c,indirizzoagenzia__c,indirizzoagenzia__pc,indirizzoformula__c,indirizzosecondario__c,indirizzoutente__pc,insegna__c,internoresidenza__c,iscustomerportal,isdeleted,ispartner,ispersonaccount,istitolare__c,jigsawcompanyid,lastactivitydate,lastmodifiedbyid,lastmodifieddate,lastname,lastnameragionesociale__c,lastreferenceddate,lastvieweddate,lavoro__pc,localita__c,localitasecondaria__c,localitautente__pc,luogodinascita__pc,mailupsender__c,mailupsenderdisplayname__c,marchio__c,masterrecordid,mktdataerogazioneultimaassicurazione__pc,mktdataerogazioneultimaconsulenza__pc,mktdataerogazioneultimacq__pc,mktdataerogazioneultimomutuo__pc,mktdatafirmacontrattoultimaassicurazione__pc,mktdatafirmacontrattoultimaconsulenza__pc,mktdatafirmacontrattoultimacq__pc,mktdatafirmacontrattoultimomutuo__pc,mktimportoultimaassicurazione__pc,mktimportoultimaconsulenza__pc,mktimportoultimacq__pc,mktimportoultimomutuo__pc,mktistitutoprecedenteultimapratica__pc,mktistitutoultimaassicurazione__pc,mktistitutoultimaconsulenza__pc,mktistitutoultimacq__pc,mktistitutoultimomutuo__pc,mktlabelprofessione__pc,mktlocalitaubicazioneimmultimapratica__pc,mktprodottoprincipaleultimaassicurazione__pc,mktsettoreultimapratica__pc,mktuserultimapratica__pc,mktuserultimapraticaindirizzo__pc,modulogestione__c,modulomarketing__c,motivocancellazioneprivacy__c,motivocancellazioneprivacyimm__c,motivodisattivazioneutente__pc,nazione__c,nazionedinascita__pc,nazionerete__c,nazionesecondaria__c,nazioneutente__pc,nomiutentifin__c,noniscrittoalrea__pc,notacreditoprestamovigentes__pc,noteeappunti__pc,numberofemployees,numerocivico__c,numerocivicosecondario__c,numerocivicoutente__pc,numerofamiliaridelnucleo__pc,numerofigliacarico__pc,numeroimmobili__c,numeroiscrizionealrea__pc,numeroiscrruoloutente__pc,numerolicenze__c,numerolicenzeattive__c,numeromaximmobili__c,numeromensilita__pc,nuovaagenzia__c,oldagimmconsharing__c,oldowner__c,originebdt__pc,ownerid,ownership,pacchettopubblicitario__c,partitaiva__c,passwordscarto__c,personassistantname,personassistantphone,personbirthdate,personcontactid,persondepartment,personemail,personemailbounceddate,personemailbouncedreason,personhomephone,personlastcurequestdate,personlastcuupdatedate,personleadsource,personmailingaddress,personmailingcity,personmailingcountry,personmailinglatitude,personmailinglongitude,personmailingpostalcode,personmailingstate,personmailingstreet,personmobilephone,personotheraddress,personothercity,personothercountry,personotherlatitude,personotherlongitude,personotherphone,personotherpostalcode,personotherstate,personotherstreet,persontitle,phone,photourl,polizzafurtoeincendio__pc,polizzainfortuni__pc,polizzalongtermcare__pc,polizzamalattia__pc,polizzaprotezionereddito__pc,polizzaresponsabilitacivile__pc,polizzatemporaneacasomorte__pc,potenzialedacostruire__pc,potenzialeimmediato__pc,premiopolizzafurtoeincendio__pc,premiopolizzainfortuni__pc,premiopolizzalongtermcare__pc,premiopolizzamalattia__pc,premiopolizzaprotezionereddito__pc,premiopolizzaresponsabilitacivile__pc,premiopolizzatemporaneacasomorte__pc,prezzoaffitto__c,privacy__c,privacy__pc,privacyfinindexedstatus__c,privacyimm__c,privacyimmindexedstatus__c,privacykironvista__pc,privacyvalorizzata__c,privacyvalorizzataimm__c,professione__pc,professionees__pc,professionekironvista__pc,provenienzaabitativa__pc,provincia__c,provinciadinascita__pc,provinciasecondaria__c,provinciautente__pc,rating,recordtypeid,redditoannuonetto__pc,redditofamigliare__pc,redditomensilenetto__pc,regione__c,registroimprese__pc,rete__c,richiesteincorsopressoterzi__pc,rivistedigitali__c,saldopendienteprestamos__pc,salutation,scalaresidenza__c,secondocognome__pc,secondonome__pc,sesso__pc,settoreattivita__pc,settoreattivitaes__pc,settoreazienda__c,shippingaddress,shippingcity,shippingcountry,shippinglatitude,shippinglongitude,shippingpostalcode,shippingstate,shippingstreet,sicdesc,sportpraticati__pc,statoattivo__c,statocivile__pc,statocontrattuale__c,studi__pc,superatolimiteimmobili__c,superatolimitelicenze__c,systemmodstamp,telefononormalizzato__c,telefononormalizzato__pc,telefonopreferito__c,telefonopreferitoformula__c,telefonoufficio__c,tipocontratto__pc,tipocontrattoes__pc,tipodocumento__pc,tipologiacliente__c,tipoultimocontattoimmobiliare__c,titolare__c,titolodistudio__pc,titolodistudioes__pc,totalcuotaprestamo__pc,type,utenteccara__pc,utenteinserprivacy__c,utenticonsharing__c,utentivisualizzatomodifiche__c,website,zona__c FROM Account WHERE AND Id = \'0011100000bzZLe\'', query);
        query = Utils.getSelectAllQueryForPA(' AND Id = \'0011100000bzZLe\'', null, true, true);
        System.assertEquals('SELECT abitazioneprincipale__pc,abitazionitenuteadisposizione__pc,accountnumber,accountsource,agenziadiaggiornamento__c,agenziafinanziariaassociata__c,agenziainserprivacy__c,agenziaultimocontattoimmobiliare__c,agfinconsharing__c,agimmconsharing__c,allegatoprivacyid__c,allegatoprivacyid__pc,allegatoprivacyidimm__c,allegatoprivacyinvalidato__c,allegatoprivacyinvalidato__pc,allegatoprivacyinvalidatoimm__c,altrotelefono__c,anniinitalia__pc,annualrevenue,areamanager__c,attivo__c,attivo__pc,billingcity,billingcountry,billinglatitude,billinglongitude,billingpostalcode,billingstate,billingstreet,cancellatoperprivacyfinanziaria__c,cancellatoperprivacyimmobiliare__c,cancellatoperscartoimmobile__c,cancellazionedabdt__c,cancellazionedamatrix__c,cancellazionedaportale__c,cancellazionigiornaliererimanenti__c,cap__c,capsecondario__c,causaprotestieosofferenze__pc,ccara__c,cellulare__c,cittadinanza__pc,clientecondiviso__c,clientetelefoniconascosto__c,codiceagenziaassociata__c,codicebdt__c,codicecatastale__c,codicecatastalecittadinanza__pc,codicecatastalenascita__pc,codicecatastalesecondario__c,codicecatastaleutente__pc,codiceente__c,codiceenteportale__c,codicefigura__pc,codicefinanziario__c,codicefiscale__c,codicefiscale__pc,codicegruppo__pc,codicematrix__c,codiceportale__c,codicereferente__pc,codicerete__c,codicerete__pc,codiceutente__pc,compagniapolizzafurtoeincendio__pc,compagniapolizzainfortuni__pc,compagniapolizzalongtermcare__pc,compagniapolizzamalattia__pc,compagniapolizzaprotezionereddito__pc,compagniapolizzaresponsabilitacivile__pc,compagniapolizzatemporaneacasomorte__pc,consensoindexedfield__c,consensoindexedfield__pc,consensoindexedfieldimm__c,consensoinviodatiretetctr__c,consensoinviodatiretetctr__pc,consensomarketing__c,consensomarketing__pc,consensoprivacy1imm__c,consensoprivacy2imm__c,consensoprivacy3imm__c,consensoprivacy4imm__c,consensoprofilazione__c,consensoprofilazione__pc,consulenterete__c,contrattoagenzia__c,coordinate__latitude__s,coordinate__longitude__s,currencyisocode,customeridkironvista__c,daflussoazienda__c,damigrazione__c,dataassunzione__pc,datacancellazioneprivacy__c,datacancellazioneprivacyimm__c,datacreazioneprimarichiesta__c,datadisattivazioneutente__pc,dataelabtalendi01b__c,dataelabtalendi01b__pc,datafidiinessere__pc,dataimportazionedaimmobiliare__c,datainizioattivitautente__pc,datainizioprimoappuntamento__pc,datainserimentostima__c,dataiscrizionealrea__pc,dataprimoappuntamento__pc,dataprivacy__c,dataprossimoappuntamento__pc,datascadenzaaffitto__c,dataultimaattivita__c,dataultimoappuntamento__pc,dataultimocontattoimmobiliare__c,dataupdatecancellazionirimanenti__c,datoredilavoro__pc,description,dicuiportatoridireddito__pc,email__c,emailsecondaria__c,esecutorecancellazioneprivacy__c,esecutorecancellazioneprivacyimm__c,etafigliacarico__pc,eventualifidiinessere__pc,eventualiprotestieosofferenze__pc,extracomunitario__c,famiglia__pc,fax,firmatario__c,firstname,hasnotizia__c,hasrichiesta__c,hobbyesport__pc,idcontratto__c,idutentifin__c,importofidiinessere__pc,indirizzo__c,indirizzosecondario__c,indirizzoutente__pc,insegna__c,internoresidenza__c,iscustomerportal,ispartner,lastname,lavoro__pc,localita__c,localitasecondaria__c,localitautente__pc,luogodinascita__pc,mailupsender__c,mailupsenderdisplayname__c,marchio__c,mktdataerogazioneultimaassicurazione__pc,mktdataerogazioneultimaconsulenza__pc,mktdataerogazioneultimacq__pc,mktdataerogazioneultimomutuo__pc,mktdatafirmacontrattoultimaassicurazione__pc,mktdatafirmacontrattoultimaconsulenza__pc,mktdatafirmacontrattoultimacq__pc,mktdatafirmacontrattoultimomutuo__pc,mktimportoultimaassicurazione__pc,mktimportoultimaconsulenza__pc,mktimportoultimacq__pc,mktimportoultimomutuo__pc,mktistitutoprecedenteultimapratica__pc,mktistitutoultimaassicurazione__pc,mktistitutoultimaconsulenza__pc,mktistitutoultimacq__pc,mktistitutoultimomutuo__pc,mktlabelprofessione__pc,mktlocalitaubicazioneimmultimapratica__pc,mktprodottoprincipaleultimaassicurazione__pc,mktsettoreultimapratica__pc,mktuserultimapratica__pc,mktuserultimapraticaindirizzo__pc,modulogestione__c,modulomarketing__c,motivocancellazioneprivacy__c,motivocancellazioneprivacyimm__c,motivodisattivazioneutente__pc,nazione__c,nazionedinascita__pc,nazionerete__c,nazionesecondaria__c,nazioneutente__pc,nomiutentifin__c,noniscrittoalrea__pc,notacreditoprestamovigentes__pc,noteeappunti__pc,numberofemployees,numerocivico__c,numerocivicosecondario__c,numerocivicoutente__pc,numerofamiliaridelnucleo__pc,numerofigliacarico__pc,numeroimmobili__c,numeroiscrizionealrea__pc,numeroiscrruoloutente__pc,numerolicenze__c,numerolicenzeattive__c,numeromaximmobili__c,numeromensilita__pc,nuovaagenzia__c,oldagimmconsharing__c,oldowner__c,originebdt__pc,ownerid,ownership,pacchettopubblicitario__c,partitaiva__c,passwordscarto__c,personassistantname,personassistantphone,personbirthdate,persondepartment,personemail,personemailbounceddate,personemailbouncedreason,personhomephone,personleadsource,personmailingcity,personmailingcountry,personmailinglatitude,personmailinglongitude,personmailingpostalcode,personmailingstate,personmailingstreet,personmobilephone,personothercity,personothercountry,personotherlatitude,personotherlongitude,personotherphone,personotherpostalcode,personotherstate,personotherstreet,persontitle,phone,polizzafurtoeincendio__pc,polizzainfortuni__pc,polizzalongtermcare__pc,polizzamalattia__pc,polizzaprotezionereddito__pc,polizzaresponsabilitacivile__pc,polizzatemporaneacasomorte__pc,potenzialedacostruire__pc,potenzialeimmediato__pc,premiopolizzafurtoeincendio__pc,premiopolizzainfortuni__pc,premiopolizzalongtermcare__pc,premiopolizzamalattia__pc,premiopolizzaprotezionereddito__pc,premiopolizzaresponsabilitacivile__pc,premiopolizzatemporaneacasomorte__pc,prezzoaffitto__c,privacy__c,privacy__pc,privacyfinindexedstatus__c,privacyimm__c,privacyimmindexedstatus__c,privacykironvista__pc,professione__pc,professionees__pc,professionekironvista__pc,provenienzaabitativa__pc,provincia__c,provinciadinascita__pc,provinciasecondaria__c,provinciautente__pc,rating,recordtypeid,redditofamigliare__pc,redditomensilenetto__pc,regione__c,registroimprese__pc,rete__c,richiesteincorsopressoterzi__pc,rivistedigitali__c,saldopendienteprestamos__pc,salutation,scalaresidenza__c,secondocognome__pc,secondonome__pc,sesso__pc,settoreattivita__pc,settoreattivitaes__pc,settoreazienda__c,shippingcity,shippingcountry,shippinglatitude,shippinglongitude,shippingpostalcode,shippingstate,shippingstreet,sicdesc,sportpraticati__pc,statoattivo__c,statocivile__pc,statocontrattuale__c,studi__pc,telefonopreferito__c,telefonoufficio__c,tipocontratto__pc,tipocontrattoes__pc,tipodocumento__pc,tipologiacliente__c,tipoultimocontattoimmobiliare__c,titolodistudio__pc,titolodistudioes__pc,totalcuotaprestamo__pc,type,utenteccara__pc,utenteinserprivacy__c,utenticonsharing__c,utentivisualizzatomodifiche__c,website,zona__c FROM Account WHERE AND Id = \'0011100000bzZLe\'', query);
        query = Utils.getSelectAllQuery('Account', ' AND Id = \'0011100000bzZLe\'', null, 'ActivatedBy.Name', false, true, new Set<String>{'accountnumber','agenziadiaggiornamento__c'}, true);
        System.assertEquals('SELECT abitazionitenuteadisposizione__pc,activatedby.name,agenziafinanziariaassociata__c,agenziainserprivacy__c,agenziaultimocontattoimmobiliare__c,agfinconsharing__c,agimmconsharing__c,allegatoprivacyid__c,allegatoprivacyid__pc,allegatoprivacyidimm__c,allegatoprivacyinvalidato__c,allegatoprivacyinvalidato__pc,allegatoprivacyinvalidatoimm__c,allegatoprivacypresente__c,allegatoprivacypresenteimm__c,altrotelefono__c,altrotelefononormalizzato__c,altrotelefononormalizzato__pc,ambito__c,annidilavoroimpiegoattuale__pc,anniinitalia__pc,annualrevenue,areamanager__c,attivo__c,attivo__pc,billingaddress,billingcity,billingcountry,billinglatitude,billinglongitude,billingpostalcode,billingstate,billingstreet,cancellatoperprivacyfinanziaria__c,cancellatoperprivacyimmobiliare__c,cancellatoperscartoimmobile__c,cancellazionedabdt__c,cancellazionedamatrix__c,cancellazionedaportale__c,cancellazionigiornaliererimanenti__c,cap__c,capsecondario__c,causaprotestieosofferenze__pc,ccara__c,ccara__pc,cellulare__c,cellularenormalizzato__c,cellularenormalizzato__pc,clientecondiviso__c,clientetelefonico__c,clientetelefoniconascosto__c,codiceagenziaassociata__c,codicebdt__c,codicecatastale__c,codicecatastalecittadinanza__pc,codicecatastalenascita__pc,codicecatastalesecondario__c,codicecatastaleutente__pc,codiceente__c,codiceente__pc,codiceenteowner__c,codiceenteportale__c,codicefigura__pc,codicefinanziario__c,codicefiscale__c,codicefiscale__pc,codicegruppo__pc,codicegruppoowner__c,codicematrix__c,codiceportale__c,codicereferente__pc,codicerete__c,codicerete__pc,codiceutente__pc,codiceutenteowner__c,compagniapolizzafurtoeincendio__pc,compagniapolizzainfortuni__pc,compagniapolizzalongtermcare__pc,compagniapolizzamalattia__pc,compagniapolizzaprotezionereddito__pc,compagniapolizzaresponsabilitacivile__pc,compagniapolizzatemporaneacasomorte__pc,consensoindexedfield__c,consensoindexedfield__pc,consensoindexedfieldimm__c,consulenterete__c,coordinate__c,coordinate__latitude__s,coordinate__longitude__s,countdownprivacyattivo__c,countdownprivacyrichiesta__c,createdbyid,createddate,customeridkironvista__c,daflussoazienda__c,damigrazione__c,dataassunzione__pc,datacancellazioneprivacy__c,datacancellazioneprivacyimm__c,datacreazioneprimarichiesta__c,datadisattivazioneutente__pc,dataelabtalendi01b__c,dataelabtalendi01b__pc,datafidiinessere__pc,dataimportazionedaimmobiliare__c,datainizioattivitautente__pc,datainizioprimoappuntamento__pc,datainserimentostima__c,dataiscrizionealrea__pc,dataprimoappuntamento__pc,dataprivacy__c,dataprossimoappuntamento__pc,datascadenzaaffitto__c,dataultimaattivita__c,dataultimoappuntamento__pc,dataultimocontattoimmobiliare__c,dataupdatecancellazionirimanenti__c,datoredilavoro__pc,description,dicuiportatoridireddito__pc,disattivazioneperprivacy__c,email__c,emailformula__c,emailsecondaria__c,esecutorecancellazioneprivacy__c,esecutorecancellazioneprivacyimm__c,eta__pc,etafigliacarico__pc,extracomunitario__c,fax,firmatario__c,firstname,giornidaultimocontattoimmobiliare__c,giornixdisattivazioneimm__c,hasnotizia__c,hasrichiesta__c,hobbyesport__pc,id,idcontratto__c,idnominativo__pc,idtitolarefin__c,idutentifin__c,importofidiinessere__pc,indirizzo__c,indirizzoagenzia__c,indirizzoagenzia__pc,indirizzoformula__c,indirizzosecondario__c,indirizzoutente__pc,insegna__c,internoresidenza__c,iscustomerportal,isdeleted,ispartner,ispersonaccount,istitolare__c,jigsawcompanyid,lastactivitydate,lastmodifiedbyid,lastmodifieddate,lastname,lastnameragionesociale__c,lastreferenceddate,lastvieweddate,localita__c,localitasecondaria__c,localitautente__pc,luogodinascita__pc,mailupsender__c,mailupsenderdisplayname__c,marchio__c,masterrecordid,mktdataerogazioneultimaassicurazione__pc,mktdataerogazioneultimaconsulenza__pc,mktdataerogazioneultimacq__pc,mktdataerogazioneultimomutuo__pc,mktdatafirmacontrattoultimaassicurazione__pc,mktdatafirmacontrattoultimaconsulenza__pc,mktdatafirmacontrattoultimacq__pc,mktdatafirmacontrattoultimomutuo__pc,mktimportoultimaassicurazione__pc,mktimportoultimaconsulenza__pc,mktimportoultimacq__pc,mktimportoultimomutuo__pc,mktistitutoprecedenteultimapratica__pc,mktistitutoultimaassicurazione__pc,mktistitutoultimaconsulenza__pc,mktistitutoultimacq__pc,mktistitutoultimomutuo__pc,mktlabelprofessione__pc,mktlocalitaubicazioneimmultimapratica__pc,mktprodottoprincipaleultimaassicurazione__pc,mktsettoreultimapratica__pc,mktuserultimapratica__pc,mktuserultimapraticaindirizzo__pc,modulogestione__c,modulomarketing__c,nazione__c,nazionedinascita__pc,nazionerete__c,nazionesecondaria__c,nazioneutente__pc,nomiutentifin__c,noniscrittoalrea__pc,notacreditoprestamovigentes__pc,noteeappunti__pc,numberofemployees,numerocivico__c,numerocivicosecondario__c,numerocivicoutente__pc,numerofamiliaridelnucleo__pc,numerofigliacarico__pc,numeroimmobili__c,numeroiscrizionealrea__pc,numeroiscrruoloutente__pc,numerolicenze__c,numerolicenzeattive__c,numeromaximmobili__c,nuovaagenzia__c,oldagimmconsharing__c,oldowner__c,originebdt__pc,ownerid,pacchettopubblicitario__c,partitaiva__c,passwordscarto__c,personassistantname,personassistantphone,personbirthdate,personcontactid,persondepartment,personemail,personemailbounceddate,personemailbouncedreason,personhomephone,personlastcurequestdate,personlastcuupdatedate,personmailingaddress,personmailingcity,personmailingcountry,personmailinglatitude,personmailinglongitude,personmailingpostalcode,personmailingstate,personmailingstreet,personmobilephone,personotheraddress,personothercity,personothercountry,personotherlatitude,personotherlongitude,personotherphone,personotherpostalcode,personotherstate,personotherstreet,persontitle,phone,photourl,potenzialedacostruire__pc,potenzialeimmediato__pc,premiopolizzafurtoeincendio__pc,premiopolizzainfortuni__pc,premiopolizzalongtermcare__pc,premiopolizzamalattia__pc,premiopolizzaprotezionereddito__pc,premiopolizzaresponsabilitacivile__pc,premiopolizzatemporaneacasomorte__pc,prezzoaffitto__c,privacy__c,privacy__pc,privacyfinindexedstatus__c,privacyimmindexedstatus__c,privacykironvista__pc,privacyvalorizzata__c,privacyvalorizzataimm__c,professionekironvista__pc,provincia__c,provinciadinascita__pc,provinciasecondaria__c,provinciautente__pc,recordtypeid,redditoannuonetto__pc,redditofamigliare__pc,redditomensilenetto__pc,regione__c,registroimprese__pc,rivistedigitali__c,saldopendienteprestamos__pc,scalaresidenza__c,secondocognome__pc,secondonome__pc,shippingaddress,shippingcity,shippingcountry,shippinglatitude,shippinglongitude,shippingpostalcode,shippingstate,shippingstreet,sicdesc,sportpraticati__pc,statoattivo__c,statocontrattuale__c,superatolimiteimmobili__c,superatolimitelicenze__c,systemmodstamp,telefononormalizzato__c,telefononormalizzato__pc,telefonopreferitoformula__c,telefonoufficio__c,titolare__c,toLabel(abitazioneprincipale__pc),toLabel(accountsource),toLabel(cittadinanza__pc),toLabel(consensoinviodatiretetctr__c),toLabel(consensoinviodatiretetctr__pc),toLabel(consensomarketing__c),toLabel(consensomarketing__pc),toLabel(consensoprivacy1imm__c),toLabel(consensoprivacy2imm__c),toLabel(consensoprivacy3imm__c),toLabel(consensoprivacy4imm__c),toLabel(consensoprofilazione__c),toLabel(consensoprofilazione__pc),toLabel(contrattoagenzia__c),toLabel(currencyisocode),toLabel(eventualifidiinessere__pc),toLabel(eventualiprotestieosofferenze__pc),toLabel(famiglia__pc),toLabel(lavoro__pc),toLabel(motivocancellazioneprivacy__c),toLabel(motivocancellazioneprivacyimm__c),toLabel(motivodisattivazioneutente__pc),toLabel(numeromensilita__pc),toLabel(ownership),toLabel(personleadsource),toLabel(polizzafurtoeincendio__pc),toLabel(polizzainfortuni__pc),toLabel(polizzalongtermcare__pc),toLabel(polizzamalattia__pc),toLabel(polizzaprotezionereddito__pc),toLabel(polizzaresponsabilitacivile__pc),toLabel(polizzatemporaneacasomorte__pc),toLabel(privacyimm__c),toLabel(professione__pc),toLabel(professionees__pc),toLabel(provenienzaabitativa__pc),toLabel(rating),toLabel(rete__c),toLabel(richiesteincorsopressoterzi__pc),toLabel(salutation),toLabel(sesso__pc),toLabel(settoreattivita__pc),toLabel(settoreattivitaes__pc),toLabel(settoreazienda__c),toLabel(statocivile__pc),toLabel(studi__pc),toLabel(telefonopreferito__c),toLabel(tipocontratto__pc),toLabel(tipocontrattoes__pc),toLabel(tipodocumento__pc),toLabel(tipologiacliente__c),toLabel(tipoultimocontattoimmobiliare__c),toLabel(titolodistudio__pc),toLabel(titolodistudioes__pc),toLabel(type),totalcuotaprestamo__pc,utenteccara__pc,utenteinserprivacy__c,utenticonsharing__c,utentivisualizzatomodifiche__c,website,zona__c FROM Account WHERE AND Id = \'0011100000bzZLe\'', query);
        */
    }

    @isTest
    static void testGetRecordTypes() {
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String, SObject> rtMap2 = Utils.getRecordTypes('Account');

        for(SObject rt : rtMap2.values()) {
            System.assertEquals(true, rtMap.containsKey((String) rt.get('Name')));
        }
    }

    @isTest
    static void testExtractSetMethods() {
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', AccountId = '001g000000CxTGm', Account = new Account(Name = 'x1'), FirstName = 'fn1', LastName = 'contact1', BirthDate = Date.valueOf('1990-01-01')),
            new Contact(Id = '003g000000CxTGo', AccountId = '001g000000CxTGo', Account = new Account(Name = 'x2'), FirstName = 'fn1', LastName = 'contact3', BirthDate = Date.valueOf('1996-01-01')),
            new Contact(Id = '003g000000CxTGn', AccountId = '001g000000CxTGo', FirstName = 'fn2', LastName = 'contact2', BirthDate = Date.valueOf('1992-01-01')),
            new Contact(Id = '003g000000CxTGn', AccountId = '001g000000CxTGo', Account = new Account(Name = 'x4'), FirstName = null, LastName = 'contact4', BirthDate = Date.valueOf('1992-01-01'))
        };

        Set<Id> accountIds = Utils.extractIdSet(cL, 'AccountId');
        System.assertEquals(2, accountIds.size());
        System.assertEquals(true, accountIds.containsAll(new Id[]{'001g000000CxTGo', '001g000000CxTGm'}));

        Set<String> firstNameSet = Utils.extractSet(cL, 'FirstName');
        System.assertEquals(2, firstNameSet.size());
        System.assertEquals(true, firstNameSet.containsAll(new String[]{'fn1', 'fn2'}));

        Set<String> accNames = Utils.extractSetRecursive(cL, 'Account.Name');
        System.assertEquals(3, accNames.size());
        System.assert(accNames.containsAll(new String[]{'x1','x2','x4'}));
    }

    @isTest
    static void testMassSet() {
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', AccountId = '001g000000CxTGm', FirstName = 'fn1', LastName = 'contact1', BirthDate = Date.valueOf('1990-01-01')),
            new Contact(Id = '003g000000CxTGo', AccountId = '001g000000CxTGo', FirstName = 'fn1', LastName = 'contact3', BirthDate = Date.valueOf('1996-01-01')),
            new Contact(Id = '003g000000CxTGn', AccountId = '001g000000CxTGo', FirstName = 'fn2', LastName = 'contact2', BirthDate = Date.valueOf('1992-01-01')),
            new Contact(Id = '003g000000CxTGn', AccountId = '001g000000CxTGo', FirstName = null, LastName = 'contact4', BirthDate = Date.valueOf('1992-01-01'))
        };

        Utils.massSet(cL, 'FirstName', 'giacomo');

        for(Contact c : cL) {
            System.assertEquals('giacomo', c.FirstName);
        }

        Utils.massSet(cL, new Map<String, Object>{
            'FirstName' => 'Michele',
            'LastName' => 'ttt'
        });

        for(Contact c : cL) {
            System.assertEquals('Michele', c.FirstName);
            System.assertEquals('ttt', c.LastName);
        }
    }

    @isTest
    static void testParseAdditionalFields() {
        String additionalFields = 'Name, (SELECT Id, Name FROM Contacts) , BillingAddress,Website';

        Set<String> fields = Utils.parseAdditionalFields(additionalFields);
        System.assert(fields.contains('name'));
        System.assert(fields.contains('(select id, name from contacts)'));
        System.assert(fields.contains('billingaddress'));
        System.assert(fields.contains('website'));
        System.assertEquals(4, fields.size());
    }

    @isTest
    static void testReplaceInMultiselect(){
        String multiselectValue = 'a1;a2;a3;a4;a5;a6;a7';
        System.assertEquals('a1;a2;a4;a5;a6;a7;a8', Utils.replaceInMultiselect(multiselectValue, 'a3', 'a8'));
    }

    @isTest
    static void testIsInMultiselect(){
        String multiselectValue = 'a1;a2;a3;a4;a5;a6;a7';
        System.assert(Utils.isInMultiselect(multiselectValue, 'a3'));
        System.assert(!Utils.isInMultiselect(multiselectValue, 'a8'));
    }

    @isTest
    static void testExtractMapOfValues(){
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'contact1', BirthDate = Date.valueOf('1990-01-01')),
            new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'contact3', BirthDate = Date.valueOf('1996-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'contact2', BirthDate = Date.valueOf('1992-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn3', LastName = 'contact4', BirthDate = Date.valueOf('1992-01-01'))
        };

        Account[] aL = new Account[]{
            new Account(Id = '001g000000CxTGm', Name = '001'),
            new Account(Id = '001g000000CxTGo', Name = '002'),
            new Account(Id = '001g000000CxTGp', Name = '003'),
            new Account(Id = '001g000000CxTGq', Name = '004')
        };

        for (Integer i = 0; i < cL.size(); i++){
            cl.get(i).Account = al.get(i);
        }

        Map<String, String> extractedMap1 = Utils.extractMapOfValues(cL, '{FirstName}_{LastName}', 'Account.Name');
        System.assertEquals('001', extractedMap1.get('fn1_contact1'));
        System.assertEquals('002', extractedMap1.get('fn1_contact3'));
        System.assertEquals('003', extractedMap1.get('fn2_contact2'));
        System.assertEquals('004', extractedMap1.get('fn3_contact4'));

        Map<String, String> extractedMap2 = Utils.extractMapOfValues(cL, '{LastName}', 'LastName');
        for (String key : extractedMap2.keySet()){
            System.assertEquals(key, extractedMap2.get(key));
        }
    }

    @isTest
    static void testExtractIdSet(){
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'contact1', BirthDate = Date.valueOf('1990-01-01')),
            new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'contact3', BirthDate = Date.valueOf('1996-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'contact2', BirthDate = Date.valueOf('1992-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn3', LastName = 'contact4', BirthDate = Date.valueOf('1992-01-01'))
        };

        Account[] aL = new Account[]{
            new Account(Id = '001g000000CxTGm', Name = '001'),
            new Account(Id = '001g000000CxTGo', Name = '002'),
            new Account(Id = '001g000000CxTGp', Name = '003'),
            new Account(Id = '001g000000CxTGq', Name = '004')
        };

        for (Integer i = 0; i < cL.size(); i++){
            cl.get(i).Account = al.get(i);
        }

        Set<Id> idSet1 = Utils.extractIdSet(cL, 'Id');
        Set<Id> idSet2 = Utils.extractIdSet(cL, 'Account.Id');

        System.assert(idSet1.contains(Id.valueOf('003g000000CxTGm')));
        System.assert(idSet1.contains(Id.valueOf('003g000000CxTGo')));
        System.assert(idSet1.contains(Id.valueOf('003g000000CxTGn')));

        System.assert(idSet2.contains(Id.valueOf('001g000000CxTGm')));
        System.assert(idSet2.contains(Id.valueOf('001g000000CxTGo')));
        System.assert(idSet2.contains(Id.valueOf('001g000000CxTGp')));
        System.assert(idSet2.contains(Id.valueOf('001g000000CxTGq')));
    }

    @isTest
    static void testExtractGroupedMapOfValues(){
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'group1', BirthDate = Date.valueOf('1990-01-01')),
            new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'group1', BirthDate = Date.valueOf('1996-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group1', BirthDate = Date.valueOf('1992-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn3', LastName = 'group2', BirthDate = Date.valueOf('1992-01-01'))
        };

        Account[] aL = new Account[]{
            new Account(Id = '001g000000CxTGm', Name = '001'),
            new Account(Id = '001g000000CxTGo', Name = '002'),
            new Account(Id = '001g000000CxTGp', Name = '003'),
            new Account(Id = '001g000000CxTGq', Name = '004')
        };

        for (Integer i = 0; i < cL.size(); i++){
            cl.get(i).Account = al.get(i);
        }

        Map<String, Set<String>> groupedMap1 = Utils.extractGroupedMapOfValues(cL, '{LastName}', 'Account.Name');

        System.assertEquals(3, groupedMap1.get('group1').size());
        System.assertEquals(1, groupedMap1.get('group2').size());

        Map<String, Set<String>> groupedMap2 = Utils.extractGroupedMapOfValues(cL, '{LastName}', 'FirstName');
        System.assertEquals(2, groupedMap2.get('group1').size());
        System.assertEquals(1, groupedMap2.get('group2').size());


        Map<String, Set<String>> groupedMap3 = Utils.extractGroupedMapOfValues(cL, '{ABC}', 'FirstName');
        System.assertEquals(3, groupedMap3.get('null').size());
    }

    @isTest
    static void testFilterByFilter(){
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'group2', BirthDate = Date.valueOf('1990-01-01')),
            new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'group1', BirthDate = Date.valueOf('1996-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group1', BirthDate = Date.valueOf('1992-01-01')),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group2', BirthDate = Date.valueOf('1992-01-01'))
        };
        Utils.FilterByFilter filter1 = new Utils.FilterByFilter('group1');
        Utils.FilterByFilter filter2 = new Utils.FilterByFilter('fn2', false);

        Map<String, Utils.FilterByFilter> filters = new Map<String, Utils.FilterByFilter>{
            'FirstName' => filter2,
            'LastName' => filter1
        };

        System.assertEquals(1, Utils.filterBy(cL, filters).size());
    }

    @isTest
    static void testDynamicMassSet(){
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'group2', Title = null),
            new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'group1', Title = null),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group1', Title = null),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group2', Title = null)
        };

        Utils.dynamicMassSet(cL, 'LastName', '{Id}_{FirstName}');

        for (Contact c : cL){
            System.assertEquals(c.Id + '_' + c.FirstName, c.LastName);
        }

        Utils.dynamicMassSet(cL, 'LastName', '{Title}_{FirstName}');

        System.assertEquals('null_fn1', cL[0].LastName);
    }

    @isTest
    static void testHas(){
        Contact[] cL = new Contact[]{
            new Contact(Id = '003g000000CxTGm', FirstName = 'fn1', LastName = 'group2', Title = null),
            new Contact(Id = '003g000000CxTGo', FirstName = 'fn1', LastName = 'group1', Title = null),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group1', Title = null),
            new Contact(Id = '003g000000CxTGn', FirstName = 'fn2', LastName = 'group2', Title = null)
        };
        System.assert(Utils.has(cL, 'FirstName', 'fn1'));
        System.assert(!Utils.has(cL, 'FirstName', 'fn3'));
    }

    @isTest
    static void testValueIn(){
        System.assert(Utils.valueIn((Object)('c'), (new Set<Object>{'a','b','c','e'})));
        System.assert(!Utils.valueIn((Object)('d'),  (new Set<Object>{'a','b','c','e'})));
    }

    @isTest
    static void testToSet(){
        String[] sL = new String[]{'a', 'a', 'b', 'c', 'd'};
        Set<String> sS = Utils.toSet(sL);

        for (String s : sL){
            System.assert(sS.contains(s));
        }
        System.assertEquals(4, sS.size());
    }

    @isTest
    static void testToList(){
        Set<String> sS = new Set<String>{'a', 'b', 'c', 'd'};

        List<String> sL = Utils.toList(sS);
        System.assertEquals(4, sL.size());
    }

    @isTest
    static void testLeftPad(){
        System.assertEquals('**abc', Utils.leftPad((Object)('abc'), 5, '*'));
        System.assertEquals('abc', Utils.leftPad((Object)('abc'), 1, '*'));
    }

    @isTest
    static void testGetSObjectValue(){
        Account a = new Account(Id = '001g000000CxTGm', Name = '001');
        Contact c = new Contact(Id = '003g000000CxTGm', Account = a, FirstName = 'fn1', LastName = 'group1', BirthDate = Date.valueOf('1990-01-01'));

        System.assertEquals('001', (String)Utils.getSObjectValue(c, 'Account.Name'));
        System.assertEquals('fn1', (String)Utils.getSObjectValue(c, 'FirstName'));

    }

    @isTest
    static void testNewGuid(){
        for (Integer i = 0; i < 50; i++){
            System.assert(Pattern.matches('[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}', Utils.newGuid()));
        }
    }

    @isTest
    static void testGetCharAtIndex(){
        System.assertEquals(null, Utils.getCharAtIndex('1234567890', 11));
        System.assertEquals('5', Utils.getCharAtIndex('1234567890', 4));
    }

    @isTest
    static void testPrepend(){
        System.assertEquals('def', Utils.prepend(new String[]{'abc'}, 'def').get(0));
    }

    @isTest
    static void testRemoveDuplicates(){
        String[] sL = new String[]{'a', 'a', 'b', 'c', 'C'};
        //Set is case sensitive?
        System.assertEquals(4, Utils.removeDuplicates(sL).size());
    }


}