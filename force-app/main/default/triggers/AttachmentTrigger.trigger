trigger AttachmentTrigger on Attachment (after insert, before delete) {

	if(Trigger.IsBefore)
	{
		if(Trigger.isDelete)
		{
			//call method to update a flag field if attachments are deleted from an Issue Case
			AttachmentTriggerMethods.IssueCaseAttachmentIndicator(Trigger.old, 'Delete');
		}
	}
	
	if(Trigger.isAfter)
	{
		if(Trigger.IsInsert)
		{
			//call method to insert case comment for list of attachments
			//AttachmentTriggerMethods.addCaseCommentAndNotify(Trigger.new);  //Deactivated - use addAttachmentNotifyLog method below instead
			
			//call method to log the new attachment in the Process Log if it comes from a Customer Portal user
			AttachmentTriggerMethods.addAttachmentNotifyLog(Trigger.new);
			
			//call method to update a flag field if new attachments are added to an Issue Case
			AttachmentTriggerMethods.IssueCaseAttachmentIndicator(Trigger.new, 'Insert');
			
			//Call method for creating an attachment to the contract record if the attachment is on DocuSign Status object.
			AttachmentTriggerMethods.createContractAttachment(trigger.newMap);
		}
	}
}