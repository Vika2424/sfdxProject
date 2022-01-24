/**
 * Created by vpelykh on 19.01.2022.
 */

public with sharing class OpportunityProductsSelector {

    public static Id getAccountId(String name) {
        return [SELECT Id
                FROM Account
                WHERE Name = :name
                LIMIT 1
        ].Id;
    }

    public static Opportunity getOpportunityInformation(Id opportunityId) {
        return [SELECT Id, Contact__c, Pricebook2Id,
                (SELECT Id, Product2.Name, Product2.Total_Amount__c, Quantity
                FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Id = :opportunityId
        ];
    }

    public static List<OpportunityLineItem> selectOppProducts(List<Id> oppProductsIds) {
        return [
                SELECT Id,
                        Product2.Name,
                        Product2Id,
                        PricebookEntryId,
                        Quantity,
                        UnitPrice
                FROM OpportunityLineItem
                WHERE Id IN :oppProductsIds
        ];
    }
}