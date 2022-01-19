/**
 * Created by vpelykh on 18.01.2022.
 */

import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";

export default class Order extends NavigationMixin(LightningElement){

    @api order;

    viewRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "Order",
                "actionName": "view"
            },
        });
    }

    actClick() {
        const event = new CustomEvent('activateclick', {
            detail: this.order.Id
        });
        this.dispatchEvent(event);
    }
}