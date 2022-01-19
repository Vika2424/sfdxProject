/**
 * Created by Админ on 05.01.2022.
 */

import {LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import COMPANY_NAME_FIELD from '@salesforce/schema/User.CompanyName';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/User.LastName';
import TITLE_FIELD from '@salesforce/schema/User.Title';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CITY_FIELD from '@salesforce/schema/User.City';

export default class UserForm extends LightningElement {
    userId = USER_ID;

    fields = [FIRST_NAME_FIELD, LAST_NAME_FIELD, COMPANY_NAME_FIELD, TITLE_FIELD, PHONE_FIELD, CITY_FIELD];
    handleSuccess() {
        const toastEvent = new ShowToastEvent({
            title: "User information successfully updated",
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }
}