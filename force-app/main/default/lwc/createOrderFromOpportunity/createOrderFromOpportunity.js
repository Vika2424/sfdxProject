/**
 * Created by Админ on 18.01.2022.
 */

import {LightningElement, api, wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import {NavigationMixin} from "lightning/navigation";
import getOpportunityProductsForOpportunity from '@salesforce/apex/OpportunityProductsController.getOpportunityProductsForOpportunity';
import createOrderWithOrderProducts from '@salesforce/apex/OpportunityProductsController.createOrderWithOrderProducts';
import getOpportunity from '@salesforce/apex/OpportunityProductsController.getOpportunity';

export default class CreateOrderFromOpportunity extends NavigationMixin(LightningElement) {
    date;
    error;
    opportunityProducts;
    value = [];
    opportunity;
    orderId;

    _recordId;

    get isNotRecordUndefined() {
        // console.log('RecordId: ' + this.recordId);
        return this.recordId !== undefined;
    }


    @api set recordId(value) {
        this._recordId = value;
        // console.log('this._recordId: ' + value);
    }

    get recordId() {
        // console.log('get recordId')
        return this._recordId;
    }

    @wire(getOpportunity, {opportunityId: '$recordId'})
    wireGetOpportunity({data, error}) {
        if (data) {
            this.opportunity = data;
            this.error = undefined;
        } else if (error) {
            this.opportunity = undefined;
            this.error = error;
        }
    }

    @wire(getOpportunityProductsForOpportunity, {opportunityId: '$recordId'})
    wireGetOpportunityProduct({data, error}) {
        // console.log('recordId ' + this.recordId);
        if (data) {
            // console.log('here');
            // console.log(JSON.stringify(data));

            this.opportunityProducts = data;
            this.error = undefined;
        } else if (error) {
            this.opportunityProducts = undefined;
            this.error = error;
        }
    }

    get availableOpportunityProducts() {
        // console.log('recordId in availableOpportunityProducts ' + this.recordId);
        // console.log('currentProducts ' + JSON.stringify(this.opportunityProducts));
        return this.generateCheckboxGroup(this.opportunityProducts);
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleDateChange(event) {
        this.date = event.target.value;

    }

    saveAction() {
        console.log('In save: ');
        console.log(this.date);
        this.orderId = createOrderWithOrderProducts({startDare: this.date, productIds: this.value, contactId: this.opportunity.Contact__c})
            .then(() => {
                console.log('OrderId: ' + this.orderId);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        "recordId": this.orderId,
                        "objectApiName": "Order",
                        "actionName": "view"
                    },
                });
            })
            .catch((error) =>{
                console.log(JSON.parse(JSON.stringify(error)));
            })


    }

    generateCheckboxGroup(opportunityItems) {
        const options = [];
        // console.log('opportunityItems');
        // console.log(opportunityItems);
        if (opportunityItems) {
            for (const opportunityItem of opportunityItems) {
                if (opportunityItem.Quantity < opportunityItem.Product2.Total_Amount__c) {
                    options.push({label: opportunityItem.Product2.Name, value: opportunityItem.Product2.Id});
                }
            }
            console.log('values:');
            console.log(this.value);
            return options;
        }
    }
}