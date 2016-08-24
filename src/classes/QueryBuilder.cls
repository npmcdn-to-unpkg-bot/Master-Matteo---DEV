public with sharing class QueryBuilder {
    String[] fields;
    String obj;
    Integer qlimit;
    String[] orderBy;
    FilterBuilder rootFilter;

    String crossFilterObj;
    String crossFilterId;

    public class FilterBuilder {
        String[] filters;
        QueryBuilder qb;
        String operation;
        FilterBuilder parent;

        public FilterBuilder(QueryBuilder qb, String operation, FilterBuilder parent) {
            this.filters = new String[]{};
            this.qb = qb;
            this.operation = operation;
            this.parent = parent;
        }

        public FilterBuilder add(String field, QBOp op, Object value) {
            return add(field, op, value, null);
        }

        public FilterBuilder add(String field, QBOp op, Object value, Boolean rendered) {
            String v = getValue(value);
            QBOp o = op;
            if(v == '(\'\')') v = null;

            if((rendered == null && (v == null || v == '\'\'')) || (rendered != null && !rendered)) return this;
            else if(v == null || v == '\'\'') {
                if(v == null) v = 'NULL';
                if(op == QBOp.QIN || op == QBOp.QLIKE) o = QBOp.QEQUAL;
                else if(op == QBOp.QNOT_IN || op == QBOp.QNOT_LIKE) o = QBOp.QNOT_EQUAL;
            }

            if(o == QBOp.QLIKE || o == QBOp.QNOT_LIKE) v = v.replace('*', '%');

            filters.add(field + ' ' + getOperator(o) + ' ' + v);
            return this;
        }

        public FilterBuilder addUntyped(String filter) {
            filters.add(filter);
            return this;
        }

        public FilterBuilder end() {
            if(parent != null && !filters.isEmpty()) {
                parent.addUntyped('(' + String.join(filters, operation == 'and' ? ' AND ' : ' OR ') + ')');
                filters = null;
            }
            return parent;
        }

        public QueryBuilder endFilter() {
            FilterBuilder current = this;
            while(current != null) {
                current = current.end();
            }
            return qb;
        }

        public FilterBuilder beginOr() {
            return new FilterBuilder(qb, 'or', this);
        }

        public FilterBuilder beginCrossFilter(String obj, String idToMatch) {
            qb.crossFilterObj = obj;
            qb.crossFilterId = idToMatch;
            return new FilterBuilder(qb, 'and', this);
        }

        public FilterBuilder endCrossFilter() {
            return endCrossFilter(true);
        }

        public FilterBuilder endCrossFilter(Boolean renderedIfNoFilters) {
            String q = 'Id IN (SELECT ' + qb.crossFilterId + ' FROM ' + qb.crossFilterObj;
            if(!this.filters.isEmpty()) q += ' WHERE ' + String.join(filters, ' AND ');
            q += ')';
            if(!filters.isEmpty() || renderedIfNoFilters) parent.addUntyped(q);
            qb.crossFilterId = null;
            qb.crossFilterObj = null;
            return parent;
        }

        private String getValue(Object v) {
            if(v instanceof List<String> || v instanceof List<Id> || v instanceof Set<String> || v instanceof Set<Id>) return '(\'' + escapedJoin(v, '\',\'') + '\')';
            else if(v instanceof String || v instanceof Id) return '\'' + String.escapeSingleQuotes((String) v) + '\'';
            else if(v instanceof Date) return Datetime.newInstance((Date) v, Time.newInstance(0, 0, 0, 0)).format('YYYY-MM-dd');
            else if(v instanceof Datetime) return ((Datetime) v).format('YYYY-MM-dd\'T\'hh:mm:ss.SSSZ');
            else if(v != null) return String.valueOf(v);
            else return null;
        }

        private String getOperator(QBOp op) {
            if(op == QBOp.QLIKE) return 'LIKE';
            else if(op == QBOp.QGT) return '>';
            else if(op == QBOp.QLT) return '<';
            else if(op == QBOp.QEQUAL) return '=';
            else if(op == QBOp.QNOT_EQUAL) return '!=';
            else if(op == QBOp.QIN) return 'IN';
            else if(op == QBOp.QNOT_IN) return 'NOT IN';
            else return null;
        }
    }

    public static QueryBuilder newInstance(String obj, String[] fields) {
        QueryBuilder qb = new QueryBuilder(obj, fields);
        return qb;
    }

    public QueryBuilder(String obj, String[] fields) {
        this.orderBy = new String[]{};
        this.obj = obj;
        this.fields = fields;
        this.rootFilter = new FilterBuilder(this, 'and', null);
    }

    public FilterBuilder beginFilter() {
        return rootFilter;
    }

    public QueryBuilder orderBy(String[] orderBy) {
        this.orderBy = orderBy;
        return this;
    }

    public QueryBuilder setLimit(Integer qlimit) {
        this.qlimit = qLimit;
        return this;
    }

    public String getQuery() {
        String q = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + obj;
        if(!rootFilter.filters.isEmpty()) q += ' WHERE ' + String.join(rootFilter.filters, ' AND ');
        if(!orderBy.isEmpty()) q += ' ORDER BY ' + String.join(orderBy, ', ');
        if(qLimit != null) q += ' LIMIT ' + String.valueOf(qLimit);
        rootFilter = null;
        return q;
    }

    private static String escapedJoin(Object x, String sep) {
        String[] res = new String[]{};
        if(x instanceof Set<String>) {
            for(String v : (Set<String>) x) {
                res.add(String.escapeSingleQuotes(v));
            }
        } else if(x instanceof Set<Id>) {
            for(Id v : (Set<Id>) x) {
                res.add(String.escapeSingleQuotes(v));
            }
        } else if(x instanceof List<String>) {
            for(String v : (List<String>) x) {
                res.add(String.escapeSingleQuotes(v));
            }
        } else if(x instanceof List<Id>) {
            for(Id v : (List<Id>) x) {
                res.add(String.escapeSingleQuotes(v));
            }
        }
        return String.join(res, sep);
    }
}