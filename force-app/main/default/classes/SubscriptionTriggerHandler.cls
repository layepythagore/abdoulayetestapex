public with sharing class SubscriptionTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public SubscriptionTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(List<SBQQ__Subscription__c> subs)
    {
        SubscriptionAction.updateContracteEndDate(subs);
    }
    public void OnAfterUpdate(List<SBQQ__Subscription__c> subs)
    {
        SubscriptionAction.updateContracteEndDate(subs);
    }

    public boolean IsTriggerContext
    {
        get{ return m_isExecuting;}
    }
}
