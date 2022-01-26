/**
 * Created by Админ on 18.01.2022.
 */

import {LightningElement, api, wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import {NavigationMixin} from "lightning/navigation";
import createOrderWithOrderProducts from '@salesforce/apex/OpportunityProductsController.createOrderWithOrderProducts';
import getOpportunity from '@salesforce/apex/OpportunityProductsController.getOpportunity';

export default class CreateOrderFromOpportunity extends NavigationMixin(LightningElement) {
    date;
    error;
    value = [];
    opportunity;

    _recordId;

    @api set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
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

    get availableOpportunityProducts() {
        return this.generateCheckboxGroup(this.opportunity.OpportunityLineItems);
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
        createOrderWithOrderProducts({ startDate: this.date,
                                      oppProductIds: this.value,
                                      opportunity: this.opportunity
            })
            .then((result) => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        "recordId": result,
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
        if (opportunityItems) {
            for (const opportunityItem of opportunityItems) {
                if (opportunityItem.Quantity <= opportunityItem.Product2.Total_Amount__c) {
                    options.push({label: opportunityItem.Product2.Name, value: opportunityItem.Id});
                }
            }
            return options;
        }
    }

}