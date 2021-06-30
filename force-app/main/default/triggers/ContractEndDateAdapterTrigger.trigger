trigger ContractEndDateAdapterTrigger on SBQQ__Subscription__c (after insert, after update) {

    SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter)
        {
            handler.OnAfterInsert(trigger.New);
        }
    }
    else if (Trigger.isUpdate)
    {
        if(Trigger.isAfter)
        {
            handler.OnAfterUpdate(trigger.New);
        }
    }
}