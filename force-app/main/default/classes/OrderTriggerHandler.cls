/**
 * Trigger Handler for the Order object and the OrderTrigger
 */

public with sharing class OrderTriggerHandler extends TriggerHandler {

    public static final String ACTIVATED_STATUS_STRING = 'Activated';
    public static final String NOT_NEEDED_PRICE_CALC_STATUS = 'Not Needed';
    public static final String COMPLETED_PRICE_CALC_STATUS = 'Completed';

    public override void beforeUpdate() {
        for (Order anOrder : (List<Order>) Trigger.new) {
            if (anOrder.Auto_Contract__c == true && anOrder.Status == ACTIVATED_STATUS_STRING && (anOrder.SBQQ__PriceCalcStatus__c == NOT_NEEDED_PRICE_CALC_STATUS || anOrder.SBQQ__PriceCalcStatus__c == COMPLETED_PRICE_CALC_STATUS)) {
                anOrder.SBQQ__Contracted__c = true;
            }
        }
    }

}