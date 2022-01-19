/**
 * Created by Админ on 04.01.2022.
 */

trigger OrderItemTrigger on OrderItem (before insert, before update, before delete ) {

    OrderItemTriggerHandler.handle(Trigger.new, Trigger.old, Trigger.oldMap, Trigger.operationType);
}