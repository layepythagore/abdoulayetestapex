public with sharing class Subscription_DataFactory {
   
    public static SBQQ__Subscription__c createSubscription(Integer quantity, String status, String compliance, String productWorkflow, 
                                           Acces_beneficiaire__c benef, String flowType, 
                                           Account compte)) {        
    	
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Quantity__c = quantity, Status__c = status, ComplianceProcess__c = compliance, 
                                           ProductWorkflow__c = productWorkflow, BeneficiaryAccess__c = benef.Id, FlowType__c = flowType, 
                                           BeneficiaryAccount__c = compte.Id);
        return sub;
    }
}
