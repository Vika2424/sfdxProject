/**
 * Created by Админ on 18.01.2022.
 */

public with sharing class OpportunityProductsMethods {

    @AuraEnabled(Cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProductsForOpportunity(Id opportunityId) {
        System.debug('1');
        return [SELECT Id, Product2.Name, Product2.Total_Amount__c, Quantity
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId];
    }
}