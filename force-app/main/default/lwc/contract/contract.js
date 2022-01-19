/**
 * Created by Админ on 09.01.2022.
 */

import {LightningElement, api} from 'lwc';
import {NavigationMixin} from "lightning/navigation";

export default class Contract extends NavigationMixin(LightningElement) {
    @api record;

    viewRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "Contract",
                "actionName": "view"
            },
        });
    }

    actClick() {
        const event = new CustomEvent('activateclick', {
            detail: this.record.Id
        });
        this.dispatchEvent(event);
    }

}