/**
 * Created by vpelykh on 18.01.2022.
 */

import {LightningElement, wire} from 'lwc';
import {updateRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {refreshApex} from "@salesforce/apex";
import getDraftOrders from '@salesforce/apex/OrderMethods.getDraftOrders';
import ID_FIELD from '@salesforce/schema/Order.Id';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

export default class OrderList extends LightningElement {

    orderIdToUpdate;
    errors;
    orders;
    result;

    @wire(getDraftOrders)
    wireDraftOrders(result) {
        this.result = result;
        const {data, error} = result;
        if (data) {
            this.orders = data;
            this.errors = undefined;
        }
        else if (error) {
            this.orders = undefined;
            this.errors = error;
        }
    }

    get areOrdersEmpty() {
        return this.orders && this.orders.length > 0;
    }


    handleActivateClick(event) {
        this.orderIdToUpdate = event.detail;
        const recordInput = this.setFields(this.orderIdToUpdate);

        updateRecord(recordInput)
            .then(() => {
                this.selectToastEvent(true);
                return refreshApex(this.result);
            })
            .catch(error => {
                this.selectToastEvent(false, error);
            });
    }

    setFields(orderId) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = orderId;
        fields[STATUS_FIELD.fieldApiName] = 'Activated';
        return {fields};
    }

    selectToastEvent(isSuccess, error = undefined) {
        if (isSuccess) {
            return this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Order updated',
                    variant: 'success'
                })
            );
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}