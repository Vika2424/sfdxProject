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

    _recordId;

    get isNotRecordUndefined() {
        return this.recordId !== undefined;
    }


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
            console.log('Error: ' + error);
            this.opportunity = undefined;
            this.error = error;
        }
    }

    @wire(getOpportunityProductsForOpportunity, {opportunityId: '$recordId'})
    wireGetOpportunityProduct({data, error}) {
        if (data) {
            this.opportunityProducts = data;
            this.error = undefined;
        } else if (error) {
            this.opportunityProducts = undefined;
            this.error = error;
        }
    }

    get availableOpportunityProducts() {
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
        // console.log('this.value: ');
        // console.log(this.value);
        // console.log('Pricebook2Id');
        // console.log(this.opportunity.Pricebook2Id);
        // console.log({ startDate: this.date,
        //     oppProductIds: this.value,
        //     contactId: this.opportunity.Contact__c,
        //     pricebookId: this.opportunity.Pricebook2Id});
        createOrderWithOrderProducts({ startDate: this.date,
                                                      oppProductIds: this.value,
                                                      contactId: this.opportunity.Contact__c,
                                                      pricebookId: this.opportunity.Pricebook2Id})
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