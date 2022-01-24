/**
 * Created by vpelykh on 19.01.2022.
 */

public with sharing class OpportunityProductsService {

    public static Order createOrder(Date startDate, Id contactId, Id pricebookId, Id opportunityId) {
        Id accountId = OpportunityProductsSelector.getAccountId('Account without contacts');
        Order order = new Order(
                AccountId = accountId,
                EffectiveDate = startDate,
                CustomerAuthorizedById = contactId,
                Status = 'Draft',
                Pricebook2Id = pricebookId,
                OpportunityId = opportunityId
        );
        insert order;
        return order;
    }

    public static void createOrderProducts(Id orderId, List<Id> oppProductIds) {

        List<OrderItem> orderProducts = new List<OrderItem>();
        List<OpportunityLineItem> oppProducts = OpportunityProductsSelector.selectOppProducts(oppProductIds);

        for (OpportunityLineItem oppProduct : oppProducts) {
            orderProducts.add(new OrderItem(Product2Id = oppProduct.Product2Id,
                                            OrderId = orderId,
                                            Quantity = oppProduct.Quantity,
                                            UnitPrice = oppProduct.UnitPrice,
                                            PricebookEntryId = oppProduct.PricebookEntryId
                    ));
        }
        insert orderProducts;
    }

}