/**
 * Created by vpelykh on 18.01.2022.
 */

public with sharing class OrderMethods {

    @AuraEnabled(Cacheable=true)
    public static List<Order> getDraftOrders() {
        return OrderMethodsService.getDraftOrdersOfCurrentUser();
    }
}