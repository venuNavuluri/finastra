/**
 * Handler class for the OpportunityTrigger
 */

public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private static final String PARTNER_PATH_TRUE = 'TRUE';

    static final String PRIMARY_SIGNATORY = 'Primary signatory';
    static final String PREFERRED_SIGNATORY_1 = 'Preferred signatory 1';
    static final String PREFERRED_SIGNATORY_2 = 'Preferred signatory 2';
    static final String PREFERRED_SIGNATORY_3 = 'Preferred signatory 3';
    static final String PREFERRED_SIGNATORY_4 = 'Preferred signatory 4';
    static final String SECOND_SIGNATORY = 'Second signatory';
    static final String SECOND_SIGNATORY_2 = 'Second signatory 2';
    static final String ALTERNATIVE_SIGNATORY_1 = 'Alternative signatory - 1';
    static final String ALTERNATIVE_SIGNATORY_2 = 'Alternative signatory - 2';
    static final String ALTERNATIVE_SIGNATORY_3 = 'Alternative signatory - 3';
    static final String ALTERNATIVE_SIGNATORY_4 = 'Alternative signatory - 4';
    public static Boolean firstRun = true;
    public static Boolean isExecuting = false;

    protected override void beforeInsert() {
        currencyFieldUpdateOnInsert(Trigger.new);
    }

    protected override void afterInsert() {
        List<Opportunity> opportunities = (List<Opportunity>) Trigger.new;
        rollupToAccount(opportunities);

        partnerPathDealUpdate(opportunities);

        insertQuotasAndUpdateContactRoles(opportunities);

        //This is to create the Contact Roles on Opportunity if the Misys Entity is attached to it.
        updateContactRoles((Map<Id, Opportunity>) Trigger.newMap, new Map<Id, Opportunity>());
    }

    protected override void beforeUpdate() {
        List<Opportunity> opportunities = (List<Opportunity>) Trigger.new;
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) Trigger.newMap;
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
        createProjectFromOpportunity(newMap, oldMap);

        ChatterBigDealAlert.checkForBigDeals(opportunities);

        currencyFieldUpdateOnUpdate(opportunities, oldMap);
    }

    protected override void afterUpdate() {
        List<Opportunity> opportunities = (List<Opportunity>) Trigger.new;
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) Trigger.newMap;
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) Trigger.oldMap;

        changeOrderOLIsForDelete(opportunities, oldMap);

        rollupToAccount(opportunities);

        updateOLIWhenTermMonthsChanged(opportunities, oldMap);
        //Update the PS line item scheduled date when the opportunity close data is updated
        updateOppLineItems(opportunities, Trigger.old);

        //Update the Quota Credit lines
        updateQuotaCredits(opportunities, oldMap);

        //Update the Contact Roles
        if (firstRun) {
            updateContactRoles(newMap, oldMap);
            firstRun = false;
        }

        partnerPathDealUpdate(opportunities);
        
        cpiFieldUpdateOnAmendmentContracted(opportunities, oldMap);
    }

    protected override void afterUndelete() {
        rollupToAccount(Trigger.new);
    }

    protected override void beforeDelete() {
        Map<Id, Opportunity> mapCRopps = new Map<Id, Opportunity>();
        //Determine if the OLIs have been pushed to the Parent Opp for this Opp
        for (Opportunity opp : (List<Opportunity>) Trigger.old) {
            if (opp.OLIs_Pushed_To_Parent__c == true) {
                mapCRopps.put(opp.Id, opp);
            }
        }

        if (!mapCRopps.isEmpty()) {
            getChangeOrderOLIsForDelete(mapCRopps);
        }
    }

    protected override void afterDelete() {
        rollupToAccount(Trigger.old);
    }

    ////////////////////////////////////////////////////////////////////////

    public static Boolean deleteChangeOrderOLIsOnParentOpportunity(List<OpportunityLineItem> lOppLineItems) {
        Boolean deleteSuccess = false;
        Database.DeleteResult[] delResult;
        Map<Id, List<Database.Error>> mapOLItoError = new Map<Id, List<Database.Error>>();
        Set<Id> sDeleteFailed_Opps = new Set<Id>();
        Map<Id, OpportunityLineItem> mapOLIs = new Map<Id, OpportunityLineItem>();

        if (lOppLineItems.size() > 0) {

            Set<Id> setOLI_Ids = new Set<Id>();

            //Loop through the OLIs and pull out the ones that have been pushed to the Parent opp.  The others can be ignored since nothing needs to happen for them.
            for (OpportunityLineItem o1 : lOppLineItems) {
                if (o1.CR_Line_Item_Added_To_Parent__c == true) {
                    setOLI_Ids.add(o1.Id);
                }
                mapOLIs.put(o1.Id, o1);
            }
            System.debug('OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity - setOLI_Ids: ' + setOLI_Ids);
            System.debug('OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity - mapOLIs: ' + mapOLIs);

            Map<Id, OpportunityLineItem> mapOLIsToDelete;
            List<OpportunityLineItem> lOLIsToDelete = new List<OpportunityLineItem>();

            //If any OLIs were found, the cooresponding line item needs to selected FROM the Parent Opp for deletion
            if (setOLI_Ids.size() > 0) {
                mapOLIsToDelete = new Map<Id, OpportunityLineItem>([
                    SELECT Id,
                        Original_OLI_Id__c,
                        OpportunityId,
                        Opportunity.Order_Number__c
                    FROM OpportunityLineItem
                    WHERE Added_By_Change_Order__c = true AND Original_OLI_Id__c IN :setOLI_Ids
                ]);
                lOLIsToDelete.addAll(mapOLIsToDelete.values());
            }

            System.debug('OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity - mapOLIsToDelete: ' + mapOLIsToDelete);
            System.debug('OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity - lOLIsToDelete: ' + lOLIsToDelete);

            if (lOLIsToDelete.size() > 0) {
                //use Database.Delete here with the allOrNone option = false, so that if one fails, the others can still be deleted
                delResult = Database.delete(lOLIsToDelete, false);

                //Check if any deletes were not successful
                Integer c = 0;
                for (Database.DeleteResult dr : delResult) {
                    //If not successful, get the OLI Id and associated errors
                    if (dr.isSuccess() == false) {
                        mapOLItoError.put(lOLIsToDelete.get(c).Id, dr.getErrors());
                    }
                    c++;
                }
                System.debug('OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity - mapOLItoError: ' + mapOLItoError);

                Map<Id, String> mapOppIdToOppNumber = new Map<Id, String>();
                Map<Id, String> mapOppIdToErrorMsg = new Map<Id, String>();
                if (mapOLItoError.keySet().size() > 0) {
                    //Errors were found...need to get a List of the Opportunities for which it failed and return those.

                    //Get the Set of unique opportunities affected by the failed deletion
                    for (Id iDel : mapOLItoError.keySet()) {
                        Id oID = mapOLIsToDelete.get(iDel).OpportunityId;
                        sDeleteFailed_Opps.add(oID);
                        mapOppIdToOppNumber.put(oID, mapOLIsToDelete.get(iDel).Opportunity.Order_Number__c);
                        string errorList = String.join(mapOLIToError.get(iDel), ';');
                        mapOppIdToErrorMsg.put(oID, errorList);
                    }
                    System.debug('OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity - sDeleteFailed_Opps: ' + sDeleteFailed_Opps);
                } else {
                    deleteSuccess = true;
                }

                if (sDeleteFailed_Opps.size() > 0) {
                    List<CommonFunctions.CustomException> exceptionsList = new List<CommonFunctions.CustomException>();
                    //Notify PS OPs of the error in deletion - they will need to follow up with sales ops
                    //List<String> toAddr = new String[]{Label.CR_Opps_EmailNoticeAddress};
                    List<String> toAddr = new String[]{
                        Label.CR_Opps_EmailNoticeAddress
                    };
                    String mailSubj = Label.CR_Opp_ErrorMailSubject;
                    String methodName = 'OpportunityTriggerHandler.deleteChangeOrderOLIsOnParentOpportunity';
                    for (Id df : sDeleteFailed_Opps) {
                        exceptionsList.add(new CommonFunctions.CustomException(mapOppIdToErrorMsg.get(df)));
                    }
                    if (!exceptionsList.isEmpty()) {
                        sendMassErrorsEmailFriendly(toAddr, mailSubj, methodName, exceptionsList);
                    }
                }
            }
        }
        return deleteSuccess;
    }

    public static void updateOppLineItemSchedule(String sQuery, Integer iNumMonths) {
        System.debug('OpportunityTriggerHandler.updateOppLineItemSchedule() sQuery=' + sQuery);
        System.debug('OpportunityTriggerHandler.updateOppLineItemSchedule() iNumMonths=' + iNumMonths);

        List<OpportunityLineItemSchedule> lOppLineItemSchedule = Database.query(sQuery);

        for (OpportunityLineItemSchedule olis : lOppLineItemSchedule) {
            olis.ScheduleDate = olis.ScheduleDate.addMonths(iNumMonths);
        }

        if (lOppLineItemSchedule.size() > 0) {
            update lOppLineItemSchedule;
        }
    }


    private void changeOrderOLIsForDelete(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap) {
        Map<Id, Opportunity> mapCROppsClosedLost = new Map<Id, Opportunity>();
        for (Opportunity anOpportunity : opportunities) {
            if (anOpportunity.RecordTypeId == Label.RecType_Opportunity_ChangeReq && anOpportunity.Original_Opportunity__c != null) {
                if (anOpportunity.IsClosed == true && anOpportunity.IsWon == false && (oldOpportunityMap.get(anOpportunity.Id).IsClosed != true || oldOpportunityMap.get(anOpportunity.Id).IsWon != false)
                    && anOpportunity.OLIs_Pushed_To_Parent__c) {
                    //This is a Change Opportunity that has just been marked as Closed and Lost.  Any OLI's copied to the Parent opp now need to be removed.
                    mapCROppsClosedLost.put(anOpportunity.Id, anOpportunity);
                }
            }
        }

        if (mapCROppsClosedLost.keySet().size() > 0) {
            getChangeOrderOLIsForDelete(mapCROppsClosedLost);
        }
    }

    private void currencyFieldUpdateOnInsert(List<Opportunity> oppListInsert) {
        System.debug('OpportunityTriggerHandler.currencyFieldUpdateOnInsert() ' + oppListInsert);
        for (Opportunity oppInsert : oppListInsert) {
            oppInsert.ILF_Equiv_SUB__c = getValue(oppInsert.SUB_Amount__c) * 2.5;
            oppInsert.ILF_Equiv_CLD__c = getValue(oppInsert.CLD_Amount__c) * 2.5;
            oppInsert.ILF_Equiv_HOS__c = getValue(oppInsert.HOS_Amount__c) * 2.5;

            if (getValue(oppInsert.Booking_Adjustment_percent__c) == 0 || getValue(oppInsert.Booking_Adjustment_percent__c) == null) {
                oppInsert.ILF_Equiv_CSH__c = getValue(oppInsert.ILF_Equiv_SUB__c) + getValue(oppInsert.ILF_Equiv_CLD__c) + getValue(oppInsert.ILF_Equiv_HOS__c);
            } else {
                oppInsert.ILF_Equiv_CSH__c = getValue(oppInsert.Booking_Adjustment_percent__c / 100) * (getValue(oppInsert.ILF_Equiv_SUB__c) + getValue(oppInsert.ILF_Equiv_CLD__c) + getValue(oppInsert.ILF_Equiv_HOS__c));
            }

            oppInsert.ILF_ILF_Equiv_CSH__c = getValue(oppInsert.Total_ILF_In_Qtr__c) + getValue(oppInsert.ILF_Equiv_CSH__c);
            oppInsert.CLD_CB_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_CB_TP__c) * 2.5;
            oppInsert.CLD_CL_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_CL_TP__c) * 2.5;
            oppInsert.CLD_ER_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_ER_TP__c) * 2.5;
            oppInsert.CLD_CM_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_CM_TP__c) * 2.5;
            oppInsert.CLD_TB_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_TB_TP__c) * 2.5;
            oppInsert.CLD_IM_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_IM_TP__c) * 2.5;

            oppInsert.SUB_CB_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_CB_TP__c) * 2.5;
            oppInsert.SUB_CL_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_CL_TP__c) * 2.5;
            oppInsert.SUB_ER_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_ER_TP__c) * 2.5;
            oppInsert.SUB_CM_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_CM_TP__c) * 2.5;
            oppInsert.SUB_TB_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_TB_TP__c) * 2.5;
            oppInsert.SUB_IM_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_IM_TP__c) * 2.5;

            oppInsert.HOS_CB_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_CB_TP__c) * 2.5;
            oppInsert.HOS_CL_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_CL_TP__c) * 2.5;
            oppInsert.HOS_ER_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_ER_TP__c) * 2.5;
            oppInsert.HOS_CM_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_CM_TP__c) * 2.5;
            oppInsert.HOS_TB_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_TB_TP__c) * 2.5;
            oppInsert.HOS_IM_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_IM_TP__c) * 2.5;

            //PN 22/10/2018 - changing the calculations as per Robert ACV document
            /*oppInsert.CSH_CB_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_CB_Revenue__c)
                    +((getValue(oppInsert.RSF_CLD_CB_TP__c)
                    + getValue(oppInsert.RSF_SUB_CB_TP__c)
                    + getValue(oppInsert.RSF_HOS_CB_TP__c))* 2.5);*/

            oppInsert.CSH_CB_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_CB_Revenue__c) + (getValue(oppInsert.ACV_Booking_CB__c) * 2.5);

            /* oppInsert.CSH_CL_ILF_ILF_Equiv__c  =  getValue(oppInsert.In_QTR_ILF_CL_Revenue__c)
                     + ((getValue(oppInsert.RSF_CLD_CL_TP__c)
                     + getValue(oppInsert.RSF_SUB_CL_TP__c)
                     + getValue(oppInsert.RSF_HOS_CL_TP__c))* 2.5);*/

            oppInsert.CSH_CL_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_CL_Revenue__c) + (getValue(oppInsert.ACV_Booking_CL__c) * 2.5);

            /* oppInsert.CSH_ER_ILF_ILF_Equiv__c  =  (oppInsert.In_QTR_ILF_ER_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_ER_Revenue__c)
                     + ((getValue(oppInsert.RSF_CLD_ER_TP__c)
                     + getValue(oppInsert.RSF_SUB_ER_TP__c)
                     + getValue(oppInsert.RSF_HOS_ER_TP__c)) * 2.5); */

            oppInsert.CSH_ER_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_ER_Revenue__c) + (getValue(oppInsert.ACV_Booking_ER__c) * 2.5);

            /* oppInsert.CSH_CM_ILF_ILF_Equiv__c= (oppInsert.In_QTR_ILF_CM_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_CM_Revenue__c)
                     +((getValue(oppInsert.RSF_CLD_CM_TP__c)
                     + getValue(oppInsert.RSF_SUB_CM_TP__c)
                     + getValue(oppInsert.RSF_HOS_CM_TP__c))* 2.5);*/

            oppInsert.CSH_CM_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_CM_Revenue__c) + (getValue(oppInsert.ACV_Booking_CM__c) * 2.5);

            /* oppInsert.CSH_TB_ILF_ILF_Equiv__c= (oppInsert.In_QTR_ILF_TB_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_TB_Revenue__c)
                     +((getValue(oppInsert.RSF_CLD_TB_TP__c)
                     + getValue(oppInsert.RSF_SUB_TB_TP__c)
                     + getValue(oppInsert.RSF_HOS_TB_TP__c))* 2.5);*/

            oppInsert.CSH_TB_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_TB_Revenue__c) + (getValue(oppInsert.ACV_Booking_TB__c) * 2.5);

            /* oppInsert.CSH_IM_ILF_ILF_Equiv__c= (oppInsert.In_QTR_ILF_IM_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_IM_Revenue__c)
                     +((getValue(oppInsert.RSF_CLD_IM_TP__c)
                     + getValue(oppInsert.RSF_SUB_IM_TP__c)
                     + getValue(oppInsert.RSF_HOS_IM_TP__c))* 2.5);*/

            oppInsert.CSH_IM_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_IM_Revenue__c) + (getValue(oppInsert.ACV_Booking_IM__c) * 2.5);

            //PN 22/10/2018 - changing the calculations as per Robert ACV document
        }
    }

    private void currencyFieldUpdateOnUpdate(List<Opportunity> oppListUpdate, Map<Id, Opportunity> oldMap) {
        System.debug('OpportunityTriggerHandler.currencyFieldUpdateOnUpdate() ' + oppListUpdate);
        for (Opportunity oppUpdate : oppListUpdate) {
            if (oppUpdate.SUB_Amount__c != oldMap.get(oppUpdate.Id).SUB_Amount__c) {
                oppUpdate.ILF_Equiv_SUB__c = getValue(oppUpdate.SUB_Amount__c) * 2.5;
            }

            if (oppUpdate.CLD_Amount__c != oldMap.get(oppUpdate.Id).CLD_Amount__c) {
                oppUpdate.ILF_Equiv_CLD__c = getValue(oppUpdate.CLD_Amount__c) * 2.5;
            }

            if (oppUpdate.HOS_Amount__c != oldMap.get(oppUpdate.Id).HOS_Amount__c) {
                oppUpdate.ILF_Equiv_HOS__c = getValue(oppUpdate.HOS_Amount__c) * 2.5;
            }

            if (oppUpdate.Booking_Adjustment_percent__c != oldMap.get(oppUpdate.Id).Booking_Adjustment_percent__c || oppUpdate.ILF_Equiv_SUB__c != oldMap.get(oppUpdate.Id).ILF_Equiv_SUB__c || oppUpdate.ILF_Equiv_CLD__c != oldMap.get(oppUpdate.Id).ILF_Equiv_CLD__c || oppUpdate.ILF_Equiv_HOS__c != oldMap.get(oppUpdate.Id).ILF_Equiv_HOS__c) {
                if (oppUpdate.Booking_Adjustment_percent__c == 0 || oppUpdate.Booking_Adjustment_percent__c == null) {
                    oppUpdate.ILF_Equiv_CSH__c = getValue(oppUpdate.ILF_Equiv_SUB__c) + getValue(oppUpdate.ILF_Equiv_CLD__c) + getValue(oppUpdate.ILF_Equiv_HOS__c);
                } else {
                    oppUpdate.ILF_Equiv_CSH__c = getValue(oppUpdate.Booking_Adjustment_percent__c / 100) * (getValue(oppUpdate.ILF_Equiv_SUB__c) + getValue(oppUpdate.ILF_Equiv_CLD__c) + getValue(oppUpdate.ILF_Equiv_HOS__c));
                }
            }

            if (oppUpdate.ILF_Equiv_CSH__c != null && oppUpdate.Total_ILF_In_Qtr__c != oldMap.get(oppUpdate.Id).Total_ILF_In_Qtr__c || oppUpdate.ILF_Equiv_CSH__c != oldMap.get(oppUpdate.Id).ILF_Equiv_CSH__c) {
                oppUpdate.ILF_ILF_Equiv_CSH__c = getValue(oppUpdate.Total_ILF_In_Qtr__c) + getValue(oppUpdate.ILF_Equiv_CSH__c);
            }

            if (oppUpdate.RSF_CLD_CB_TP__c != oldMap.get(oppUpdate.Id).RSF_CLD_CB_TP__c) {
                oppUpdate.CLD_CB_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_CB_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_CLD_CL_TP__c != oldMap.get(oppUpdate.Id).RSF_CLD_CL_TP__c) {
                oppUpdate.CLD_CL_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_CL_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_CLD_ER_TP__c != oldMap.get(oppUpdate.Id).RSF_CLD_ER_TP__c) {
                oppUpdate.CLD_ER_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_ER_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_CLD_CM_TP__c != oldMap.get(oppUpdate.Id).RSF_CLD_CM_TP__c) {
                oppUpdate.CLD_CM_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_CM_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_CLD_TB_TP__c != oldMap.get(oppUpdate.Id).RSF_CLD_TB_TP__c) {
                oppUpdate.CLD_TB_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_TB_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_CLD_IM_TP__c != oldMap.get(oppUpdate.Id).RSF_CLD_IM_TP__c) {
                oppUpdate.CLD_IM_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_IM_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_SUB_CB_TP__c != oldMap.get(oppUpdate.Id).RSF_SUB_CB_TP__c) {
                oppUpdate.SUB_CB_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_CB_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_SUB_CL_TP__c != oldMap.get(oppUpdate.Id).RSF_SUB_CL_TP__c) {
                oppUpdate.SUB_CL_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_CL_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_SUB_ER_TP__c != oldMap.get(oppUpdate.Id).RSF_SUB_ER_TP__c) {
                oppUpdate.SUB_ER_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_ER_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_SUB_CM_TP__c != oldMap.get(oppUpdate.Id).RSF_SUB_CM_TP__c) {
                oppUpdate.SUB_CM_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_CM_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_SUB_TB_TP__c != oldMap.get(oppUpdate.Id).RSF_SUB_TB_TP__c) {
                oppUpdate.SUB_TB_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_TB_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_SUB_IM_TP__c != oldMap.get(oppUpdate.Id).RSF_SUB_IM_TP__c) {
                oppUpdate.SUB_IM_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_IM_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_HOS_CB_TP__c != oldMap.get(oppUpdate.Id).RSF_HOS_CB_TP__c) {
                oppUpdate.HOS_CB_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_CB_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_HOS_CL_TP__c != oldMap.get(oppUpdate.Id).RSF_HOS_CL_TP__c) {
                oppUpdate.HOS_CL_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_CL_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_HOS_ER_TP__c != oldMap.get(oppUpdate.Id).RSF_HOS_ER_TP__c) {
                oppUpdate.HOS_ER_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_ER_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_HOS_CM_TP__c != oldMap.get(oppUpdate.Id).RSF_HOS_CM_TP__c) {
                oppUpdate.HOS_CM_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_CM_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_HOS_TB_TP__c != oldMap.get(oppUpdate.Id).RSF_HOS_TB_TP__c) {
                oppUpdate.HOS_TB_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_TB_TP__c) * 2.5;
            }

            if (oppUpdate.RSF_HOS_IM_TP__c != oldMap.get(oppUpdate.Id).RSF_HOS_IM_TP__c) {
                oppUpdate.HOS_IM_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_IM_TP__c) * 2.5;
            }

            //if(oppUpdate.CSH_CB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CB_Revenue__c || oppUpdate.RSF_CLD_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_CB_TP__c || oppUpdate.RSF_SUB_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_CB_TP__c || oppUpdate.RSF_HOS_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CB_TP__c){
            if (oppUpdate.CSH_CB_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_CB_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_CB_Revenue__c || oppUpdate.ACV_Booking_CB__c != oldMap.get(oppUpdate.Id).ACV_Booking_CB__c) {
                // oppUpdate.CSH_CB_ILF_ILF_Equiv__c  = getValue(oppUpdate.In_QTR_ILF_CB_Revenue__c) + ((getValue(oppUpdate.RSF_CLD_CB_TP__c) + getValue(oppUpdate.RSF_SUB_CB_TP__c) + getValue(oppUpdate.RSF_HOS_CB_TP__c)) * 2.5);
                oppUpdate.CSH_CB_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_CB_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CB__c) * 2.5);
            }

            // if(oppUpdate.CSH_CL_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CL_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CL_Revenue__c || oppUpdate.RSF_CLD_CL_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_CL_TP__c || oppUpdate.RSF_SUB_CL_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_CL_TP__c || oppUpdate.RSF_HOS_CL_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CL_TP__c){
            if (oppUpdate.CSH_CL_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_CL_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_CL_Revenue__c || oppUpdate.ACV_Booking_CL__c != oldMap.get(oppUpdate.Id).ACV_Booking_CL__c) {
                oppUpdate.CSH_CL_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_CL_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CL__c) * 2.5);
            }

            // if(oppUpdate.CSH_ER_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_ER_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_ER_Revenue__c || oppUpdate.RSF_CLD_ER_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_ER_TP__c || oppUpdate.RSF_SUB_ER_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_ER_TP__c || oppUpdate.RSF_HOS_ER_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_ER_TP__c){
            if (oppUpdate.CSH_ER_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_ER_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_ER_Revenue__c || oppUpdate.ACV_Booking_ER__c != oldMap.get(oppUpdate.Id).ACV_Booking_ER__c) {
                oppUpdate.CSH_ER_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_ER_Revenue__c) + (getValue(oppUpdate.ACV_Booking_ER__c) * 2.5);
            }

            // if(oppUpdate.CSH_CM_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CM_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CM_Revenue__c || oppUpdate.RSF_CLD_CM_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_CM_TP__c || oppUpdate.RSF_SUB_CM_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_CM_TP__c || oppUpdate.RSF_HOS_CM_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CM_TP__c){
            if (oppUpdate.CSH_CM_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_CM_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_CM_Revenue__c || oppUpdate.ACV_Booking_CM__c != oldMap.get(oppUpdate.Id).ACV_Booking_CM__c) {
                oppUpdate.CSH_CM_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_CM_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CM__c) * 2.5);
            }

            //if(oppUpdate.CSH_TB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_TB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_TB_Revenue__c || oppUpdate.RSF_CLD_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_TB_TP__c || oppUpdate.RSF_SUB_TB_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_TB_TP__c || oppUpdate.RSF_HOS_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_TB_TP__c){
            if (oppUpdate.CSH_TB_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_TB_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_TB_Revenue__c || oppUpdate.ACV_Booking_TB__c != oldMap.get(oppUpdate.Id).ACV_Booking_TB__c) {
                oppUpdate.CSH_TB_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_TB_Revenue__c) + (getValue(oppUpdate.ACV_Booking_TB__c) * 2.5);
            }

            //if(oppUpdate.CSH_IM_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_IM_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_IM_Revenue__c || oppUpdate.RSF_CLD_IM_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_IM_TP__c || oppUpdate.RSF_SUB_IM_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_IM_TP__c || oppUpdate.RSF_HOS_IM_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_IM_TP__c){
            if (oppUpdate.CSH_IM_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_IM_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_IM_Revenue__c || oppUpdate.ACV_Booking_IM__c != oldMap.get(oppUpdate.Id).ACV_Booking_IM__c) {
                oppUpdate.CSH_IM_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_IM_Revenue__c) + (getValue(oppUpdate.ACV_Booking_IM__c) * 2.5);
            }

            if (oppUpdate.CSH_CB_ILF_ILF_Equiv__c != null && oppUpdate.In_QTR_ILF_CB_Revenue__c != oldMap.get(oppUpdate.Id).In_QTR_ILF_CB_Revenue__c || oppUpdate.ACV_Booking_CB__c != oldMap.get(oppUpdate.Id).ACV_Booking_CB__c) {
                oppUpdate.CSH_CB_ILF_ILF_Equiv__c = getValue(oppUpdate.In_QTR_ILF_CB_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CB__c) * 2.5);
            }

        }
    }

    private void partnerPathDealUpdate(List<Opportunity> opportunities) {
        if (label.PartnerPathDealUpdateTrigger_Switch.equalsIgnoreCase(PARTNER_PATH_TRUE)) {
            List<Id> partnerPathOppList = new List<Id>();
            //To filter the partner opportunities based on partner path Id and the opp record type
            for (Opportunity oppObj : opportunities) {
                if (oppObj.RecordTypeId == IdManager.OPP_LicensesWithWithoutPSRecTypeId && !String.isEmpty(oppObj.PartnerPath_ID__c)) {
                    partnerPathOppList.add(oppObj.Id);
                }
            }
            if (partnerPathOppList.size() > 0) {
                //To make a synchronous call to PartnerPath if the opportunity update is called from a Batch Apex.
                if (System.isBatch() || System.isFuture()) {
                    System.debug('PartnerPathDealUpdateTrigger :: Called from Batch Apex to update PartnerPath deal synchronously');
                    /*This method is called when the pearl proposal is pushed to sfdc via Batch Apex.
                      Currently this is commented as Opportunity and OLI coming from pearl are heavy and this is a synchronous callout
                      to PartnerPath, due to which sfdc bach apex performance will be slowed down.
                    */

                    //PartnerPathRESTIntegration.sendOppDetailsToPPSync(trigger.new);
                } else {
                    //To call the future method sendOppDetailsToPartnerPathOnOppCreate after partner opportunity creation
                    if (Trigger.isAfter && Trigger.isInsert) {
                        System.debug('PartnerPathDealUpdateTrigger :: To call the update deal on opp creation');
                        PartnerPathRESTIntegration.sendOppDetailsToPartnerPathOnOppCreate(partnerPathOppList);
                    }
                    //To call the future method sendOppDetailsToPartnerPathOnOppUpdate after partner opportunity updation
                    if (Trigger.isAfter && Trigger.isUpdate) {
                        System.debug('PartnerPathDealUpdateTrigger :: To call the update deal on opp updation');
                        PartnerPathRESTIntegration.sendOppDetailsToPartnerPathOnOppUpdate(partnerPathOppList);
                    }
                }
            }
        }
    }

    private void insertQuotasAndUpdateContactRoles(List<Opportunity> opportunities) {
        RecordType lQuotaRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Direct Master Credit' AND sObjectType = 'Com_Splits__c'
        ];

        List<Com_Splits__c> insertComSplits = new List<Com_Splits__c>();
        for (Integer li_counter = 0; li_counter < opportunities.size(); li_counter++) {
            Com_Splits__c lQuotaCredits = new Com_Splits__c();
            lQuotaCredits.Opportunity__c = opportunities[li_counter].Id;
            lQuotaCredits.RecordTypeId = lQuotaRecordType.Id;
            lQuotaCredits.Employee_Name__c = opportunities[li_counter].OwnerId;
            lQuotaCredits.CurrencyIsoCode = opportunities[li_counter].CurrencyIsoCode;

            insertComSplits.add(lQuotaCredits);
        }

        if (insertComSplits.size() > 0) {
            insert insertComSplits;
        }
    }

    private void cpiFieldUpdateOnAmendmentContracted(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        System.debug('OpportunityTriggerHandler.cpiFieldUpdateOnAmendmentContracted() ' + opportunities);
        Map<Id, Id> contractIdQuoteIdMap = new Map<Id, Id>();
        for (Opportunity opp : opportunities) {
            //See if any of these opportunites were just contracted.
         	if ((opp.SBQQ__AmendedContract__c != null) && (opp.SBQQ__PrimaryQuote__c != null) && 
                (opp.SBQQ__Contracted__c == true) && (oldMap.get(opp.Id).SBQQ__Contracted__c == false)) {
            	contractIdQuoteIdMap.put(opp.SBQQ__AmendedContract__c, opp.SBQQ__PrimaryQuote__c);
            }
        }
        System.debug('OpportunityTriggerHandler.cpiFieldUpdateOnAmendmentContracted contractIdQuoteIdMap ' + contractIdQuoteIdMap);
        
        if (contractIdQuoteIdMap.isEmpty() == false) {
            List<Contract> contractsToUpdate = [select Id, Standard_Index__c, Additional_Increase__c, CPI__c, CPI_Index_Type__c, Maximum_Rate__c, Minimum_Rate__c, No_CPI__c, Use_Existing_CPI__c, Apply_Standard_CPI__c  from Contract where Id in :contractIdQuoteIdMap.keySet()];
            Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Standard_Index__c, Additional_Increase__c, CPI__c, CPI_Index_Type__c, Maximum_Rate__c, Minimum_Rate__c, No_CPI__c, Use_Existing_CPI__c, Apply_Standard_CPI__c FROM SBQQ__Quote__c where Id in :contractIdQuoteIdMap.values()]);
			//Update Contracts with the data from the primary quotes.
            for(Contract c : contractsToUpdate) {
                Id quoteId = contractIdQuoteIdMap.get(c.Id);
                if (quoteMap.containsKey(quoteId)) {
                    SBQQ__Quote__c dataQuote = quoteMap.Get(quoteId);
                    c.Standard_Index__c = dataQuote.Standard_Index__c;
                    c.Additional_Increase__c = dataQuote.Additional_Increase__c;
                    c.CPI__c = dataQuote.CPI__c;
                    c.CPI_Index_Type__c = dataQuote.CPI_Index_Type__c;
                    c.Maximum_Rate__c  = dataQuote.Maximum_Rate__c ;
                    c.Minimum_Rate__c  = dataQuote.Minimum_Rate__c ;
                    c.No_CPI__c = dataQuote.No_CPI__c;
                    c.Use_Existing_CPI__c = dataQuote.Use_Existing_CPI__c;
                    c.Apply_Standard_CPI__c = dataQuote.Apply_Standard_CPI__c;
                }
        	}
            //Update the Contracts.
            if (contractsToUpdate != null && contractsToUpdate.size() > 0) {
        		System.debug('OpportunityTriggerHandler.cpiFieldUpdateOnAmendmentContracted contractsToUpdate ' + contractsToUpdate);
            	update contractsToUpdate;
            }
        }
     }

    /*
        This method is for creating and updating the contact roles on opportunity based on the Entity attached to it.
        It will pull out the Primary and Preferred signatories FROM the attached Entity and will create the contact roles.
    */
    private static void updateContactRoles(Map<id, Opportunity> updatedOpps, Map<Id, Opportunity> prevOpps) {
        Set<Id> misysEntityIds = new Set<Id>();
        Map<Id, Id> meOppIdMap = new Map<Id, Id>();
        Map<Id, Billing_Entity__c> misysEntityMap = new Map<Id, Billing_Entity__c>();

        Map<Id, Id> prevMeOppIdMap = new Map<Id, Id>();
        Map<Id, Billing_Entity__c> prevMisysEntityMap = new Map<Id, Billing_Entity__c>();

        System.debug('UpdateContactRoles - updatedOpps - ' + updatedOpps);
        System.debug('UpdateContactRoles - prevOpps - ' + prevOpps);

        for (Opportunity opp : updatedOpps.values()) {
            if (opp.Entity__c != null && prevOpps != null && prevOpps.size() > 0 && opp.Entity__c != prevOpps.get(opp.Id).Entity__c) {
                misysEntityIds.add(opp.Entity__c);
                meOppIdMap.put(opp.Entity__c, opp.Id);

                if (prevOpps.get(opp.Id).Entity__c != null) {
                    misysEntityIds.add(prevOpps.get(opp.Id).Entity__c);
                    prevMeOppIdMap.put(prevOpps.get(opp.Id).Entity__c, opp.Id);
                }
            } else if (opp.Entity__c == null && prevOpps != null && prevOpps.size() > 0 && prevOpps.get(opp.Id).Entity__c != null) {
                misysEntityIds.add(prevOpps.get(opp.Id).Entity__c);
                prevMeOppIdMap.put(prevOpps.get(opp.Id).Entity__c, opp.Id);
            } else if (opp.Entity__c != null && prevOpps != null && prevOpps.size() == 0) {
                misysEntityIds.add(opp.Entity__c);
                meOppIdMap.put(opp.Entity__c, opp.Id);
            }
        }
        System.debug('UpdateContactRoles - misysEntityIds - ' + misysEntityIds);
        System.debug('UpdateContactRoles - prevMeOppIdMap - ' + prevMeOppIdMap);
        System.debug('UpdateContactRoles - meOppIdMap - ' + meOppIdMap);

        if (misysEntityIds != null && misysEntityIds.size() > 0) {
            for (Billing_Entity__c me : [
                SELECT Primary_signatory__c, Preferred_signatory_1__c, Preferred_signatory_2__c,
                    Preferred_signatory_3__c, Preferred_signatory_4__c, Second_signatory__c, Second_Signatory_2__c,
                    Alternative_signatory_1__c, Alternative_signatory_2__c, Alternative_signatory_3__c, Alternative_signatory_4__c
                FROM Billing_Entity__c
                WHERE id in :misysEntityIds and Entity_Status__c = 'Contracting Entity'
            ]) {
                if (meOppIdMap.containsKey(me.Id)) {
                    misysEntityMap.put(meOppIdMap.get(me.Id), me);
                } else if (prevMeOppIdMap.containsKey(me.Id)) {
                    prevMisysEntityMap.put(prevMeOppIdMap.get(me.Id), me);
                }

            }
        }
        System.debug('UpdateContactRoles - misysEntityIds 1 - ' + misysEntityIds);
        System.debug('UpdateContactRoles - misysEntityMap 1 - ' + misysEntityMap);
        System.debug('UpdateContactRoles - prevMisysEntityMap 1 - ' + prevMisysEntityMap);
        //Create a List of contacts that needs to be deleted FROM the Contact Roles and delete the Contact Roles
        if (prevMisysEntityMap != null && prevMisysEntityMap.size() > 0) {
            List<Id> prevContactIdList = new List<Id>();
            for (Billing_Entity__c mEntity : prevMisysEntityMap.values()) {
                if (mEntity.Primary_signatory__c != null) {
                    prevContactIdList.add(mEntity.Primary_signatory__c);
                }
                if (mEntity.Preferred_signatory_1__c != null) {
                    prevContactIdList.add(mEntity.Preferred_signatory_1__c);
                }
                if (mEntity.Preferred_signatory_2__c != null) {
                    prevContactIdList.add(mEntity.Preferred_signatory_2__c);
                }
                if (mEntity.Preferred_signatory_3__c != null) {
                    prevContactIdList.add(mEntity.Preferred_signatory_3__c);
                }
                if (mEntity.Preferred_signatory_4__c != null) {
                    prevContactIdList.add(mEntity.Preferred_signatory_4__c);
                }
                if (mEntity.Second_signatory__c != null) {
                    prevContactIdList.add(mEntity.Second_signatory__c);
                }
                if (mEntity.Second_Signatory_2__c != null) {
                    prevContactIdList.add(mEntity.Second_Signatory_2__c);
                }
            }
            if (prevContactIdList != null && prevContactIdList.size() > 0) {
                List<OpportunityContactRole> prevOCR = [SELECT id, ContactId, OpportunityId, Role FROM OpportunityContactRole WHERE ContactId in :prevContactIdList and OpportunityId in :prevMisysEntityMap.keySet()];
                if (prevOCR != null && prevOCR.size() > 0) {
                    delete prevOCR;
                }
            }
        }

        //Create a List of contacts that needs to be added as the Contact Roles and create them
        if (misysEntityMap != null && misysEntityMap.size() > 0) {
            List<OpportunityContactRole> newOCRList = new List<OpportunityContactRole>();
            for (Id oppId : misysEntityMap.keySet()) {
                if (misysEntityMap.get(oppId).Primary_signatory__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Primary_signatory__c, Role = PRIMARY_SIGNATORY));
                    System.debug('UpdateContactRoles - newOCRList 1 - ' + newOCRList);
                }
                if (misysEntityMap.get(oppId).Preferred_signatory_1__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_1__c, Role = PREFERRED_SIGNATORY_1));
                    System.debug('UpdateContactRoles - newOCRList 2 - ' + newOCRList);
                }
                if (misysEntityMap.get(oppId).Preferred_signatory_2__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_2__c, Role = PREFERRED_SIGNATORY_2));
                    System.debug('UpdateContactRoles - newOCRList 3 - ' + newOCRList);
                }
                if (misysEntityMap.get(oppId).Preferred_signatory_3__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_3__c, Role = PREFERRED_SIGNATORY_3));
                    System.debug('UpdateContactRoles - newOCRList 4 - ' + newOCRList);
                }
                if (misysEntityMap.get(oppId).Preferred_signatory_4__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_4__c, Role = PREFERRED_SIGNATORY_4));
                    System.debug('UpdateContactRoles - newOCRList 5 - ' + newOCRList);
                }
                if (misysEntityMap.get(oppId).Second_signatory__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Second_signatory__c, Role = SECOND_SIGNATORY));
                    System.debug('UpdateContactRoles - newOCRList 6 - ' + newOCRList);
                }
                if (misysEntityMap.get(oppId).Second_Signatory_2__c != null) {
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Second_Signatory_2__c, Role = SECOND_SIGNATORY_2));
                    System.debug('UpdateContactRoles - newOCRList 7 - ' + newOCRList);
                }
            }
            if (newOCRList != null && newOCRList.size() > 0) {
                System.debug('UpdateContactRoles - newOCRList 8 - ' + newOCRList);
                insert newOCRList;
            }
        }
    }

    private static void rollupToAccount(List<Opportunity> oppList) {
        //populate the currency conversion rate Map
        Map<string, Decimal> conversionRateMap = new Map<string, Decimal>();
        for (CurrencyType cType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive = TRUE]) {
            conversionRateMap.put(cType.ISOCode, cType.ConversionRate);
        }
        System.debug('OpportunityTriggerHandler.rollupToAccount() Changed conversionRateMap = ' + conversionRateMap);
        Set<Id> accountIds = new Set<Id>();
        Map<Id, List<Opportunity>> aacIdOppListMap = new Map<Id, List<Opportunity>>();

        for (Opportunity opp : oppList) {
            accountIds.add(opp.AccountId);
        }
        System.debug('OpportunityTriggerHandler.rollupToAccount() accountIds = ' + accountIds);

        List<Opportunity> opportunityList;

        if (accountIds != null && accountIds.size() > 0) {
            for (Opportunity opp : [select Id, name, ILF_Amount__c, PS_Amount__c, StageName, AccountId, CloseDate, CurrencyISOCode from Opportunity where AccountId in :accountIds]) {
                if (aacIdOppListMap.containsKey(opp.AccountId)) {
                    opportunityList = aacIdOppListMap.get(opp.AccountId);
                    opportunityList.add(opp);
                } else {
                    opportunityList = new List<Opportunity>();
                    opportunityList.add(opp);
                    aacIdOppListMap.put(opp.AccountId, opportunityList);
                }
            }
            System.debug('OpportunityTriggerHandler.rollupToAccount() aacIdOppListMap = ' + aacIdOppListMap);

            //logic for rollup
            List<Account> updateAccountList = new List<Account>();
            for (Id accId : accountIds) {
                Decimal ilfClosedAmount = 0;
                Decimal ilfPipelineAmount = 0;
                Decimal servicesClosedAmount = 0;
                Decimal servicesPipelineAmount = 0;

                if (aacIdOppListMap.containsKey(accId)) {
                    Account account = new Account(Id = accId);
                    Boolean flag = false;
                    for (Opportunity opp : aacIdOppListMap.get(accId)) {
                        Decimal conversionRate = 1;
                        if (conversionRateMap.containsKey(opp.CurrencyISOCode)) {
                            conversionRate = conversionRateMap.get(opp.CurrencyISOCode);
                        }
                        if (opp.StageName == 'Closed Won' && isCurrentFY(opp.CloseDate) && opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0) {
                            ilfClosedAmount = ilfClosedAmount + opp.ILF_Amount__c / conversionRate;
                            flag = true;
                        }
                        if ((opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate' || opp.StageName == '7. Committed')
                            && opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0) {

                            ilfPipelineAmount = ilfPipelineAmount + opp.ILF_Amount__c / conversionRate;
                            flag = true;
                        }
                        if (opp.StageName == 'Closed Won' && isCurrentFY(opp.CloseDate) && opp.PS_Amount__c != null && opp.PS_Amount__c != 0) {
                            servicesClosedAmount = servicesClosedAmount + opp.PS_Amount__c / conversionRate;
                            flag = true;
                        }
                        if ((opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate' || opp.StageName == '7. Committed')
                            && opp.PS_Amount__c != null && opp.PS_Amount__c != 0) {

                            servicesPipelineAmount = servicesPipelineAmount + opp.PS_Amount__c / conversionRate;
                            flag = true;
                        }
                        /* KK: Service Desk Req 1441822 : added a check for closed lost and Closed Qualified Out opportunities.
                         No rollup should be done for above 4 fields of this type of opportunity */
                        if (opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Qualified Out') {
                            flag = true;
                        }
                    }
                    account.ILF_Closed_Current_FY__c = ilfClosedAmount;
                    account.ILF_Pipeline__c = ilfPipelineAmount;
                    account.Services_Closed_Current_FY__c = servicesClosedAmount;
                    account.Services_Pipeline__c = servicesPipelineAmount;
                    if (flag == true) {
                        updateAccountList.add(account);
                    }
                }
            }
            System.debug('updateAccountList = ' + updateAccountList);
            if (updateAccountList != null && updateAccountList.size() > 0) {
                update updateAccountList;
            }
        }
    }

    private static void updateOppLineItems(List<Opportunity> updatedOpps, List<Opportunity> prevOpps) {

        /*
            Name        :   OpportunityAfterUpdate

            Purpose     :   The trigger contains business logic that's supposed to occur when opportunity gets updated.
                            This trigger will be fired on update of Opportunity record(s) Single or in batch.

            Parameters  :   N/A

            Invoked From    : Auto-triggered on Opportunity record update

            Triggering Condition:   1. Opportunity.CloseDate changed
                                    2. Opportuniy.Owner changed

            Returns     :   N/A

            Notes       :   1. The initial version of the trigger was to fulfil PS Forecasting requirements. The details of the requirements can be
                            obtained at https://emea.salesforce.com/015?fcf=00l200000012cfl
                                a. When the Month of modified CloseDate is the same, send an email;
                                b. When the Month of modified CloseDate is the different, update month of the schedule dates relatively.

                            2. When Opportunity Owner changes and have corresponding Quota Credit records, the employee name on it should be changed.


            Modification Log

            User                Date                Description
            --------------      ----------          --------------------------------------------------------------
            Prashant Bhure      05/21/2009          Created - Initial version - To meet PS Forecasting requirements.
            Prashant Bhure      05/22/3009          Modified to meet Quota Credit requirements.
            Prashant Bhure      07/09/2009          When PS Team member not assigned, send the email to regional teams.
            Prashant Bhure      07/13/2009          Added opp name and opp link to the email; Changed the email for MEA to Managers FROM Team.
            Jason Bennett       04/05/2011          Reformatted code for better readability
            Jason Bennett       04/05/2011          Modified code to call the update to OpportunityLineItems as an asynchronous (Future) process instead of Batch Apex (to avoid issues with limits)
            Jason Bennett       04/06/2011          Modified code detect if it is running in production or sandbox, and adjust email TO address accordingly
            Jason Bennett       06/16/2011          Added code to log updates made by an integration for RLF amounts
            Jason Bennett       09/19/2012          Moved the SendMail call outside the loop to prevent limit errors.  Also, moved the code out of the trigger and into this class.

            */

        String ls_email_conclusion = '<br><br> You may update the schedule.';
        String sPS = 'PS', sFD = 'FD';
        String currentUserEmail = '';
        if (!GlobalVar.IsProduction()) {
            User aUser = [
                SELECT Id, Email
                FROM User
                WHERE id = :UserInfo.getUserId()
            ];
            currentUserEmail = aUser.Email;
        }

        List<Messaging.SingleEmailMessage> MailsToSend = new List<Messaging.SingleEmailMessage>();
        for (Integer li_counter = 0; li_counter < updatedOpps.size(); li_counter++) {
            System.debug('OpportunityTriggerHandler.updateOppLineItems() Get in only when CloseDate on Opportunity changed...');
            if (updatedOpps[li_counter].CloseDate != prevOpps[li_counter].CloseDate) {
                //************* PS FORECASTING - BEGIN *************
                System.debug('OpportunityTriggerHandler.updateOppLineItems() Check if the Opp has PS/FD schedule.');
                // Define List variable for Schedules to be updated
                //opportunityLineItemSchedule[] OppScheduleList = [SELECT o.Id, o.ScheduleDate FROM OpportunityLineItemSchedule o  WHERE (OpportunityLineItem.OpportunityId = :updatedOpps[li_counter].Id) AND ((o.OpportunityLineItem.Prod_fly__c LIKE 'PS%') OR (o.OpportunityLineItem.Prod_fly__c LIKE 'FD%')) ORDER BY ScheduleDate];

                //If the month was changed on the Close Date, update the related Opportunity Line Items
                if ((updatedOpps[li_counter].CloseDate.month() != prevOpps[li_counter].CloseDate.month()) || (updatedOpps[li_counter].CloseDate.year() != prevOpps[li_counter].CloseDate.year())) {
                    Integer li_months_between = prevOpps[li_counter].CloseDate.monthsBetween(updatedOpps[li_counter].CloseDate);
                    String strQuery = 'SELECT o.Id, o.ScheduleDate FROM OpportunityLineItemSchedule o WHERE (OpportunityLineItem.OpportunityId = \'' + updatedOpps[li_counter].Id;
                    strQuery += '\') AND ((o.OpportunityLineItem.Prod_fly__c LIKE \'' + sPS + '%\') OR (o.OpportunityLineItem.Prod_fly__c LIKE \'' + sFD + '%\')) ORDER BY ScheduleDate';
                    updateOppLineItemSchedule(strQuery, li_months_between);
                    ls_email_conclusion = '<br><br> The schedule has been updated.';
                }

            }
        }
    }

    private static void updateQuotaCredits(List<Opportunity> updatedOpps, Map<Id, Opportunity> prevOpps) {
        //Start building a Map of Opp Ids to Com Splits
        Map<Id, List<Com_Splits__c>> mapOppIdToComSplits = new Map<Id, List<Com_Splits__c>>();
        //Set<Id> setUpdatedOppIds = new Set<Id>();
        for (Opportunity o1 : updatedOpps) {
            //setUpdatedOppIds.add(o1.Id);
            mapOppIdToComSplits.put(o1.Id, new List<Com_Splits__c>());
        }
        System.debug('OpportunityTriggerHandler.updateQuotaCredits() - 1.mapOppIdToComSplits: ' + mapOppIdToComSplits);

        //Get a List of Com Splits for the current Opps
        //Com_Splits__c[] OCom_SplitsList = [SELECT Id, Employee_Name__c FROM Com_Splits__c  WHERE Opportunity__c in :setUpdatedOppIds AND RecordType.Name = 'Direct Master Credit'];
        for (Com_Splits__c cs : [SELECT Id, Employee_Name__c, Opportunity__c FROM Com_Splits__c WHERE Opportunity__c IN :mapOppIdToComSplits.keySet() AND RecordType.Name = 'Direct Master Credit']) {
            mapOppIdToComSplits.get(cs.Opportunity__c).add(cs);
        }
        System.debug('OpportunityTriggerHandler.updateQuotaCredits() - 2.mapOppIdToComSplits: ' + mapOppIdToComSplits);

        //for(Integer li_counter = 0; li_counter < updatedOpps.size(); li_counter++)
        List<Com_Splits__c> csToUpdate = new List<Com_Splits__c>();
        for (Opportunity opp : updatedOpps) {
            //if(updatedOpps[li_counter].OwnerId != prevOpps[li_counter].OwnerId && updatedOpps[li_counter].isClosed == false) {
            if (opp.OwnerId != prevOpps.get(opp.Id).OwnerId && opp.isClosed == false) {
                /************* QUOTA CREDITS - BEGIN *************/
                System.debug('OpportunityTriggerHandler.updateQuotaCredits() the Opp Owner changed to ' + opp.Owner);

                // Define List variable for employee names of the direct quotas to be updated
                //Com_Splits__c[] OCom_SplitsList = [SELECT Id, Employee_Name__c FROM Com_Splits__c  WHERE Opportunity__c = :updatedOpps[li_counter].Id AND RecordType.Name = 'Direct Master Credit'];

                // The following condition checks if there's any schedule records to be updated; otherwise, the subsequent statement would fail with there's no sObject for assignment.
                //if(OCom_SplitsList.size() > 0) {
                List<Com_Splits__c> listCS = mapOppIdToComSplits.get(opp.Id);

                if (listCS.size() > 0) {
                    System.debug('OpportunityTriggerHandler.updateQuotaCredits() Opp has quota credit records..');

                    // Adjust month of the schedule date to whatever the difference is in changed Opp Close Date
                    //for(Integer li_OCom_Splits_counter = 0; li_OCom_Splits_counter < OCom_SplitsList.size(); li_OCom_Splits_counter++){
                    for (Integer li_OCom_Splits_counter = 0; li_OCom_Splits_counter < listCS.size(); li_OCom_Splits_counter++) {
                        listCS[li_OCom_Splits_counter].Employee_Name__c = opp.OwnerId;
                    }
                    csToUpdate.addAll(listCS);

                    System.debug('OpportunityTriggerHandler.updateQuotaCredits() Update the new owner on opp to Quota Credits ');
                    //update OCom_SplitsList;
                }
                /************* QUOTA CREDITS - END *************/
            }
        }

        if (csToUpdate.size() > 0) {
            update csToUpdate;
        }
    }


    private static void updateOLIWhenTermMonthsChanged(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        System.debug('OpportunityTriggerHandler.isCurrentFY() updateOLIWhenTermMonthsChanged: ' + newList);
        Set<Id> setOppId = new Set<Id>();
        Map<Id, OpportunityLineItem> map_OppLineItem = new Map<Id, OpportunityLineItem>();

        for (opportunity opp : newList) {
            if (opp.Term_Estimate_Months__c != oldMap.get(opp.Id).Term_Estimate_Months__c) {
                setOppId.add(opp.id);
            }
        }

        if (!setOppId.isEmpty()) {
            List<OpportunityLineItem> oppLineItems = [Select Id,OpportunityId from OpportunityLineItem where OpportunityId IN:setOppId];
            // we're updating OLIs to trigger rollup for commission values
            if (!oppLineItems.isEmpty()) {
                update oppLineItems;
            }
        }
    }

    private static void getChangeOrderOLIsForDelete(Map<Id, Opportunity> mapClosedOpps) {
        System.debug('OpportunityTriggerHandler.getChangeOrderOLIsForDelete() mapClosedOpps' + mapClosedOpps);
        //For the ones with OLIs pushed to the parent, get the OLI records to send for deletion
        List<OpportunityLineItem> listOLIs = [
            SELECT Id, CR_Line_Item_Added_To_Parent__c, OpportunityId, Opportunity.Order_Number__c
            FROM OpportunityLineItem
            WHERE OpportunityId IN :mapClosedOpps.keySet()
        ];

        System.debug('OpportunityTriggerHandler.getChangeOrderOLIsForDelete() - listOLIs: ' + listOLIs);

        Boolean isSuccess = deleteChangeOrderOLIsOnParentOpportunity(listOLIs);
        System.debug('OpportunityTriggerHandler.getChangeOrderOLIsForDelete() isSuccess' + isSuccess);
        //If successful, send a notice to PS Operations
        if (isSuccess) {
            //Notify PS
            List<String> toAddr = new String[]{
                Label.CR_Opps_EmailNoticeAddress
            };
            String mailSubj = Label.CR_Opp_EmailNoticeSubject;
            String processName = Label.CR_Opp_EmailNoticeProcessName;
            String action = Label.CR_Opp_EmailNoticeNextAction;
            sendCRTOParentEmailNotice(toAddr, mailSubj, processName, mapClosedOpps.values());
        }

    }

    private static void createProjectFromOpportunity(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap) {
        List<Opportunity> validOpptysForProjectCreation = new List<Opportunity>();
        for (Opportunity oppty : newMap.values()) {
            if (oppty.Pushed_to_OpenAir__c == true && oldMap.get(oppty.id).Pushed_To_OpenAir__c != true && oppty.SF_Project_Already_Created__c != true) {
                oppty.SF_Project_Already_Created__c = true;
                validOpptysForProjectCreation.add(oppty);
            }
        }

        List<Project__c> projectsToInsert = new List<Project__c>();
        for (Opportunity oppty : validOpptysForProjectCreation) {
            Project__c prj = new Project__c();
            prj.Account__c = oppty.AccountId;
            prj.Opportunity__c = oppty.id;
            prj.Name = oppty.Name;
            prj.Active_Project__c = true;
            projectsToInsert.add(prj);
        }

        //insert the new project
        if (projectsToInsert.size() > 0) {
            insert projectsToInsert;
        }
    }

    private static void sendCRTOParentEmailNotice(List<String> toAddresses, String mailSubject, String processName, List<Opportunity> crOppsList) {
        //Use format below to populate the List of toAddresses
        //List<String> toAddr = Label.Apex_Error_Emails.split(';');

        //Verify there is available email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending this email
        Boolean bNoEmail = false;
        try {
            Messaging.reserveSingleEmailCapacity(1);
        } catch (Exception e1) {
            System.debug('OpportunityTriggerHandler.sendCRTOParentEmailNotice() In sendEmailErrorNotice, Error=' + e1.getTypeName() + ' - ' + e1.getCause() + ': ' + e1.getMessage());
            bNoEmail = true;
        }

        if (!bNoEmail && crOppsList != null && !crOppsList.isEmpty()) {
            String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm();
            System.debug(LoggingLevel.FINE, 'OpportunityTriggerHandler.sendCRTOParentEmailNotice() sendEmailNoticeBasic function');
            System.debug('OpportunityTriggerHandler.sendCRTOParentEmailNotice() toAddresses = ' + toAddresses);
            System.debug('OpportunityTriggerHandler.sendCRTOParentEmailNotice()  mailSubject = ' + mailSubject);
            System.debug('OpportunityTriggerHandler.sendCRTOParentEmailNotice() processName = ' + processName);
            System.debug('OpportunityTriggerHandler.sendCRTOParentEmailNotice() RecordId = ' + crOppsList);

            //Create the email to send
            List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject(mailSubject);
            String sHTML = '';
            sHTML += 'Process Name: ' + processName;
            sHTML += '<br /><br />';
            for (Opportunity opp : crOppsList) {
                sHTML += '<a href=/' + sfdcUrl + '/' + opp.Id + '>' + opp.Name + '</a>';
                sHTML += '<br />';
            }
            sHTML += '<br />';
            sHTML += 'Sent by an automated process in Apex class OpportunityServices.sendCRTOParentEmailNotice()';
            mail.setHtmlBody(sHTML);
            mailToSend.add(mail);

            //Send the email
            try {
                Messaging.sendEmail(mailToSend, false);
            } catch (Exception e2) {
                System.debug('OpportunityTriggerHandler.sendCRTOParentEmailNotice() Error sending email: ' + e2.getTypeName() + ' - ' + e2.getCause() + ': ' + e2.getMessage());
            }
        }
    }

    //G.B 14.03.2013 extend sendErrorEmailFriendly methods
    private static void sendMassErrorsEmailFriendly(List<String> toAddresses, String mailSubject, String methodName, List<Exception> excpList) {
        //Use format below to populate the List of toAddresses

        //Verify there is available email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending this email
        Boolean bNoEmail = false;
        try {
            Messaging.reserveSingleEmailCapacity(1);
        } catch (Exception e1) {
            System.debug('OpportunityTriggerHandler.sendMassErrorsEmailFriendly() In sendEmailErrorNotice, Error=' + e1.getTypeName() + ' - ' + e1.getCause() + ': ' + e1.getMessage());
            bNoEmail = true;
        }

        if (excpList != null && !bNoEmail && !excpList.isEmpty()) {
            System.debug(LoggingLevel.FINE, 'OpportunityTriggerHandler.sendMassErrorsEmailFriendly() function');
            System.debug('OpportunityTriggerHandler.sendMassErrorsEmailFriendly() toAddresses = ' + toAddresses);
            System.debug('OpportunityTriggerHandler.sendMassErrorsEmailFriendly() mailSubject = ' + mailSubject);
            System.debug('OpportunityTriggerHandler.sendMassErrorsEmailFriendly() methodName = ' + methodName);

            //Create the email to send
            List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject(mailSubject);
            String sHTML = '';
            sHTML += 'Technical Details:<br />';
            sHTML += 'Errors have occurred in <b>' + methodName + '</b>.  See details below.';
            //with record Id <b>'+recordId+'</b>
            sHTML += '<br /><br />';
            for (Exception excp : excpList) {
                sHTML += excp.getTypeName() + ' - ' + excp.getCause() + ': ' + excp.getMessage();
                sHTML += '<br />';
            }
            sHTML += '<br />';
            sHTML += 'Sent by an automated process in Apex class OpportunityServices.sendMassErrorsEmailFriendly()';
            mail.setHtmlBody(sHTML);
            mailToSend.add(mail);

            //Send the email
            try {
                Messaging.sendEmail(mailToSend, false);
            } catch (Exception e2) {
                System.debug('OpportunityTriggerHandler.sendMassErrorsEmailFriendly() Error sending email: ' + e2.getTypeName() + ' - ' + e2.getCause() + ': ' + e2.getMessage());
            }
        }

    }

    private static Boolean isCurrentFY(date closeDate) {
        Boolean currentFY = false;
        date currentDate = Date.today();
        Integer day = currentDate.day();
        Integer month = currentDate.month();
        Integer year = currentDate.year();
        Date startDate;
        Date endDate;

        if (month >= 6) {
            startDate = Date.newInstance(year, 6, 1);
            endDate = Date.newInstance(year + 1, 5, 31);
        }
        if (month <= 5) {
            startDate = Date.newInstance(year - 1, 6, 1);
            endDate = Date.newInstance(year, 5, 31);
        }
        System.debug('OpportunityTriggerHandler.isCurrentFY() startDate = ' + startDate);
        System.debug('OpportunityTriggerHandler.isCurrentFY() endDate = ' + endDate);

        if (closeDate >= startDate && closeDate <= endDate) {
            currentFY = true;
        }
        System.debug('OpportunityTriggerHandler.isCurrentFY() currentFY = ' + currentFY);

        return currentFY;
    }

    private Decimal getValue(Decimal fieldValue) {
        return (fieldValue == null ? 0 : fieldValue);
    }
}