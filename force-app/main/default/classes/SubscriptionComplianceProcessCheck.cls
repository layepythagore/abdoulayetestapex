global with sharing class SubscriptionComplianceProcessCheck implements Database.Batchable<sObject> {
    // on déclare parce que de nouveaux processus de conformité seront ajoutés ultérieurement.v
    private static  List<String> complianceChecks = new List<String>{'Conformité Pub', 'Conformité Immo neuf'};

    /**
        Cette classe a été créé pour répondre au besoin métier décrit sur la question. En fait la solution dépend de quel
        moment voudrait-on verifié la conformitté des souscriptions:
        1 - si c'est à la création d'une souscription alors vaudrait mieux aller vers un trigger.
        2 - si on le plannifie pour un moment bien déterminé il serait mieux d'utliser un batch que nous allons essayer
         d'écrire sur les lignes suivantes
     */
    global List<SBQQ__Subscription__c> start(Database.BatchableContext cnx) {        
        return Database.getQueryLocator('SELECT Id, ComplianceProcess__c, EffectiveEndDate__c, MissingInformations__c' + 
                'FROM SBQQ__Subscription__c WHERE ComplianceProcess__c IN :complianceChecks');
    }

    global void execute(Database.BatchableContext cnx, List<SBQQ__Subscription__c> scope) {
        Date today = Date.today();
        for (SBQQ__Subscription__c sub : scope) {
            Map<String, Object> mapSub = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sub));
            if (mapSub.get(String.valueOf(SBQQ__Subscription__c.EffectiveEndDate__c)) != null) {
                if (sub.EffectiveEndDate__c > today) {
                    sub.Souscription_Conforme__c = true;
                } else {
                    // MissingInformations__c prend la valeur du processus de conformité
                    sub.MissingInformations__c = sub.ComplianceProcess__c;
                }
            }
        }
        if (scope != null && !scope.isEmpty()) {
            update scope;
        }        
    }

    global void finish(Database.BatchableContext cnx){}
}
