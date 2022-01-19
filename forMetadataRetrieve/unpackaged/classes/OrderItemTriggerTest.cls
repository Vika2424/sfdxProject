/**
 * Created by Админ on 04.01.2022.
 */

@IsTest
private class OrderItemTriggerTest {
    private static final String errorFor0 = 'This product is out of stock';
    private static final String errorFor1 = 'There is only one item in stock';

    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Pricebook2 pricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert pricebook;


        Order order = new Order(AccountId=account.Id, EffectiveDate = Date.today().addDays(5), Status='Draft', Pricebook2Id = pricebook.Id);
        insert order;

        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 10; i++) {
            products.add(new Product2(Name = 'Test Product ' + i, Total_Amount__c = 30));
        }
        insert products;

        Id standardPricebook = Test.getStandardPricebookId();
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            standardPricebookEntries.add(new PricebookEntry(UnitPrice = 200, Pricebook2Id = standardPricebook, Product2Id = product.Id));
        }
        insert standardPricebookEntries;

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(UnitPrice = 200, Pricebook2Id = pricebook.Id, Product2Id = product.Id));
        }
        insert pricebookEntries;
    }
    @IsTest
    static void testInsertManyOrderItemsForDifferentProducts() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];

        List<OrderItem> orderItems = new List<OrderItem>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            orderItems.add(new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = 5));
        }

        Test.startTest();
        insert orderItems;
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Product2 product2 : product2s) {
            System.assertEquals(25, product2.Total_Amount__c);
        }
    }

    @IsTest
    static void testInsertManyOrderItemsForDifferentProductsWithError() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];

        List<OrderItem> orderItems = new List<OrderItem>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            orderItems.add(new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = 35));
        }

        Test.startTest();
        Database.SaveResult[] results = Database.insert(orderItems, false);
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Integer i = 0; i < results.size(); i++) {
            System.assertEquals('There are only 30 in stock', results[i].getErrors()[0].message);
            System.assertEquals(30, product2s[i].Total_Amount__c);
        }
    }

    @IsTest
    static void testInsertWithErrorsWith1() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Product2 product = [SELECT Id, Total_Amount__c FROM Product2 LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook' AND Product2.Id =:product.Id];

        product.Total_Amount__c = 1;
        List<OrderItem> orderItems = new List<OrderItem>{new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = 30)};

        Test.startTest();
        update product;
        Database.SaveResult[] results = Database.insert(orderItems, false);
        Test.stopTest();

        Product2 productResult = [SELECT Id, Total_Amount__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(errorFor1, results[0].getErrors()[0].message);
        System.assertEquals(1, productResult.Total_Amount__c);

    }

    @IsTest
    static void testInsertWithErrorsWith0() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Product2 product = [SELECT Id, Total_Amount__c FROM Product2 LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook' AND Product2.Id =:product.Id];

        product.Total_Amount__c = 0;
        List<OrderItem> orderItems = new List<OrderItem>{new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = 30)};

        Test.startTest();
        update product;
        Database.SaveResult[] results = Database.insert(orderItems, false);
        Test.stopTest();

        Product2 productResult = [SELECT Id, Total_Amount__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(errorFor0, results[0].getErrors()[0].message);
        System.assertEquals(0, productResult.Total_Amount__c);
    }

    @IsTest
    static void testInsertConsistentItems() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Product2 product = [SELECT Id, Total_Amount__c FROM Product2 LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook' AND Product2.Id =:product.Id];

        Test.startTest();
        insert new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = 5);
        insert new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = 7);
        Test.stopTest();

        Product2 productResult = [SELECT Id, Total_Amount__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(18, productResult.Total_Amount__c);
    }

    @IsTest
    static void testPositiveUpdateManyOrderItemsForDifferentProducts() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(pricebookEntries, order, 3);
        List<Product2> products = [SELECT Id, Total_Amount__c FROM Product2];

        for (Integer i = 0; i < pricebookEntries.size(); i++) {
            System.assertEquals(27, products[i].Total_Amount__c);
            orderItems[i].Quantity = 1;
        }
        Test.startTest();
        update orderItems;
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Product2 product2 : product2s) {
            System.assertEquals(29, product2.Total_Amount__c);
        }
    }

    @IsTest
    static void testNegativeUpdateManyOrderItemsForDifferentProducts() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(pricebookEntries, order, 3);
        List<Product2> products = [SELECT Id, Total_Amount__c FROM Product2];

        for (Integer i = 0; i < pricebookEntries.size(); i++) {
            System.assertEquals(27, products[i].Total_Amount__c);
            orderItems[i].Quantity = 7;
        }
        Test.startTest();
        update orderItems;
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Product2 product2 : product2s) {
            System.assertEquals(23, product2.Total_Amount__c);
        }
    }

    @IsTest
    static void testUpdateManyOrderItemsForDifferentProductsWithError() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(pricebookEntries, order, 3);
        List<Product2> products = [SELECT Id, Total_Amount__c FROM Product2];

        for (Integer i = 0; i < pricebookEntries.size(); i++) {
            System.assertEquals(27, products[i].Total_Amount__c);
            orderItems[i].Quantity = 31;
        }
        Test.startTest();
        Database.SaveResult[] results = Database.update(orderItems, false);
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Integer i = 0; i < results.size(); i++) {
            System.assertEquals('There are only 27 in stock', results[i].getErrors()[0].message);
            System.assertEquals(27, product2s[i].Total_Amount__c);
        }
    }

    @IsTest
    static void testUpdateManyOrderItemsForDifferentProductsWithError1() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(pricebookEntries, order, 29);
        List<Product2> products = [SELECT Id, Total_Amount__c FROM Product2];

        for (Integer i = 0; i < pricebookEntries.size(); i++) {
            System.assertEquals(1, products[i].Total_Amount__c);
            orderItems[i].Quantity = 33;
        }
        Test.startTest();
        Database.SaveResult[] results = Database.update(orderItems, false);
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Integer i = 0; i < results.size(); i++) {
            System.assertEquals(errorFor1, results[i].getErrors()[0].message);
            System.assertEquals(1, product2s[i].Total_Amount__c);
        }
    }

    @IsTest
    static void testUpdateManyOrderItemsForDifferentProductsWithError0() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(pricebookEntries, order, 30);
        List<Product2> products = [SELECT Id, Total_Amount__c FROM Product2];

        for (Integer i = 0; i < pricebookEntries.size(); i++) {
            System.assertEquals(0, products[i].Total_Amount__c);
            orderItems[i].Quantity = 33;
        }
        Test.startTest();
        Database.SaveResult[] results = Database.update(orderItems, false);
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Integer i = 0; i < results.size(); i++) {
            System.assertEquals(errorFor0, results[i].getErrors()[0].message);
            System.assertEquals(0, product2s[i].Total_Amount__c);
        }
    }

    @IsTest
    static void testDeleteOrderItems() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Test Pricebook'];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(pricebookEntries, order, 5);

        Test.startTest();
        delete orderItems;
        Test.stopTest();

        List<Product2> product2s = [SELECT Id, Total_Amount__c FROM Product2];
        for (Product2 product2 : product2s) {
            System.assertEquals(30, product2.Total_Amount__c);
        }
    }
}