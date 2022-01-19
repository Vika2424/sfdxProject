/**
 * Created by Админ on 09.01.2022.
 */

public without sharing class ContractMethods {
    @AuraEnabled(Cacheable=true)
    public static List<Contract> getDraftContracts() {
        Id currentUser = UserInfo.getUserId();
        return [SELECT Id, Status,StartDate, ContractNumber FROM Contract WHERE Status != 'Activated' AND OwnerId = :currentUser];
    }

}