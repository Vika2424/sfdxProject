/**
 * Created by Админ on 02.01.2022.
 */
@IsTest
public class TestDataFactory {

    public static List<Event> getEvents(Integer num, Id owner, Integer interval, Datetime start, Integer duration) {
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < num; i++) {
            events.add(new Event(OwnerId = owner, StartDateTime = start.addMinutes(i * interval), EndDateTime = start.addMinutes(duration + i * interval)));
        }
        return events;
    }

    public static Event insertEvent(Id owner, Datetime start, Integer duration) {
        Event event = new Event(OwnerId = owner, StartDateTime = start, EndDateTime = start.addMinutes(duration));
        insert event;
        return event;
    }

    public static List<Event> insertEvents(Integer num, Id owner, Integer interval, Datetime start, Integer duration) {
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < num; i++) {
            events.add(new Event(OwnerId = owner, StartDateTime = start.addMinutes(i * interval), EndDateTime = start.addMinutes(duration + i * interval)));
        }
        insert events;
        return events;
    }

    public static List<OrderItem> insertOrderItems(List<PricebookEntry> pricebookEntries, Order order, Integer quantity) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            orderItems.add(new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = quantity, Product2Id = pricebookEntry.Product2Id));
        }
        insert orderItems;
        return orderItems;
    }

    public static List<Event> getEventsForDifferentUsers(List<User> users, Datetime start, Integer duration) {
        List<Event> events = new List<Event>();
        for (User user : users) {
            events.add(new Event(OwnerId = user.Id, StartDateTime = start, EndDateTime = start.addMinutes(duration)));
        }
        return events;
    }

    public static List<Contact> insertContacts(Integer num) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < num; i++) {
            contacts.add(new Contact(LastName = 'Test ' + i));
        }
        insert contacts;
        return contacts;
    }

    public static Pricebook2 insertPricebook(String name, Boolean active) {
        Pricebook2 pricebook = new Pricebook2(Name = name, IsActive = active);
        insert pricebook;
        return pricebook;
    }

    public static Account insertAccount(String name) {
        Account account = new Account(Name = name);
        insert account;
        return account;
    }

    public static Opportunity insertOpportunity(String name, String stage, Date closeDate, Id contactId) {
        Opportunity opportunity = new Opportunity(Name = name,
                                                  StageName = stage,
                                                  CloseDate = closeDate,
                                                  Contact__c = contactId
                );
        insert opportunity;
        return opportunity;
    }

    public static List<PricebookEntry> insertProductsAndPriceEntry(Integer num, Integer unitPrice, Integer amount, Id pricebookId) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < num; i++) {
            products.add(new Product2(Name = 'Test Product ' + i, Total_Amount__c = amount));
        }
        insert products;

        Id standardPricebook = Test.getStandardPricebookId();
        List<PricebookEntry> pricebookEntries = generatePricebookEntry(products, standardPricebook, unitPrice);
        List<PricebookEntry> entriesForCustomPricebook = generatePricebookEntry(products, pricebookId, unitPrice);
        pricebookEntries.addAll(entriesForCustomPricebook);

        insert pricebookEntries;
        return entriesForCustomPricebook;

    }

    public static List<PricebookEntry> generatePricebookEntry(List<Product2> products, Id pricebookId, Integer unitPrice) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(
                    UnitPrice = unitPrice,
                    Pricebook2Id = pricebookId,
                    Product2Id = product.Id,
                    IsActive = true
            ));
        }
        return pricebookEntries;
    }

    public static List<OpportunityLineItem> insertOpportunityLineItems(List<PricebookEntry> pricebookEntries, Id opportunityId, Integer quantity) {
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            opportunityLineItems.add(new OpportunityLineItem(UnitPrice = 200,
                                                            PricebookEntryId = pricebookEntry.Id,
                                                            OpportunityId = opportunityId,
                                                            Quantity = quantity
            ));
        }
        insert opportunityLineItems;
        return opportunityLineItems;
    }

    public static List<Order> generateOrders(Integer num, Date startDate, Id accountId, String status, Id contactId) {
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < num; i++) {
            orders.add(new Order(EffectiveDate = startDate,
                    AccountId = accountId,
                    Status = status,
                    CustomerAuthorizedById = contactId
            ));
        }
        return orders;
    }
}