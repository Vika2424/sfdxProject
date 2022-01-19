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
            orderItems.add(new OrderItem(UnitPrice = 200, PricebookEntryId = pricebookEntry.Id, OrderId = order.Id, Quantity = quantity));
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
}