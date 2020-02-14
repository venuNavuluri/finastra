global class AttachmentWrapper {
	public string AttachmentName {get; set;}
	public string AttachmentId {get; set;}
	public string CreatedById {get; set;}
	public string CreatedByName {get; set;}
	public datetime LastModifiedDate {get; set;}
	public string LastModifiedById {get; set;} 
	public integer BodyLength {get; set;}

	public AttachmentWrapper() {
		
	}
}