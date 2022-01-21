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
    public static Id createOrderWithOrderProducts(String startDate, List<Id> oppProductIds, Id contactId, Id pricebookId) {
//        System.debug(contactId);
//        System.debug('startDate: ' + startDate);
        System.debug('oppProductIds: ');
        System.debug(oppProductIds);
        Order order = OpportunityProductsService.createOrder(Date.valueOf(startDate), contactId, pricebookId);
        if (oppProductIds != null && oppProductIds.size() > 0) {
            OpportunityProductsService.createOrderProducts(order.Id, oppProductIds);
        }
        return order.Id;
    }
}