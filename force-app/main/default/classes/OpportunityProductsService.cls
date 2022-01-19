/**
 * Created by vpelykh on 19.01.2022.
 */

public with sharing class OpportunityProductsService {

    public static Order createOrder(Date startDate, Id contactId) {
        Id accountId = OpportunityProductsSelector.getAccountId('Account without contacts');
        Order order = new Order(
                AccountId = accountId,
                EffectiveDate = startDate,
                CustomerAuthorizedById = contactId
        );
        insert order;
        return order;
    }


}