@isTest
private class SubscriptionComplianceCheckTest {

    private static final String BOUTIQUE = 'Conformité Boutique';
    private static final String CREDIT = 'Conformité Crédits';
    private static final String PARENT_BUNDLE = 'Conformité Parent Bundle';
    private static final String DIFFUSION_LBC = 'Conformité Diffusion LBC';
    private static final String DIFFUSION_AVAL = 'Conformité Diffusion AVAL';
    private static final String VISIBILITE_AVAL = 'Conformité Visibilité AVAL';
    private static final String PUB_LOCAL = 'Conformité Pub Local';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String CONFORME = 'Conforme';
    private static final String CREATED = 'Created';
    private static final String MODE = 'Fashion';
    private static final String SSII = 'JobServiceCompany';
    private static final String MME = 'Ms';
    private static final String CLOVER = 'CLOVER';
    private static final String MANUEL = 'Manuel';
    private static final String UBIFLOW = 'Ubiflow';
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';

    @TestSetup
    static void makeData(){
        Account compte = Account_DataFactory.createAccount('compte_1', '+33 6 00 00 00 00', '37915832200097');
        compte.Segmentation__c = SSII; 
        compte.CompanyIndustry__c = 'Beauty';
        compte.BillingCountry = 'France';
        compte.BillingCity = 'city';
        compte.BillingState = 'Île-de-France';
        compte.BillingPostalCode = '93600';
        compte.BillingStreet = 'street';
        UPDATE compte;

        Acces_beneficiaire__c benef1 = AccesBeneficiaire_DataFactory.createBeneficiaire('benef_1', compte.Id, 'test1@lbc.fr', CREATED);
        benef1.AccessUserId__c = 'OUAH';
        benef1.AccessStoreId__c = 'OUAH';
        benef1.AccessCategory__c = MODE;
        benef1.Segmentation__c = SSII;
        benef1.AccessSalutation__c = MME;
        benef1.AccessFirstname__c = 'Mimmi';
        benef1.AccessLastname__c = 'Montey';
        benef1.AccessAddressStreet__c = '11 nowhere';
        benef1.AccessCategory__c = 'RealEstate';
        benef1.AccessAddressCountry__c = 'FR';
        benef1.AccessAddressCity__c = 'city';
        benef1.AccessAddressZipcode__c = '22000';
        UPDATE benef1;

        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c parent = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, 
            ComplianceProcess__c = PARENT_BUNDLE);
        INSERT parent;

        SBQQ__Subscription__c immo = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = IMMO_NEUF, LeadPhone__c = '+33 6 00 00 00 66',
			ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, FlowType__c = MANUEL);
        INSERT immo;
        immo.PromoterDescription__c = 'UBIFLOW4';
        UPDATE immo;

        subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = BOUTIQUE, 
                                           ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, FlowType__c = 'Manuel', BeneficiaryAccount__c = compte.Id));
        
        subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = DIFFUSION_LBC, 
                                             ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id,
                                           BroadcastSoftware__c = CLOVER, BroadcastPartner__c = UBIFLOW, FlowType__c = 'Manuel'));
        subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = DIFFUSION_AVAL, FlowType__c = 'Manuel',
                                             ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id));
        subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = VISIBILITE_AVAL, FlowType__c = 'Manuel',
                                             ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, SBQQ__RequiredById__c = parent.Id, BeneficiaryAccount__c = compte.Id));
        subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = CREDIT, FlowType__c = 'Manuel',
                                             ProductWorkflow__c = 'yeah',BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id));
        subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = PUB_LOCAL, OrderNumber__c = '00215',
                                             PostalCode__c = 7500, KilometerRadius__c = '50', PrintVolume__c = 25));
        INSERT subs;
    }
    
    @isTest
    private static void testConformite() {
       
        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
        
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        System.assertNotEquals(0, [SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true].size());
        // vue qu'on a inséré 8 SBQQ__Subscription__c dont le statut est élément manquant et que par défaut le Souscription_Conforme__c est false,
        // apres exécution du batch on s'attend à avoir 8 subsciption dont Souscription_Conforme__c est true
        System.assertEquals(8, [SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true].size());
    }
}