/**
 * Created by vpelykh on 24.01.2022.
 */

@IsTest
private class OpportunityProductsTest {

    @TestSetup
    static void setup() {
        TestDataFactory.insertAccount('Account without contacts');
        List<Contact> contacts = TestDataFactory.insertContacts(10);

        Pricebook2 pricebook2 = TestDataFactory.insertPricebook('Test Pricebook', true);
        Opportunity opportunity = TestDataFactory.insertOpportunity('Test', 'Prospecting', Date.today().addDays(10), contacts[0].Id);
        List<PricebookEntry> pricebookEntries = TestDataFactory.insertProductsAndPriceEntry(10, 100, 12, pricebook2.Id);
        TestDataFactory.insertOpportunityLineItems(pricebookEntries, opportunity.Id, 8);
    }

    @IsTest
    static void createOrderWithoutProducts() {
        Opportunity opportunity = [SELECT Id,
                            Contact__c,
                            Pricebook2Id
                            FROM Opportunity
                            LIMIT 1
        ];

        Test.startTest();
        OpportunityProductsService.createOrder(Date.today().addDays(20), opportunity.Contact__c, opportunity.Pricebook2Id, opportunity.Id);
        Test.stopTest();

        List<Order> orders = [SELECT Id, EffectiveDate,
                             CustomerAuthorizedById,
                             Pricebook2Id,
                             OpportunityId
                             FROM Order
        ];
        System.assertEquals(1, orders.size());
        System.assertEquals(Date.today().addDays(20), orders[0].EffectiveDate);
        System.assertEquals(opportunity.Contact__c, orders[0].CustomerAuthorizedById);
        System.assertEquals(opportunity.Pricebook2Id, orders[0].Pricebook2Id);
        System.assertEquals(opportunity.Id, orders[0].OpportunityId);

    }

    @IsTest
    static void createOrderWithProducts() {
        Opportunity opportunity = [SELECT Id,
                                  Pricebook2Id,
                                  Contact__c,
                                  (SELECT Id FROM OpportunityLineItems)
                                  FROM Opportunity
                                  LIMIT 1
        ];
        List<Id> opportunityLineItemIds = new List<Id>();
        for (OpportunityLineItem opportunityLineItem : opportunity.OpportunityLineItems){
            opportunityLineItemIds.add(opportunityLineItem.Id);
        }

        Test.startTest();
        Order order = OpportunityProductsService.createOrder(Date.today().addDays(20), opportunity.Contact__c, opportunity.Pricebook2Id, opportunity.Id);
        OpportunityProductsService.createOrderProducts(order.Id, opportunityLineItemIds);
        Test.stopTest();

        Order resultOrder = [SELECT Id,
                             (SELECT Id FROM OrderItems)
                             FROM Order
                             WHERE Id = :order.Id
        ];
        System.assertEquals(10, resultOrder.OrderItems.size());
    }

    @IsTest
    static void getCreatedOpportunity() {
        Opportunity opportunity = [SELECT Id,
                                Contact__c,
                                Pricebook2Id,
                                (SELECT Id FROM OpportunityLineItems)
                                FROM Opportunity
                                LIMIT 1
        ];
        Test.startTest();
        Opportunity resultOpportunity = OpportunityProductsController.getOpportunity(opportunity.Id);
        Test.stopTest();

        System.assertEquals(opportunity.Contact__c, resultOpportunity.Contact__c);
        System.assertEquals(opportunity.Pricebook2Id, resultOpportunity.Pricebook2Id);
        System.assertEquals(opportunity.OpportunityLineItems.size(), resultOpportunity.OpportunityLineItems.size());
    }

    @IsTest
    static void createOrderWithProductsTogether() {
        Opportunity opportunity = [SELECT Id,
                                    Contact__c,
                                    Pricebook2Id,
                                    (SELECT Id, Quantity, Product2Id FROM OpportunityLineItems LIMIT 3)
                                    FROM Opportunity
                                    LIMIT 1
        ];
        List<Id> opportunityLineItemIds = new List<Id>();
        for (OpportunityLineItem opportunityLineItem : opportunity.OpportunityLineItems) {
            opportunityLineItemIds.add(opportunityLineItem.Id);
        }

        Test.startTest();
        OpportunityProductsController.createOrderWithOrderProducts(String.valueOf(Date.today().addDays(15)), opportunityLineItemIds, opportunity);
        Test.stopTest();

        Order order = [SELECT Id,
                        CustomerAuthorizedById,
                        Pricebook2Id,
                        EffectiveDate,
                        OpportunityId,
                        (SELECT Id, Quantity, Product2Id FROM OrderItems)
                        FROM Order
        ];
        System.assertEquals(Date.today().addDays(15), order.EffectiveDate);
        System.assertEquals(opportunity.Contact__c, order.CustomerAuthorizedById);
        System.assertEquals(opportunity.Pricebook2Id, order.Pricebook2Id);
        System.assertEquals(opportunity.Id, order.OpportunityId);
        System.assertEquals(opportunityLineItemIds.size(), order.OrderItems.size());

        Boolean productsAreCorrect = false;
        for (OrderItem orderItem : order.OrderItems) {
            if (orderItem.Product2Id == opportunity.OpportunityLineItems[0].Product2Id) {
                System.assertEquals(opportunity.OpportunityLineItems[0].Quantity, orderItem.Quantity);
                productsAreCorrect = true;
                break;
            }
        }
        System.assert(productsAreCorrect);
    }

    @IsTest
    static void createOrderWithoutProductsTogether() {
        Id contactId = [SELECT Id
                        FROM Contact
                        LIMIT 1
        ].Id;
        Opportunity opportunity = TestDataFactory.insertOpportunity('Test 2', 'Prospecting', Date.today().addDays(3), contactId);

        Test.startTest();
        OpportunityProductsController.createOrderWithOrderProducts(String.valueOf(Date.today().addDays(15)), null, opportunity);
        Test.stopTest();

        Order order = [SELECT Id,
                CustomerAuthorizedById,
                Pricebook2Id,
                EffectiveDate,
                OpportunityId,
        (SELECT Id, Quantity, Product2Id FROM OrderItems)
        FROM Order
        ];
        System.assertEquals(Date.today().addDays(15), order.EffectiveDate);
        System.assertEquals(opportunity.Contact__c, order.CustomerAuthorizedById);
        System.assertEquals(opportunity.Pricebook2Id, order.Pricebook2Id);
        System.assertEquals(opportunity.Id, order.OpportunityId);
        System.assertEquals(0, order.OrderItems.size());

    }
}