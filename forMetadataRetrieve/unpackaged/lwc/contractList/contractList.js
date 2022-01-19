/**
 * Created by Админ on 09.01.2022.
 */

import {LightningElement, wire} from 'lwc';
import getDraftContracts from '@salesforce/apex/ContractMethods.getDraftContracts';
import { refreshApex } from '@salesforce/apex';
import {updateRecord} from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Contract.Id';
import STATUS_FIELD from '@salesforce/schema/Contract.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContractList extends LightningElement {
    contractIdToUpdate;
    error;

    @wire(getDraftContracts)
    contracts;

    get areContracts() {

        return this.contracts.data != null && this.contracts.data != '';

    }

    handleActivateClick(event) {
        this.contractIdToUpdate = event.detail;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.contractIdToUpdate;
        fields[STATUS_FIELD.fieldApiName] = 'Activated';
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contract updated',
                        variant: 'success'
                    })
                );

                return refreshApex(this.contracts);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

    }
}