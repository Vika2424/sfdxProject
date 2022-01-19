/**
 * Created by Админ on 29.12.2021.
 */

public with sharing class EventTriggerHandler {

    public static void handle(List<Event> newRecords, TriggerOperation triggerOperation) {

        Map<Id, List<Event>> mapEvents = getEventsOfUsers(newRecords);
        switch on triggerOperation {
            when BEFORE_INSERT {
                checkCollision(newRecords, mapEvents, true);
            }
            when BEFORE_UPDATE {
                checkCollision(newRecords, mapEvents, false);
            }
        }


    }

    private static Map<Id, List<Event>> getEventsOfUsers(List<Event> records) {
        Set<Id> users = new Set<Id>();
        for (Event record : records) {
            users.add(record.OwnerId);
        }
        Map<Id, List<Event>> mapEvents = new Map<Id, List<Event>>();
        List<Event> existingEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId FROM Event WHERE OwnerId IN :users];
        for (Id user : users) {
            mapEvents.put(user, new List<Event>());
        }
        for (Event existingEvent : existingEvents) {
            mapEvents.get(existingEvent.OwnerId).add(existingEvent);
        }
        return mapEvents;
    }

    private static void checkCollision(List<Event> newRecords, Map<Id, List<Event>> mapEvents, Boolean isInsertion) {
        for (Event newRecord : newRecords) {
            for (Event event : mapEvents.get(newRecord.OwnerId)) {
                if (areTwoEventsAtTheSameTime(newRecord, event) && (isInsertion || newRecord.Id != event.Id)) {
                    newRecord.addError('You have already had an event at this time');
                    break;
                }
            }
            mapEvents.get(newRecord.OwnerId).add(newRecord);
        }
    }

    private static Boolean areTwoEventsAtTheSameTime(Event first, Event event) {
        return (first.StartDateTime < event.StartDateTime && first.EndDateTime > event.StartDateTime) ||
                (first.EndDateTime > event.EndDateTime && first.StartDateTime < event.EndDateTime) ||
                (first.StartDateTime >= event.StartDateTime && first.EndDateTime <= event.EndDateTime);
    }
}