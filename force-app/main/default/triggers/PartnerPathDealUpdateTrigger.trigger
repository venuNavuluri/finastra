/*
    Trigger : PartnerPathDealUpdateTrigger
    Description: This is a trigger on opportunity  which makes the future call to the partnerpath REST APIs.
                 All the partnerpath REST API calls after opportunity is created or later updated are made from this trigger.
    Parameters: NA
    Return: String - recordtypeId
    CreatedBy: Komal Karnawat
*/
trigger PartnerPathDealUpdateTrigger on Opportunity(after insert,after update) {
    if(label.PartnerPathDealUpdateTrigger_Switch.EqualsIgnoreCase('TRUE')){
        List<Id> partnerPathOppList = new List<Id>();
        //To filter the partner opportunities based on partner path Id and the opp record type
        For(Opportunity oppObj: Trigger.new){
            if(oppObj.RecordTypeId == IdManager.OPP_LicensesWithWithoutPSRecTypeId && !String.isEmpty(oppObj.PartnerPath_ID__c))
            partnerPathOppList.add(oppObj.Id);
        }
        if(partnerPathOppList.size()>0){
            //To make a synchronous call to PartnerPath if the opportunity update is called from a Batch Apex.
            if(System.isBatch() || System.isFuture()){
                system.debug('PartnerPathDealUpdateTrigger :: Called from Batch Apex to update PartnerPath deal synchronously');
                /*This method is called when the pearl proposal is pushed to sfdc via Batch Apex. 
                  Currently this is commented as Opportunity and OLI coming from pearl are heavy and this is a synchronous callout 
				  to PartnerPath, due to which sfdc bach apex performance will be slowed down.
				*/
                
            	//PartnerPathRESTIntegration.sendOppDetailsToPPSync(trigger.new);
        	}
            else{
                //To call the future method sendOppDetailsToPartnerPathOnOppCreate after partner opportunity creation
                if(trigger.isAfter && trigger.isInsert){
                    system.debug('PartnerPathDealUpdateTrigger :: To call the update deal on opp creation');
                    PartnerPathRESTIntegration.sendOppDetailsToPartnerPathOnOppCreate(partnerPathOppList);
                }
                //To call the future method sendOppDetailsToPartnerPathOnOppUpdate after partner opportunity updation
                if(trigger.isAfter && trigger.isUpdate){
                    system.debug('PartnerPathDealUpdateTrigger :: To call the update deal on opp updation');
                    PartnerPathRESTIntegration.sendOppDetailsToPartnerPathOnOppUpdate(partnerPathOppList);
                }
            }
        }
    }
}