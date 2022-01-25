/**
 * Created by vpelykh on 24.01.2022.
 */

@IsTest
private class OrderMethodsTest {
    @TestSetup
    static void setup() {
        Id accountId = TestDataFactory.insertAccount('Account without contacts').Id;
        List<Contact> contacts = TestDataFactory.insertContacts(1);

        Pricebook2 pricebook2 = TestDataFactory.insertPricebook('Test Pricebook', true);
        List<Order> orders = TestDataFactory.insertOrders(5, Date.today(), accountId, 'Draft', contacts[0].Id, pricebook2.Id);
        List<PricebookEntry> pricebookEntries = TestDataFactory.insertProductsAndPriceEntry(3, 100, 12, pricebook2.Id);
        TestDataFactory.insertOrderItems(pricebookEntries, orders[0], 4);
        TestDataFactory.insertOrderItems(pricebookEntries, orders[1], 5);
    }

    @IsTest
    static void getOrderAvailableForActivation() {
        Test.startTest();
        List<Order> orders = OrderMethods.getDraftOrders();
        Test.stopTest();


        System.assertEquals(2, orders.size());
        System.assertEquals(3, orders[0].OrderItems.size());
    }
}