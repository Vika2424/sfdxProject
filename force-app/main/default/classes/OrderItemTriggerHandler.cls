/**
 * Created by Админ on 04.01.2022.
 */

public with sharing class OrderItemTriggerHandler {

    public static void handle(List<OrderItem> newRecords, List<OrderItem> oldRecords, Map<Id, OrderItem> oldMap, System.TriggerOperation triggerOperation) {

        switch on triggerOperation {
            when BEFORE_INSERT {
                Map<Id, Product2> mapProducts = getMapProducts(newRecords);
                Decimal remainingQuantity, amount;
                String error;

                for (OrderItem newRecord : newRecords) {
                    amount = mapProducts.get(newRecord.Product2Id).Total_Amount__c;
                    remainingQuantity = amount - newRecord.Quantity;
                    if (remainingQuantity >= 0) {
                        mapProducts.get(newRecord.Product2Id).Total_Amount__c = remainingQuantity;
                    }
                    else {
                        error = generateError(amount.intValue());
                        newRecord.addError(error);
                    }
                }
                update mapProducts.values();
            }

            when BEFORE_UPDATE {
                Map<Id, Product2> mapProducts = getMapProducts(newRecords);
                Decimal remainingQuantity, amount;
                String error;

                for (OrderItem newRecord : newRecords) {
                    if (newRecord.Quantity != oldMap.get(newRecord.Id).Quantity) {
                        amount = mapProducts.get(newRecord.Product2Id).Total_Amount__c;
                        remainingQuantity = amount - (newRecord.Quantity - oldMap.get(newRecord.Id).Quantity);

                        if (remainingQuantity >= 0) {
                            mapProducts.get(newRecord.Product2Id).Total_Amount__c = remainingQuantity;
                        } else {
                            error = generateError(amount.intValue());
                            newRecord.addError(error);
                        }
                    }
                }
                update mapProducts.values();
            }

            when BEFORE_DELETE {
                Map<Id, Product2> mapProducts = getMapProducts(oldRecords);
                for (OrderItem oldRecord : oldRecords) {
                    mapProducts.get(oldRecord.Product2Id).Total_Amount__c += oldRecord.Quantity;
                }
                update mapProducts.values();
            }
        }
    }

    private static Map<Id, Product2> getMapProducts(List<OrderItem> orderItems) {
        Set<Id> productsId = new Set<Id>();
        for (OrderItem orderItem : orderItems) {
            productsId.add(orderItem.Product2Id);
        }
        return new Map<Id, Product2>([SELECT Id, Total_Amount__c FROM Product2]);
    }

    private static String generateError(Integer amount) {
        String error;
        switch on amount {
            when 0 {
                error = 'This product is out of stock';
            }
            when 1 {
                error = 'There is only one item in stock';
            }
            when else {
                error = 'There are only ' + amount + ' in stock';
            }
        }
        return error;
    }
}