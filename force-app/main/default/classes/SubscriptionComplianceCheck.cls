global class SubscriptionComplianceCheck implements Database.Batchable<sObject> {
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    
    /**
     * modified by Abdoulaye
    */
    global List<SBQQ__Subscription__c> start(Database.BatchableContext cnx) { 
        // Du fait qu'on ne processe pas de donner, il serait mieux d'utiliser queryLocator pour avoir plus de donner sans heurter les goverments limits
        Boolean nonConforme = false;
        return Database.getQueryLocator(
            'SELECT Id, CompanyAddressCity__c, OrderNumber__c, CompanyAddressCountry__c, CompanyPhone__c, ContactGender__c, ContactLastName__c,' + 
                'ContactFirstName__c, Companyindustry__c, CompanyName__c, PrintVolume__c, BroadcastSoftware__c, PromoterDescription__c, SBQQ__RequiredById__c,'+
                'FlowType__c, BroadcastPartner__c, PostalCode__c, Souscription_Conforme__c, ComplianceProcess__c, Status__c, AccessStoreState__c, '+
                'ProductWorkflow__c, AccessUserId__c, KilometerRadius__c, AccessStoreId__c, CompanyAddressStreet__c, CompanyAddressZipcode__c, LeadPhone__c,'+
                'ContractEmail__c, CompanySegment__c, CompanySiret__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS'+
                'AND Souscription_Conforme__c =:nonConforme'
        );
    }
    
    global void execute(Database.BatchableContext cnx, List<SBQQ__Subscription__c> scope) {
        try {
            // variable utilisé pour stocker les SBQQ__Subscription__c et les mettre à jour
            List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
            Set<String> parentIds = new Set<String>();

            for(SBQQ__Subscription__c sub : scope) {
               if (sub.ComplianceProcess__c == IMMO_NEUF) {
                    SBQQ__Subscription__c subImmo = setConformiteImmoNeuf(sub);
                    if (subImmo != null) {
                        subs.add(subImmo);                        
                        // on test si le field a été retourné par SOQL d'abord parce s'il est null il ne sera pas retourné et on aura une exception
                        Map<String, Object> mapSub = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sub));
                        if (mapSub.get(String.valueOf(SBQQ__Subscription__c.SBQQ__RequiredById__c)) != null) {
                            parentIds.add(sub.SBQQ__RequiredById__c);       
                        }
                    }
                }
            }
            Set<SBQQ__Subscription__c> parentSubs = setParentConforme(parentIds);
            if (parentSubs != null && !parentSubs.isEmpty()) {
                for (SBQQ__Subscription__c pSub : parentSubs) {
                    subs.add(pSub);
                }
            }
            update subs;            

        } catch(Exception e) {
            Logs.error('SubscriptionComplianceCheck','Batch Compliance Check', e);
        }
    }
    
    global void finish(Database.BatchableContext cnx) {
    }
    
    /*
    private SBQQ__Subscription__c setConformiteImmoNeuf(SBQQ__Subscription__c sub) {
        if(sub.PromoterDescription__c != null && sub.FlowType__c != null && sub.ProductWorkflow__c != null
          && sub.ContractEmail__c != null && sub.CompanySiret__c != null && sub.CompanyName__c != null
          && sub.CompanyAddressStreet__c != null && sub.CompanyAddressZipcode__c != null && sub.CompanyAddressCity__c != null
          && sub.CompanyPhone__c != null && sub.ContactGender__c != null && sub.ContactFirstName__c != null 
          && sub.ContactLastName__c != null && sub.LeadPhone__c != null) {
            sub.Souscription_Conforme__c = true;
            update sub;
            return sub;
        }
        return null;
    }*/

    /**
     * modified by Abdoulaye
    */
    private SBQQ__Subscription__c setConformiteImmoNeuf(SBQQ__Subscription__c sub) {
        if(sub.PromoterDescription__c != null && sub.FlowType__c != null && sub.ProductWorkflow__c != null
          && sub.ContractEmail__c != null && sub.CompanySiret__c != null && sub.CompanyName__c != null
          && sub.CompanyAddressStreet__c != null && sub.CompanyAddressZipcode__c != null && sub.CompanyAddressCity__c != null
          && sub.CompanyPhone__c != null && sub.ContactGender__c != null && sub.ContactFirstName__c != null 
          && sub.ContactLastName__c != null && sub.LeadPhone__c != null) {
            sub.Souscription_Conforme__c = true;
            //update sub;
            // Comme la fonction setConformiteImmoNeuf est appelée dans un boucle il serait de ne pas faire une opération DML
            // on peut juste retourner le sub et faire l'operation dml ailleur
            return sub;
        }
        return null;
    }
    
    /*
    private SBQQ__Subscription__c setParentConforme(String parentId) {
        SBQQ__Subscription__c[] parentSub = [SELECT Id, Souscription_Conforme__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id = :parentId];
        if (parentSub != null && !parentSub.isEmpty()) {
            parentSub[0].Souscription_Conforme__c = true;
            return parentSub[0];
            //UPDATE parentSub[0];
        }
        return null;
    }
    */

    private Set<SBQQ__Subscription__c> setParentConforme(Set<String> parentIds) {
        /*SBQQ__Subscription__c[] parentSub = [SELECT Id, Souscription_Conforme__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id = :parentId]; */

        Set<SBQQ__Subscription__c> parentSubs = new Set<SBQQ__Subscription__c>([SELECT Id, Souscription_Conforme__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id IN :parentIds]);

        if (parentSubs != null && !parentSubs.isEmpty()) {
            for (Souscription_Conforme__c parentSub : parentSubs) {
                parentSub.Souscription_Conforme__c = true;
            }
            return parentSubs;
        }
        return null;
    }
}