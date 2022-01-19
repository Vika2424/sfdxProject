/**
 * Created by Админ on 29.12.2021.
 */

trigger EventTrigger on Event (before insert, before update) {

    EventTriggerHandler.handle(Trigger.new, Trigger.operationType);
}