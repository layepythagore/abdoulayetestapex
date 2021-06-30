public with sharing class SubscriptionAction {

    public static void updateContracteEndDate(List<SBQQ__Subscription__c> subscriptions){
        Boolean isTerminate;
        Date terminatedDate;
        Date endDate;
    
        List<SBQQ__Subscription__c> subs = [SELECT SBQQ__Contract__c,TechAmendmentReason__c FROM SBQQ__Subscription__c where id =:subscriptions];
        Set<Id> cons = new Set<Id>();
        for (SBQQ__Subscription__c sub :subs) {
            cons.add(sub.SBQQ__Contract__c);
        }
        try {
            List<Contract> conts = new List<Contract>();
            for (Contract con : [SELECT Id, EndDate, (SELECT Id, SBQQ__EndDate__c, SBQQ__TerminatedDate__c, SBQQ__Contract__c 
                                    FROM SBQQ__Subscriptions__r) FROM Contract WHERE Id IN :cons]) {
                                                
                isTerminate = true;
                terminatedDate = con.EndDate;
                endDate = con.EndDate;
                
                for (SBQQ__Subscription__c sub : con.SBQQ__Subscriptions__r) {
                    if (sub.SBQQ__TerminatedDate__c == null) {
                        isTerminate = false;
                    } else if (terminatedDate < sub.SBQQ__TerminatedDate__c) {
                        terminatedDate = sub.SBQQ__TerminatedDate__c;
                    }
                    if (sub.SBQQ__EndDate__c != null && endDate < sub.SBQQ__EndDate__c) {
                        endDate = sub.SBQQ__EndDate__c;
                    }
                }
                if (isTerminate) {
                    con.EndDate = terminatedDate;
                } else {
                    con.EndDate = endDate;
                }                                   
                conts.add(con);
            }        
            update conts;
        } catch(Exception e) {
                Logs.error('ContractEndDateAdapterTrigger','SBQQ__Subscription__c Trigger insert & update', e);
        }
    }
}
