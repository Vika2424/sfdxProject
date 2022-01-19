/**
 * Created by vpelykh on 18.01.2022.
 */

public with sharing class OrderMethodsSelector {

    public static List<Order> selectDraftOrdersOfCurrentUser(Id currentUser) {

        return [SELECT Id, Status, OrderNumber, EffectiveDate,
                (SELECT Id FROM OrderItems)
                FROM Order
                WHERE Status = 'Draft'
                AND OwnerId = :currentUser];
    }
}