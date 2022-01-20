/**
 * Created by Админ on 18.01.2022.
 */
public with sharing class OpportunityProductsController {

    @AuraEnabled(Cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProductsForOpportunity(Id opportunityId) {
        return OpportunityProductsSelector.selectOpportunityProductsForOpportunity(opportunityId);
    }

    @AuraEnabled(Cacheable=true)
    public static Opportunity getOpportunity(Id opportunityId) {
        return OpportunityProductsSelector.getOpportunityContact(opportunityId);
    }

    @AuraEnabled
    public static Id createOrderWithOrderProducts(Date startDate, List<Id> productIds, Id contactId) {
        System.debug(1);
        Order order = OpportunityProductsService.createOrder(startDate, contactId);
        System.debug(2);
        return (Id) order.Id;
    }
}