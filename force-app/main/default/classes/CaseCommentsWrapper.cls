public with sharing class CaseCommentsWrapper {
	
	public string createdByName {get; set;}
	public datetime createdDate {get; set;}
	public string commentBody { get{
			return commentBody;
		} set{
			commentBody = lineBreaks(value); 
		}
	}

	public CaseCommentsWrapper() {
		
	}

	private string lineBreaks(string inText)
	{
	   if (inText == null)
	       return '';
	   else {
	   		system.debug('replace breaks');
	   		return inText.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>');
	   }

	       
	}
}