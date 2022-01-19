/**
 * Created by Админ on 02.01.2022.
 */

@IsTest
private class EventTriggerTest {

    @TestSetup
    private static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> uu = new List<User>();
        String uid;

        for (Integer i = 0; i < 6; i++) {
            uid = 'standardUser' + i;
            User u = new User(Alias = 'std' + i, Email= uid + '@test.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/New_York', Username = uid + '@test.com' + i);
            uu.add(u);
        }
        insert(uu);
    }

    @IsTest
    static void testInsertEventsSameTime() {
        Event event = TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);
        List<Event> events = TestDataFactory.getEvents(1, UserInfo.getUserId(), 0, Datetime.now(), 60);

        Test.startTest();
        Database.SaveResult[] results = Database.insert(events, false);
        Test.stopTest();

        List<Event> events2 = [SELECT Id FROM Event];

        for (Database.SaveResult saveResult : results) {
            System.assert(!saveResult.isSuccess());
        }
        System.assertEquals(1, events2.size());
    }

    @IsTest
    static void testInsertEventDifferentTime() {

        List<Event> events = TestDataFactory.getEvents(8, UserInfo.getUserId(), 60, Datetime.now(), 60);

        Test.startTest();
        insert events;
        Test.stopTest();

        List<Event> events2 = [SELECT Id FROM Event];
        System.assertEquals(8, events2.size());
    }

    @IsTest
    static void testWithEarlyCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(-20), EndDateTime = Datetime.now().addMinutes(30));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testWithLateCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(20), EndDateTime = Datetime.now().addMinutes(80));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testWithInsideCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(20), EndDateTime = Datetime.now().addMinutes(30));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testWithOutsideCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(-20), EndDateTime = Datetime.now().addMinutes(80));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testUpdateSingleEvent() {
        Datetime currentTime = Datetime.now();
        Event event = TestDataFactory.insertEvent(UserInfo.getUserId(), currentTime, 60);

        event.StartDateTime = event.StartDateTime.addMinutes(20);
        event.EndDateTime = event.EndDateTime.addMinutes(20);


        Test.startTest();
        update event;
        Test.stopTest();


        List<Event> events = [SELECT Id, StartDateTime, EndDateTime FROM Event];
        System.assertEquals(1, events.size());
        System.assertEquals(currentTime.addMinutes(20).minute(), events[0].StartDateTime.minute());
        System.assertEquals(currentTime.addMinutes(80).minute(), events[0].EndDateTime.minute());
    }

    @IsTest
    static void testUpdateWithCollision() {
        Datetime currentTime = Datetime.now();
        List<Event> events = TestDataFactory.insertEvents(4, UserInfo.getUserId(), 60, currentTime, 60);

        Id eventId = events[0].Id;
        events[0].StartDateTime = Datetime.now().addMinutes(20);
        events[0].EndDateTime = Datetime.now().addMinutes(80);

        Test.startTest();
        Database.SaveResult[] results = Database.update(events, false);
        Test.stopTest();

        System.assert(!results[0].isSuccess());
        List<Event> resultEvents = [SELECT Id FROM Event];
        System.assertEquals(4, resultEvents.size());

        Event event = [SELECT Id, StartDateTime, EndDateTime FROM Event WHERE Id = :eventId];
        System.assertEquals(currentTime, event.StartDateTime);
        System.assertEquals(currentTime.addMinutes(60), event.EndDateTime);
    }

    @IsTest
    static void testInsertForDifferentUsers() {
        List<User> users = [SELECT Id FROM User WHERE CreatedDate = TODAY];
        List<Event> events = TestDataFactory.getEventsForDifferentUsers(users, Datetime.now(), 60);

        Test.startTest();
        insert events;
        Test.stopTest();

        List<Event> resultEvents = [SELECT Id FROM Event];
        System.assertEquals(6, resultEvents.size());

    }

    @IsTest
    static void testInsertFor3DifferentUsers() {
        List<User> users = [SELECT Id FROM User WHERE CreatedDate = TODAY LIMIT 3];
        List<Event> events = TestDataFactory.getEventsForDifferentUsers(users, Datetime.now(), 60);

        Test.startTest();
        insert events;
        Test.stopTest();

        List<Event> resultEvents = [SELECT Id FROM Event];
        System.assertEquals(3, resultEvents.size());

    }

    @IsTest
    static void testInsertForDifferentUsersWithCollision() {
        List<User> users = [SELECT Id FROM User WHERE CreatedDate = TODAY];
        List<Event> events = TestDataFactory.getEventsForDifferentUsers(users, Datetime.now(), 60);
        List<Event> anotherEvents = TestDataFactory.getEventsForDifferentUsers(users, Datetime.now().addMinutes(20), 60);


        Test.startTest();
        insert events;
        Database.insert(anotherEvents, false);
        Test.stopTest();

        List<Event> resultEvents = [SELECT Id FROM Event];
        System.assertEquals(6, resultEvents.size());

    }
}