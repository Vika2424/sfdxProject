/**
 * Created by Админ on 18.01.2022.
 */
public with sharing class OpportunityProductsController {

    @AuraEnabled(Cacheable=true)
    public static Opportunity getOpportunity(Id opportunityId) {
        return OpportunityProductsSelector.getOpportunityInformation(opportunityId);
    }

    @AuraEnabled
    public static Id createOrderWithOrderProducts(String startDate, List<Id> oppProductIds, Opportunity opportunity) {
        Order order = OpportunityProductsService.createOrder(Date.valueOf(startDate), opportunity.Contact__c, opportunity.Pricebook2Id, opportunity.Id);
        if (oppProductIds != null && oppProductIds.size() > 0) {
            OpportunityProductsService.createOrderProducts(order.Id, oppProductIds);
        }
        return order.Id;
    }
}