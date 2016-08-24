public class Utils {

    /**
     *  Ritorna una stringa SOQL contenente tutti i campi "base" di un account, più eventuali additionalFields. Serve a creare la query corretta per gli account nel caso si usino i person account
     *  @whereClause Il filtro della query (es Id = 'xxx')
     *  @additionalFields Eventuali campi aggiuntivi non automaticamente aggiunti dal metodo, ad esempio campi relazionati o campi non creatable tipo formule se è stato specificato il flag onlyCreatable = true
     *  @onlyCreatable Specifica se prendere solo i campi "creabili" oppure tutti i campi, compresi campi readonly, campi non modificabili, campi formula. Utile specificarlo se si fanno query su record che verranno poi modificati. In questo caso avere nella query campi readonly potrebbe non consentire l'update
     *  @isPersonAccount se true, vengono aggiunti alla query i campi propri dei person account (campi custom __pc, LastName, FirstName, Salutation) e vengono esclusi quelli propri dell'account (Name). Se false, viene fatto il viceversa
     */
    public static string getSelectAllQueryForPA(String whereClause, String additionalFields, boolean onlyCreateable, Boolean isPersonAccount){
        return getSelectAllQuery('Account', whereClause, null, additionalFields, onlyCreateable, isPersonAccount, null, false);
    }

    /**
     *  Ritorna una stringa SOQL contenente tutti i campi "base" di un oggetto, più eventuali additionalFields
     *  @objectName Il nome dell'oggetto
     *  @whereClause Il filtro della query (es Id = 'xxx')
     *  @relationshipName Permette di creare una subquery da inserire in una query normale. In questo caso specificare il nome della relazione a cui si fa riferimento (ad esempio se si vuole creare una subquery sui contatti di un account specificare qui "contacts")
     *  @additionalFields Eventuali campi aggiuntivi non automaticamente aggiunti dal metodo, ad esempio campi relazionati o campi non creatable tipo formule se è stato specificato il flag onlyCreatable = true
     *  @onlyCreatable Specifica se prendere solo i campi "creabili" oppure tutti i campi, compresi campi readonly, campi non modificabili, campi formula. Utile specificarlo se si fanno query su record che verranno poi modificati. In questo caso avere nella query campi readonly potrebbe non consentire l'update
     */
    public static string getSelectAllQuery(String objectName, String whereClause, String relationshipName, String additionalFields, boolean onlyCreateable){
        return getSelectAllQuery(objectName, whereClause, relationshipName, additionalFields, onlyCreateable, false, null, false);
    }

    public static string getSelectAllQuery(String objectName, String whereClause, String relationshipName, String additionalFields, boolean onlyCreateable, Boolean isPersonAccount){
        return getSelectAllQuery(objectName, whereClause, relationshipName, additionalFields, onlyCreateable, isPersonAccount, null, false);
    }

    public static string getSelectAllQuery(String objectName, String whereClause, String relationshipName, String additionalFields, boolean onlyCreateable, Boolean isPersonAccount, Set<String> excludeFields){
        return getSelectAllQuery(objectName, whereClause, relationshipName, additionalFields, onlyCreateable, isPersonAccount, excludeFields, false);
    }

    public static string getSelectAllQuery(String objectName, String whereClause, String relationshipName, String additionalFields, boolean onlyCreateable, Boolean isPersonAccount, Set<String> excludeFields, Boolean picklistToLabel){
        if (String.isBlank(relationshipName) && String.isBlank(whereClause)){ return null; }

        Boolean isAccount = objectName.toLowerCase() == 'account';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Set<string> selectFields = new Set<string>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
                String fName = fd.getName();
                if(!isAccount || ((!isPersonAccount && !fName.startsWith('Person') && !fName.endsWith('__pc') && fName != 'FirstName' && fName != 'LastName' && fName != 'Salutation') || (isPersonAccount && fName != 'Name'))) {
                    if( ((fd.isCreateable() || fd.isUpdateable()) || !onlyCreateable)) {
                        if (picklistToLabel && fd.getType() == Schema.DisplayType.Picklist){
                            selectFields.add('toLabel(' + fName.toLowerCase() + ')');
                        } else {
                            selectFields.add(fName.toLowerCase());
                        }
                    }
                }
            }
        }

        if(excludeFields != null) selectFields.removeAll(excludeFields);
        if(!String.isEmpty(additionalFields)) {
            selectFields.addAll(parseAdditionalFields(additionalFields));
        }

        String[] selectFieldsList = new String[]{};
        if (!selectFields.isEmpty()){
            selectFieldsList.addAll(selectFields);
            selectFieldsList.sort();
        }

        return getSelectQuery(!String.isBlank(relationshipName) ? relationshipName : objectName, selectFieldsList, whereClause);
    }

    public static String getSelectQuery(String objectName, String[] fields, String whereClause) {
        String w = (!String.isBlank(whereClause) ? ' WHERE ' + whereClause : '');
        return 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectName + w;
    }

    public static Set<String> parseAdditionalFields(String additionalFields) {
        Set<String> res = new Set<String>();
        String[] preRes = additionalFields.toLowerCase().split(',');
        if(!additionalFields.contains('(')) {
            res.addAll(preRes);
            return res;
        }

        Integer count = 0;
        while(count < preRes.size()) {
            String x = preRes[count];
            if(!x.contains('(')) res.add(x);
            else {
                Integer parenthesisCount = 1;
                String[] subQuery = new String[]{};
                subQuery.add(x);
                while(parenthesisCount != 0) {
                    String token = preRes[++count];
                    subQuery.add(token);
                    parenthesisCount = parenthesisCount + token.countMatches('(') - token.countMatches(')');
                }
                res.add(String.join(subQuery, ','));
            }
            count++;
        }

        Set<String> buf = new Set<String>();
        for(String s : res) {
            buf.add(s.trim());
        }
        return buf;
    }

    public class TriggerUtils {
        public SObject[] triggerNew;
        public Map<Id, SObject> oldMap;
        private Schema.DescribeSObjectResult describeInfo;

        public TriggerUtils(SObject[] triggerNew, Map<Id, SObject> oldMap) {
            this(triggerNew == null ? new SObject[]{} : triggerNew, oldMap, triggerNew == null || triggerNew.isEmpty() ? (trigger.oldMap == null || trigger.oldMap.isEmpty() ? null : trigger.oldMap.values()[0].getSObjectType().getDescribe()) : triggerNew[0].getSObjectType().getDescribe());
        }

        private TriggerUtils(SObject[] triggerNew, Map<Id, SObject> oldMap, Schema.DescribeSObjectResult describeMap) {
            this.triggerNew = triggerNew;
            this.oldMap = oldMap;
            this.describeInfo = describeMap;
        }

        public Map<String, Schema.SObjectField> getFields() {
            return describeInfo == null ? null : describeInfo.fields.getMap();
        }

        public Boolean isUpdate {
            get {
                return oldMap != null;
            }
        }

        public String getObjectName() {
            return describeInfo == null ? null : describeInfo.getName();
        }

        public SObject[] getChanged(String[] fieldsToCheck) {
            return getChanged(fieldsToCheck, false);
        }

        public SObject[] getChanged(String[] fieldsToCheck, Boolean skipCheck) {
            if(!isUpdate || skipCheck) return triggerNew;
            SObject[] res = new SObject[]{};
            Map<String, Schema.SObjectField> objFields = getFields();
            for(SObject obj : triggerNew) {
                for(String field : fieldsToCheck) {
                    if(!objFields.containsKey(field)) continue;
                    //Object vL = obj.get(field);
                    //Object vR = oldMap.get(obj.Id).get(field);
                    //Boolean isChanged1 = (vL == null || vR == null) && vL != vR;
                    //Boolean isChanged2 = (vL != null && !vL.equals(vR)) || (vR != null && !vR.equals(vL));
                    //if(isChanged1 || isChanged2) {
                    if(obj.get(field) != oldMap.get(obj.id).get(field)) {
                        res.add(obj);
                        break;
                    }
                }
            }
            return res;
        }

        public TriggerUtils filterByChanged(String[] fieldsToCheck) {
            return new TriggerUtils(getChanged(fieldsToCheck), oldMap, describeInfo);
        }

        public TriggerUtils filterByOld(String field, Object value) {
            return filterByOld(field, value, true);
        }

        public TriggerUtils filterByOld(String field, Object value, Boolean includeOrExclude) {
            SObject[] res = new SObject[]{};

            if(!isUpdate && !includeOrExclude) return this;
            if(!isUpdate || !getFields().containsKey(field)) return new TriggerUtils(res, oldMap, describeInfo);
            SObject[] filteredOlds = filterBy(oldMap.values(), field, value, includeOrExclude);
            Map<Id, SObject> newMap = new Map<Id, SObject>(triggerNew);
            for(SObject o : filteredOlds) {
                if(newMap.containsKey(o.Id)) res.add(newMap.get(o.Id));
            }
            return new TriggerUtils(res, oldMap, describeInfo);
        }

        public TriggerUtils filterBy(String field, Object value) {
            return filterBy(field, value, true);
        }

        public TriggerUtils filterBy(String field, Object value, Boolean includeOrExclude) {
            SObject[] res = new SObject[]{};
            if(!getFields().containsKey(field)) return new TriggerUtils(res, oldMap, describeInfo);
            return new TriggerUtils(filterBy(triggerNew, field, value, includeOrExclude), oldMap, describeInfo);
        }
    }

    /**
     *  Concatena tra loro il set di elementi interponendo la stringa separator tra di essi. Utile perchè il join di SFDC è supportato solo sulle liste.
     *  Inoltre, gestisce senza errori il caso di set nullo o vuoto
     */
    public static String join(Set<String> elements, String separator) {
        if(elements == null || elements.isEmpty()) return '';
        String[] elementList = new String[]{};
        elementList.addAll(elements);
        return String.join(elementList, separator);
    }

    public static String addToMultiselect(String multiselect, String value) {
        Set<String> valuesSet = new Set<String>();
        String[] values = new String[]{};
        valuesSet.addAll(split(multiselect, ';'));
        valuesSet.addAll(split(value, ';'));
        values.addAll(valuesSet);
        values.sort();
        return String.join(values, ';');
    }

    public static String replaceInMultiselect(String multiselect, String oldValue, String newValue) {
        Set<String> valuesSet = new Set<String>();
        Set<String> newValuesSet = new Set<String>();
        String[] values = new String[]{};
        valuesSet.addAll(split(multiselect, ';'));
        for(String x : valuesSet) {
            if(x == oldValue && newValue != null) newValuesSet.add(newValue);
            else if(x != oldValue) newValuesSet.add(x);
        }
        values.addAll(newValuesSet);
        values.sort();
        return String.join(values, ';');
    }

    public static Boolean isInMultiselect(String multiselect, String value) {
        if(String.isBlank(multiselect) || String.isBlank(value)) return false;
        Set<String> values = new Set<String>();
        values.addAll(multiselect.split(';'));
        return values.contains(value);
    }

    /**
     *  Simile allo split standard di SFDC, ma gestisce il caso di stringa vuota o nulla in ingresso
     */
    public static String[] split(String value, String separator) {
        if(String.isBlank(value)) return new String[]{};
        return value.split(separator);
    }

    /**
     *  Simile al substring standard di SFDC, ma gestisce il caso in cui endIndex è maggiore della lunghezza della stringa. In questo caso, il substring si
     *  ferma senza errori quando raggiunge la fine della stringa
     */
    public static String substring(String x, Integer beginIndex, Integer endIndex) {
        if(x == null) return null;
        else return x.substring(beginIndex, Math.min(endIndex, x.length()));
    }

    /**
     *  Estrae una mappa di SObject la cui chiave è composta da uno o più campi degli oggetti contenuti in objList, e il valore è l'oggetto.
     *  Ne consegue che la chiave della mappa dovrebbe essere univoca, altrimenti come valore sopravvive solo l'ultimo della lista ad avere tale chiave.
     *  @objList La lista di oggetti da cui si vuole creare la mappa
     *  @keyPattern una stringa contenente uno o più "tag" {nomeCampo} concatenati a piacimento, che rappresenta il formato che avranno le chiavi della mappa
     *              (es: "{name}" , oppure "{firstName}_{lastName}")
     */
    public static Map<String, SObject> extractMap(SObject[] objList, String keyPattern) {
        return extractMap(objList, keyPattern, false);
    }

    public static Map<String, SObject> extractMap(SObject[] objList, String keyPattern, Boolean noRegularExpr) {
        Map<String, SObject> res = new Map<String, SObject>();
        if(objList == null) return res;

        Map<String, String> pattern2FieldMap = new Map<String, String>();
        if(!noRegularExpr) {
            Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
            Matcher m = pat.matcher(keyPattern);

            while(m.find()) {
                String f = m.group().substringAfter('{').substringBeforeLast('}');
                pattern2FieldMap.put(m.group(), f);
            }
        }

        if(objList == null) return res;
        for(SObject obj : objList) {
            if(noRegularExpr) {
                String v = (String) obj.get(keyPattern);
                if(v != null) res.put(v, obj);
            } else {
                String compiledPattern = keyPattern;
                for(String p : pattern2FieldMap.keySet()) {
                    String value = (String) obj.get(pattern2FieldMap.get(p));
                    if(value != null) {
                        compiledPattern = compiledPattern.replace(p, value);
                    }
                }
                res.put(compiledPattern, obj);
            }
        }

        return res;
    }

    public static Map<String, String> extractMapOfValues(SObject[] objList, String keyPattern, String fieldToExtract) {
        Map<String, String> res = new Map<String, String>();
        if(objList == null) return res;

        Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
        Matcher m = pat.matcher(keyPattern);
        Map<String, String> pattern2FieldMap = new Map<String, String>();

        while(m.find()) {
            System.debug(m.group());
            String f = m.group().substringAfter('{').substringBeforeLast('}');
            pattern2FieldMap.put(m.group(), f);
        }

        if(objList == null) return res;
        for(SObject obj : objList) {
            String compiledPattern = keyPattern;
            for(String p : pattern2FieldMap.keySet()) {
                String value = (String) obj.get(pattern2FieldMap.get(p));
                if(value != null) {
                    compiledPattern = compiledPattern.replace(p, value);
                }
            }

            if(fieldToExtract.contains('.')) {
                String[] tokens = fieldToExtract.split('\\.');
                SObject subObj = obj;
                for(Integer i = 0; i < tokens.size() - 1; i++) {
                    subObj = subObj.getSObject(tokens[i]);
                }
                res.put(compiledPattern, (String) subObj.get(tokens[tokens.size() - 1]));
            } else {
                res.put(compiledPattern, (String) obj.get(fieldToExtract));
            }
        }

        return res;
    }

    /**
     *  Estrae un set di id da una lista di oggetti
     *  @objList la lista di oggetti
     *  @idField il nome del campo che si vuole estrarre
     */
    public static Set<Id> extractIdSet(SObject[] objList, String idField) {
        Set<Id> res = new Set<Id>();
        for(SObject obj : objList) {
            if(idField.contains('.')) {
                String[] tokens = idField.split('\\.');
                SObject subObj = obj;
                for(Integer i = 0; i < tokens.size() - 1; i++) {
                    subObj = subObj.getSObject(tokens[i]);
                    if(subObj == null) break;
                }
                if(subObj != null && subObj.get(tokens[tokens.size() - 1]) != null) {
                    res.add((Id) subObj.get(tokens[tokens.size() - 1]));
                }
            } else if(obj.get(idField) != null) {
                res.add((Id) obj.get(idField));
            }
        }
        return res;
    }

    /**
     *  Estrae un set di stringhe da una lista di oggetti
     *  @objList la lista di oggetti
     *  @idField il nome del campo che si vuole estrarre
     */
    public static Set<String> extractSet(SObject[] objList, String field) {
        Set<String> res = new Set<String>();
        if(objList==null) return res;
        for(SObject obj : objList) {
            //Object val = getSObjectValue(obj, field);
            //if(val != null) res.add((String) val);
            if(obj.get(field) != null) {
                res.add((String) obj.get(field));
            }
        }
        return res;
    }

    public static Set<String> extractSetRecursive(SObject[] objList, String field) {
        Set<String> res = new Set<String>();
        for(SObject obj : objList) {
            Object val = getSObjectValue(obj, field);
            if(val != null) res.add((String) val);
        }
        return res;
    }

    /**
     *  Estrae una mappa di SObject la cui chiave è composta da uno o più campi degli oggetti contenuti in objList, e il valore è la lista di oggetti aventi tale chiave.
     *  Ne consegue che la chiave della mappa può non essere univoca.
     *  @objList La lista di oggetti da cui si vuole creare la mappa
     *  @keyPattern una stringa contenente uno o più "tag" {nomeCampo} concatenati a piacimento, che rappresenta il formato che avranno le chiavi della mappa
     *              (es: "{name}" , oppure "{firstName}_{lastName}")
     */
    public static Map<String, SObject[]> extractGroupedMap(SObject[] objList, String keyPattern) {
        return extractGroupedMap(objList, keyPattern, false);
    }

    public static Map<String, SObject[]> extractGroupedMap(SObject[] objList, String keyPattern, Boolean noRegularExpr) {
        Map<String, String> pattern2FieldMap = new Map<String, String>();
        if(!noRegularExpr) {
            Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
            Matcher m = pat.matcher(keyPattern);

            while(m.find()) {
                System.debug(m.group());
                String f = m.group().substringAfter('{').substringBeforeLast('}');
                pattern2FieldMap.put(m.group(), f);
            }
        }

        Map<String, SObject[]> res = new Map<String, SObject[]>();
        for(SObject obj : objList) {
            if(noRegularExpr) {
                String v = (String) obj.get(keyPattern);
                addToGroupedMap(res, v != null ? v : 'null', obj);
            }else {
                String compiledPattern = keyPattern;
                for(String p : pattern2FieldMap.keySet()) {
                    String value;
                    try {
                        value = (String) getSObjectValue(obj, pattern2FieldMap.get(p));// obj.get(pattern2FieldMap.get(p));
                    } catch(Exception e) {
                        value = 'null';
                    }
                    compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
                }
                addToGroupedMap(res, compiledPattern, obj);
            }
        }

        return res;
    }

    public static Map<String, Set<String>> extractGroupedMapOfValues(SObject[] objList, String keyPattern, String fieldToExtract) {
        Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
        Matcher m = pat.matcher(keyPattern);
        Map<String, String> pattern2FieldMap = new Map<String, String>();

        while(m.find()) {
            System.debug(m.group());
            String f = m.group().substringAfter('{').substringBeforeLast('}');
            pattern2FieldMap.put(m.group(), f);
        }

        Map<String, Set<String>> res = new Map<String, Set<String>>();
        for(SObject obj : objList) {
            String compiledPattern = keyPattern;
            for(String p : pattern2FieldMap.keySet()) {
                String value;
                try {
                    value = (String) obj.get(pattern2FieldMap.get(p));
                } catch(Exception e) {
                    value = 'null';
                }
                compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
            }
            if(!res.containsKey(compiledPattern)) res.put(compiledPattern, new Set<String>());

            if(fieldToExtract.contains('.')) {
                String[] tokens = fieldToExtract.split('\\.');
                SObject subObj = obj;
                for(Integer i = 0; i < tokens.size() - 1; i++) {
                    subObj = subObj.getSObject(tokens[i]);
                }
                res.get(compiledPattern).add((String) subObj.get(tokens[tokens.size() - 1]));
            } else {
                res.get(compiledPattern).add((String) obj.get(fieldToExtract));
            }

        }

        return res;
    }

    public static void addToGroupedMap(Map<String, SObject[]> m, String key, SObject value) {
        if(!m.containsKey(key)) m.put(key, new SObject[]{});
        m.get(key).add(value);
    }

    /**
     *  Filtra la lista di oggetti in input sulla base del valore di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value il valore del campo
     */
    public static SObject[] filterBy(SObject[] coll, String field, Object value) {
        return filterBy(coll, field, value, true);
    }

    /**
     *  Filtra la lista di oggetti in input sulla base del valore di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value il valore del campo
     *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
     *                    presente solo se il valore del campo NON è uguale a value
     */
    public static SObject[] filterBy(SObject[] coll, String field, Object value, Boolean includeOrExclude) {
        if(value != null && (value instanceof Set<String> || value instanceof Set<Id>)) {
            //System.debug('ISSET!!!! true');
            return filterBy(coll, field, (Set<String>) value, includeOrExclude);
        }
        SObject[] res = new SObject[]{};
        if(coll == null) return res;
        for(SObject x : coll) {
            Object val = getSObjectValue(x, field);
            if((value == val && includeOrExclude) || (!includeOrExclude && value != val)) res.add(x);
        }
        return res;
    }

    /**
     *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value L'insieme dei valori da controllare. I valori sono messi in OR
     */
    public static SObject[] filterBy(SObject[] coll, String field, Set<String> value) {
        return filterBy(coll, field, value, true);
    }

    /**
     *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
     *  @coll La lista di oggetti
     *  @field Il nome api del campo
     *  @value L'insieme dei valori da controllare. I valori sono messi in OR
     *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
     *                    presente solo se il valore del campo NON è uguale a value
     */
    public static SObject[] filterBy(SObject[] coll, String field, Set<String> value, Boolean includeOrExclude) {
        SObject[] res = new SObject[]{};
        if(coll == null) return res;
        for(SObject x : coll) {
            Object val = getSObjectValue(x, field);
            if((includeOrExclude && value.contains((String) val)) || (!includeOrExclude && !value.contains((String) val))) res.add(x);
        }
        return res;
    }

    public class FilterByFilter {
        public Object value;
        public Boolean includeOrExclude = true;

        public FilterByFilter(Object value) {
            this(value, true);
        }

        public FilterByFilter(Object value, Boolean includeOrExclude) {
            this.value = value;
            this.includeOrExclude = includeOrExclude;
        }
    }

    public static SObject[] filterBy(SObject[] coll, Map<String, FilterByFilter> filters) {
        SObject[] res = coll;
        for(String f : filters.keySet()) {
            res = filterBy(res, f, filters.get(f).value, filters.get(f).includeOrExclude);
        }
        return res;
    }

    public static String join(String el1, String el2, String separator) {
        if(String.isBlank(el1)) return el2;
        else if(String.isBlank(el2)) return el1;
        else return el1 + separator + el2;
    }

    /*
     * Il metodo viene usato per normalizzare i nomi e cognomi all'interno del sistema. In particolare:
     * -Elimina spazi prima e dopo
     * -Capitalizza la prima lettera
     * -Capitalizza ogni lettera che segue uno spazio o un apostrofo
     * -Rende minuscola ogni altra lettera
     */
    public static String addCapitalLetters(String s){
        if(s == null) return null;
        String temp='';
        if(s.length()>0){
            s=s.Trim();
            for(integer n=0;n<s.length();n++){
                if(n==0 || s.substring(n-1,n)==' ' || s.substring(n-1,n)=='\'')
                     temp=temp+s.substring(n,n+1).toUpperCase();//se è la prima lettera, o preceduta da spazio vuoto o '
                else
                    temp=temp+s.substring(n,n+1).toLowerCase();

            }
        }
        return temp;
    }


    public static String toUpperCaseOrVoid(String s){
        return s != null ? s.toUpperCase() : '';
    }

    public class SObjectSorter implements Comparable {
        public SObject obj;
        private String fieldName;
        private Boolean ascOrDesc;
        private String typeOfField;

        public SObjectSorter(SObject obj, String fieldName, Boolean ascOrDesc, String typeOfField) {
            this.obj = obj;
            this.fieldName = fieldName;
            this.ascOrDesc = ascOrDesc;
            this.typeOfField = typeOfField;
        }

        public Integer compareTo(Object compareTo) {
            SObjectSorter cmp = (SObjectSorter)compareTo;
            Integer returnValue = 0;

            Object vL = obj.get(fieldName);
            Object vR = cmp.obj.get(fieldName);

            Boolean vLGreaterThanVR;

            if(vL == vR) return 0;

            if(typeOfField == 'date') {
                vLGreaterThanVR = (Date) vL > (Date) vR;
            } else if(typeOfField == 'datetime') {
                vLGreaterThanVR = (Datetime) vL > (Datetime) vR;
            } else if(typeOfField == 'string') {
                vLGreaterThanVR = (String) vL > (String) vR;
            } else if(typeOfField == 'decimal') {
                vLGreaterThanVR = (Decimal) vL > (Decimal) vR;
            }

            if(ascOrDesc) {
                return vLGreaterThanVR ? 1 : -1;
            } else {
                return vLGreaterThanVR ? -1 : 1;
            }
        }
    }

    public static SObject[] sortBy(SObject[] coll, String field, Boolean ascOrDesc) {
        return sortBy(coll, field, ascOrDesc, 'string');
    }

    public static SObject[] sortBy(SObject[] coll, String field, Boolean ascOrDesc, String typeOfField) {
        SObjectSorter[] resWrapper = new SObjectSorter[]{};
        for(SObject o : coll) {
            resWrapper.add(new SObjectSorter(o, field, ascOrDesc, typeOfField));
        }
        resWrapper.sort();

        SObject[] res = new SObject[]{};
        for(SObjectSorter ss : resWrapper) {
            res.add(ss.obj);
        }

        return res;
    }

    /**
     *  Restituisce una mappa valore => label relativa ad una picklist
     *  @field Il campo picklist di cui si vuole ottenere la mappa
     */
    public static Map<String, String> getPicklistMap(Schema.SObjectField field) {
        return getPicklistMap(field.getDescribe());
    }

    public static Map<String,String> getPicklistMap(Schema.DescribeFieldResult dfr) {
        Map<String, String> res = new Map<String,String>();
        Schema.PicklistEntry[] pickValues = dfr.getPickListValues();
        for(Schema.PicklistEntry ple : pickValues) {
            res.put(ple.getValue(), ple.getLabel());
        }
        return res;
    }

    /**
     *  Restituisce una lista di selectOption con i valori di una picklist
     */
    public static SelectOption[] getPicklistSelectOptions(Schema.SObjectField field) {
        return getPicklistSelectOptions(field,true);
    }
    public static SelectOption[] getPicklistSelectOptions(Schema.SObjectField field,boolean addNullValue) {
        SelectOption[] res = new SelectOption[]{};
        if(addNullValue){
            res.add(new SelectOption('','--Seleziona--'));
        }
        Schema.PicklistEntry[] pickValues = field.getDescribe().getPickListValues();
        for(Schema.PicklistEntry ple : pickValues) {
            res.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return res;
    }

    /**
     *  Restituisce una mappa DeveloperName => RecordType di tutti i recordtypes di un oggetto
     *  @obj Il nome dell'oggetto di cui si vogliono recuperare i recordType
     */
    private static Map<String, Map<String, SObject>> rtCache = new Map<String, Map<String, SObject>>();
    public static Map<String, SObject> getRecordTypes(String sobj) {
        if(!rtCache.containsKey(sobj)) {
            rtCache.put(sobj, extractMap([SELECT Id, SObjectType, Name, DeveloperName, IsActive, Description FROM RecordType WHERE SObjectType = :sobj], 'DeveloperName', true));
        }
        return rtCache.get(sobj);
    }

    /**
     *  Imposta massivamente su una lista di oggetti i campi passati in input
     */
    public static void massSet(SObject[] objs, String fieldName, Object value) {
        for(SObject obj : objs) {
            obj.put(fieldName, value);
        }
    }

    public static void massSet(SObject[] objs, Map<String, Object> fieldMap) {
        Set<String> fields = fieldMap.keySet();
        for(SObject obj : objs) {
            for(String f : fields) {
                obj.put(f, fieldMap.get(f));
            }
        }
    }

    public static void dynamicMassSet(SObject[] objs, String fieldName, String fieldFormula) {
        Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
        Matcher m = pat.matcher(fieldFormula);
        Map<String, String> pattern2FieldMap = new Map<String, String>();

        while(m.find()) {
            String f = m.group().substringAfter('{').substringBeforeLast('}');
            pattern2FieldMap.put(m.group(), f);
        }

        for(SObject obj : objs) {
            String compiledPattern = fieldFormula;
            for(String p : pattern2FieldMap.keySet()) {
                String value = (String) getSObjectValue(obj, pattern2FieldMap.get(p));
                if(value == null) value = 'null';
                compiledPattern = compiledPattern.replace(p, value);
            }
            obj.put(fieldName, compiledPattern);
        }
    }

    public static Boolean has(SObject[] objs, String fieldName, Object value) {
        for(SObject obj : objs) {
            if(obj.get(fieldName) == value) return true;
        }
        return false;
    }

    public static Boolean valueIn(Object value, Set<Object> possibilities) {
        return possibilities.contains(value);
    }

    public static Set<String> toSet(String[] l) {
        Set<String> res = new Set<String>();
        if(l != null) res.addAll(l);
        return res;
    }

    public static List<String> toList(Set<String> s) {
        String[] res = new String[]{};
        if(s != null) res.addAll(s);
        return res;
    }

    public static String leftPad(Object x, Integer length, String padWith) {
        String target = (x == null) ? '' : String.valueOf(x);
        return target.leftPad(length).replace(' ', padWith);
    }

    private static Map<String, String[]> tokensMap = new Map<String, String[]>();
    public static Object getSObjectValue(SObject obj, String field) {
        if(String.isBlank(field) || obj == null) return null;
        else if(!field.contains('.')) return obj.get(field);
        else {
            try {
                SObject subObj = obj;
                if(!tokensMap.containsKey(field)) tokensMap.put(field, field.split('\\.'));
                String[] tokens = tokensMap.get(field);
                for(Integer i = 0; i < tokens.size() - 1; i++) {
                    subObj = subObj.getSObject(tokens[i]);
                }
                return subObj.get(tokens[tokens.size() - 1]);
            } catch(Exception e) {
                return null;
            }
        }
    }

    private static String kHexChars = '0123456789abcdef';

    public static String newGuid() {
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    public static String getCharAtIndex(String str, Integer index) {
        if (str == null) return null;
        if (str.length() <= 0) return str;
        if (index >= str.length()) return null;
        return str.substring(index, index+1);
    }

    public static String[] prepend(String[] l, String i) {
        return prepend(l, new String[]{i});
    }

    public static String[] prepend(String[] l, String[] items) {
        String[] x = items.clone();
        x.addAll(l);
        return x;
    }

    public static String[] removeDuplicates(String[] l) {
        Set<String> lSet = toSet(l);
        if(lSet.size() == l.size()) return l.clone();
        else {
            String[] res = new String[]{};
            for(String x : l) {
                if(lSet.contains(x)) {
                    res.add(x);
                    lSet.remove(x);
                }
            }
            return res;
        }
    }

    public static String iD15to18(String inID) {
        if (inID.length() == 18) { return inID; }
        else if (inID.length() != 15) { return ''; }
        else {
            String suffix = '';
            for (Integer i = 0; i < 3; i++) {
                Integer flags = 0;
                for (Integer j = 0; j < 5; j++) {
                    String c = inID.substring(i*5+j, i*5+j+1);
                    if ( ( c.compareTo('A') >= 0 ) && ( c.compareTo('Z') <= 0 ) ) {
                      flags += 1 << j;
                    }
                }
                suffix = suffix + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345'.substring(flags, flags+1);
            }
            return inID + suffix;
        }
    }


    // Utile per generare codice apex di creazione di un record di test a partire da un record esistente
    public static String createTestMethod(Id sObjectId, Boolean isPersonAccount) {
        Schema.SObjectType sobjectType = sObjectId.getSObjectType();
        String sobjectApiName = sobjectType.getDescribe().getName();
        String sobjectCamelCaseName = sobjectApiName.replace('__c', '').replace('_', '');
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(sobjectApiName).getDescribe().Fields.getMap();
        Boolean isAccount = sobjectApiName.toLowerCase() == 'account';
        List<string> selectFields = new List<string>();

        Map<String, String> fieldTypeMap = new Map<String, String>();
        Schema.DescribeSObjectResult objResult = sobjectType.getDescribe();
        for (String fieldName : objResult.fields.getMap().keySet()) {
            String fieldType = String.valueOf(objResult.fields.getMap().get(fieldName).getDescribe().getType());
            fieldType = fieldType.toLowerCase();
            fieldTypeMap.put((String)fieldName.toLowerCase(), fieldType);
        }

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
                String fName = fd.getName();
                if(!isAccount || ((!isPersonAccount && !fName.startsWith('Person') && !fName.endsWith('__pc') && fName != 'FirstName' && fName != 'LastName' && fName != 'Salutation') || (isPersonAccount && fName != 'Name'))) {
                    if(fd.isCreateable() || fd.isUpdateable()) {
                        selectFields.add(fName);
                    }
                }
            }
        }

        String query = 'SELECT ' + String.join(selectFields, ',') + ' FROM ' + sobjectApiName + ' WHERE Id = ' + '\'' + sObjectId + '\'';
        SObject record = Database.query(query);

        String s = '';

        s += 'public static ' + sobjectApiName + ' create' + sobjectCamelCaseName + '() {\n';
        s += '\t' + sobjectApiName + ' obj = new ' + sobjectApiName + '();\n';

        for(String field : selectFields) {
            String sourceFieldType = fieldTypeMap.get(field.toLowerCase());
            Object fieldValue = record.get(field);
            if(sourceFieldType == 'id' || sourceFieldType == 'string' || sourceFieldType == 'email' || sourceFieldType == 'multipicklist' || sourceFieldType == 'phone' || sourceFieldType == 'picklist' || sourceFieldType == 'url' || sourceFieldType == 'textarea' || sourceFieldType == 'calculated') {
                if(fieldValue != null) {
                    s += 'obj.' + field + ' = \'' + String.escapeSingleQuotes((String)fieldValue) + '\';\n';
                }
            }
            else if(sourceFieldType == 'date'){
                if (fieldValue != null) {
                    s += 'obj.' + field + ' = Date.newInstance(' + Date.valueOf(fieldValue).year() + ', ' + Date.valueOf(fieldValue).month() + ', ' + Date.valueOf(fieldValue).day() +');\n';
                }
            }
            else if(sourceFieldType == 'datetime'){
                if (fieldValue != null) {
                    s += 'obj.' + field + ' = Datetime.newInstance(' + Datetime.valueOf(fieldValue).year() + ', ' + Datetime.valueOf(fieldValue).month() + ', ' + Datetime.valueOf(fieldValue).day() +');\n';
                }
            }
            else if(sourceFieldType == 'reference'){
                if (fieldValue != null) {
                    s += 'obj.' + field + ' = ' + fieldValue + ';\n'; // TODO
                }
            }
            else {
                if(fieldValue != null) {
                    s += 'obj.' + field + ' = ' + fieldValue + ';\n';
                }
            }
        }
        s += '\treturn obj;\n';
        s += '}';

        return s;
    }
}