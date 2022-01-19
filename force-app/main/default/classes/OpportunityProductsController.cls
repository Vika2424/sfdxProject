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
        Order order = OpportunityProductsService.createOrder(startDate, contactId);
        return order.Id;
    }
}