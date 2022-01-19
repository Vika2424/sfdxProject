/**
 * Created by Админ on 18.01.2022.
 */

import {LightningElement, api, wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getOpportunityProductsForOpportunity from '@salesforce/apex/OpportunityProductsController.getOpportunityProductsForOpportunity';

export default class CreateOrderFromOpportunity extends LightningElement {
    date;
    error;
    opportunityProducts;
    value = [];

    _recordId;

    get isNotRecordUndefined() {
        return this.recordId !== undefined;
    }

    @api set recordId(value) {
        this._recordId = value;
        console.log('value: ' + value);
    }

    get recordId() {
        return this._recordId;
    }

    @wire(getOpportunityProductsForOpportunity, {opportunityId: '$recordId'})
    wireGetOpportunity({data, error}) {
        console.log('recordId ' + this.recordId);
        if (data) {
            console.log('here');
            console.log(JSON.stringify(data));

            this.opportunityProducts = data;
            this.error = undefined;
        } else if (error) {
            this.opportunityProducts = undefined;
            this.error = error;
        }
    }

    get availableOpportunityProducts() {
        console.log('recordId in availableOpportunityProducts ' + this.recordId);
        console.log(JSON.stringify(this.opportunityProducts));
        return this.generateCheckboxGroupForOpportunityProducts(this.opportunityProducts);
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
        return null;
    }
    generateCheckboxGroupForOpportunityProducts(opportunityItems) {
        const options = [];
        for (const opportunityItem of opportunityItems) {
            console.log(opportunityItem);
            if (opportunityItem.Quantity > opportunityItem['Product2.Total_Amount__c']) {
                options.push({label : opportunityItem['Product2.Name'], value : opportunityItem.Id});
            }
        }
        return options;
    }
}