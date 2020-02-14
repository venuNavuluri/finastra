public with sharing class CaseEmailInBoundUtilities {

    public Case theCase = null;
    public string supportEmail = null;
    public Boolean severalContacts = false;
    public Contact contactName = null;
    public Id productSet = null;
    public Messaging.InboundEmail inboundEmail;
    private Map<String, Constants__c> generalContants {get; set;}
    private Map<String, RecordType_Info__c> allRecordType {get; set;}


    public CaseEmailInBoundUtilities() 
    {  
        List<RecordType_Info__c> selectRecordType  = [select Id, Name, Case_origin__c, Support_email__c from RecordType_Info__c where Support_email__c != ''];
        
        if (selectRecordType.size() > 0)
        {
            allRecordType = new Map<String, RecordType_Info__c>();
        
            for (RecordType_Info__c key : selectRecordType)
            {
                string keySE = key.Support_email__c.substring(0,key.Support_email__c.indexOf('@'));
                allRecordType.put(keySE,key);
            }
        }
        System.debug(allRecordType);    
    }

    public Messaging.InboundEmailResult processInboundEmail(Messaging.InboundEmail email)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try
        {
            result.success = false;          
            this.inboundEmail = email;
            
            if (SearchForCase() == true)
            {
                createEmailMessage(theCase,email);
                result.success = true;
            }
            else
            {
                if (GetRecordType() && GetAccountContact())
                {
                    if (CreateCase())
                    {
                        createEmailMessage(theCase,email);
                        
                        if (severalContacts == true)
                        {
                             CaseComment sevContactComment = new CaseComment(
                                                              IsPublished = false,
                                                              ParentId    = theCase.Id,
                                                              CommentBody = inboundEmail.FromAddress + ' has been assigned to several accounts.'); 
                             insert sevContactComment;
                        }
                        result.success = true;
                    }
                }
                else
                {
                    result.message = 'Oops, I failed.';  
                }
            }
        }
        catch (Exception e)
        {
          result.message = 'Oops, I failed.';         
          system.debug('CaseEmailInBoundUtilities. processInboundEmail: '+ e.getMessage());
        }
        return result;
    }
    
    public Boolean SearchForCase()
    {
        system.debug('CaseEmailInBoundUtilities. SearchForCase.  Starting...');
        return SearchByThreadIDOrCaseNumber(inboundEmail.subject);
    }


    public Boolean GetAccountContact()
    {
        contactName = null;
        try
        {
            system.debug('CaseEmailInBoundUtilities. GetAccountContact. FromAddress: "' + inboundEmail.FromAddress + '"');
            string[] domain = inboundEmail.FromAddress.split('@');
            if(domain[1].contains('misys.com') == false)
            {
                Contact[] allContacts = [select Id, Name, Account.Id from Contact where Inactive_Contact__c = false and (Alternative_Email__c = :inboundEmail.FromAddress or email = :inboundEmail.FromAddress)];
                system.debug('CaseEmailInBoundUtilities. GetAccountContact. Number of contacts: ' + allContacts.size());
                    
                if (allContacts.size() == 0)
                {
                    // function for checking account with domain
                    return false;
                }
                                             
                if (allContacts.size() > 1)
                {
                    severalContacts = true;
                }

                Set<Id> records = new Set<Id>();
                for (integer index = 0; index < allContacts.size (); index++)
                {
                    records.add(allContacts[index].Account.Id);
                    system.debug('CaseEmailInBoundUtilities. GetAccountContact. Account: ' + allContacts[index].Account.Id);                        
                }

                Id recordToValidate = allRecordType.get(supportEmail).Name;
                system.debug('CaseEmailInBoundUtilities. GetActiveProductSets. record type to validate: '+ recordToValidate );        
                
                List<ProductSetToRecordTypeId__c> allPdtRecords = ProductSetToRecordTypeId__c.getAll().values();
                system.debug('CaseEmailInBoundUtilities. GetActiveProductSets. Number of associations record type-product sets: '+allPdtRecords.size());        
             

                            
                Set<String> pdtRecords = new Set<String>();            
                for (ProductSetToRecordTypeId__c key : allPdtRecords)
                {
                    if (key.Record_Type_Id__c == recordToValidate)
                    {
                        pdtRecords.add(key.ExternalId__c);
                        system.debug('CaseEmailInBoundUtilities. GetActiveProductSets. Record type set: ' + key.RecordType_Name__c + ': ' +key.Record_Type_Id__c + ': external ID: ' + key.ExternalId__c);
                    }
                }  
                if (pdtRecords.size () == 0)
                {
                    system.debug('CaseEmailInBoundUtilities. GetActiveProductSets. No product set associated to this record type');
                    return false;
                }
                Product_Set__c[] allProductSets = [select Id, Name,Account__r.Id from Product_Set__c where Name in :pdtRecords and EmailToCase_Enabled__c = true and Account__r.Id in :records ];        
        
                system.debug('CaseEmailInBoundUtilities. GetActiveProductSets. Number of Product Sets: ' + allProductSets.size() +' :' + allProductSets );
                if (allProductSets.size() > 1)
                {
                    return true;
                }
                if (allProductSets.size() == 1)
                {
                    for (integer index = 0; index < allContacts.size (); index++)
                    {
                        if (allContacts[index].Account.Id == allProductSets[0].Account__r.Id)
                        {
                            contactName = allContacts[index];
                            productSet = allProductSets[0].Id;
                            system.debug('CaseEmailInBoundUtilities. GetAccountContact. Account: ' + allContacts[index].Account.Id);     
                            return true;                   
                        }
                    }               
                }           
                return false;
            }
            else
            {
                return true;
            }
        }
        catch (Exception e) 
        {
          system.debug(Logginglevel.ERROR,'CaseEmailInBoundUtilities. GetAccountContact. Unable to identify the account/contact:' + e.GetMessage());
        }

        return false;        
    }
   
    public Boolean GetRecordType()
    {
        try
        {
            system.debug('CaseEmailInBoundUtilities. GetRecordType. toAddresses: "' + inboundEmail.toAddresses+ '"');
            system.debug('CaseEmailInBoundUtilities. GetRecordType. ccAddresses: "' + inboundEmail.ccAddresses+ '"');

            for(string toEmail : inboundEmail.toAddresses) 
            {
                string emailPart1 = toEmail.substring(0,toEmail.indexOf('@'));
                system.debug('CaseEmailInBoundUtilities. GetRecordType. toEmail : ' + toEmail + '. Supportemail: ' + emailPart1);
                if (allRecordType.containsKey(emailPart1) == true)
                {
                    supportEmail = emailPart1;
                    system.debug('CaseEmailInBoundUtilities. GetRecordType. Support email: ' + supportEmail);
                    return true;
                }
            }

            for(string ccEmail : inboundEmail.ccAddresses) 
            {
                string emailPart1 = ccEmail.substring(0,ccEmail.indexOf('@'));
                system.debug('CaseEmailInBoundUtilities. GetRecordType. ccEmail : ' + ccEmail + '. Supportemail: ' + emailPart1);
                if (allRecordType.containsKey(emailPart1) == true)
                {
                    supportEmail = emailPart1;
                    system.debug('CaseEmailInBoundUtilities. GetRecordType. Support email: ' + supportEmail);
                    return true;
                }
            }
            return false;
        }
        catch (Exception e)
        {
          system.debug(Logginglevel.ERROR,'CaseEmailInBoundUtilities. GetRecordType. Unable to identify the record type: '+ e.getMessage());
          return false;
        }
    }

    public Boolean CreateCase()
    {
        generalContants = Constants__c.getAll();

        this.theCase = new Case();
        // Case record type.
        theCase.RecordTypeId = allRecordType.get(supportEmail).Name;

        // Product set
        theCase.Product_Set__c = productSet;

        // Assign to 
        //theCase.Assigned_To__c = '00520000001lSm';

        // Case category ==> Support Request  ==> No=> No need to set it up. Default is 'Support Request'

        // Type ==>  Question
        theCase.Type = generalContants.get('DEFAULT_CS_TYPE').Value__c;

        // Case status
        theCase.Status = generalContants.get('DEFAULT_STATUS').Value__c;

        // Sub-Status = 'Awaiting Triage'
        theCase.Sub_Status__c = generalContants.get('DEFAULT_SUB_STATUS').Value__c;

        // Workaround provided ==> No=> No need to set it up. Default is 'No'

        // System status ==> Live
        theCase.System__c = generalContants.get('DUMMY SYSTEM ID').Value__c;
        theCase.Support_Entitlement__c = null;
        theCase.Project__c = null;

        // Case priority
        theCase.Priority = generalContants.get('DEFAULT_PRIORITY').Value__c;

        // Case severity
        theCase.Severity__c = generalContants.get('DEFAULT_SEVERITY').Value__c;

        // Case internal severity
        theCase.Internal_Severity__c = generalContants.get('DEFAULT_INTERNAL_SEVERITY').Value__c;

        // Urgency
        theCase.Urgency__c = generalContants.get('DEFAULT_URGENCY').Value__c;

        // Case origin
        theCase.Origin = allRecordType.get(supportEmail).Case_origin__c;

        // Case contact name
        if (contactName != null)
        {
            theCase.ContactId = contactName.Id;          
        }

        // Subject
        theCase.Subject = inboundEmail.Subject;
        // Description
        theCase.Description = inboundEmail.plainTextBody;

        theCase.SuppliedEmail = inboundEmail.fromAddress;
        theCase.SuppliedName = inboundEmail.fromName;

        system.debug('CaseEmailInBoundUtilities. fromAddress: ' + inboundEmail.fromAddress);
        system.debug('CaseEmailInBoundUtilities. fromName: ' + inboundEmail.fromName);
try{
        insert this.theCase;
}
catch(Exception e)
{
System.debug('The following exception has occurred: ' + e.getMessage());
}
        return true;
    }

    // Save attachments, if any
    public void handleAttachments(EmailMessage theEmail, Messaging.InboundEmail email)
    {
        if(email.textAttachments!=null && email.textAttachments.size() >0)
        {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments)
            {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = theEmail.Id;
                insert attachment;
            }
        }

        if(email.binaryAttachments!=null && email.binaryAttachments.size() >0)
        {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments)
            {
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = theEmail.Id;
                insert attachment;
            }
        } 
    }

    public String limitLength(String input, Integer maxLength)
    {
        String results;
        if(input != null && input.length() > maxLength)
            results = input.substring(0,maxLength);
        else
            results = input;
        return results;
    }

    public void createEmailMessage(Case theCase, Messaging.InboundEmail email)
    {
        String value;
        Integer maxlength;
        EmailMessage theEmail = new EmailMessage();
        theEmail.ParentId = theCase.Id;
        theEmail.Incoming = true;
        Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
        maxlength = F.getLength();
        theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = limitLength(email.htmlBody,EmailMessage.HtmlBody.getDescribe().getLength());
        theEmail.TextBody = limitLength(email.plainTextBody,EmailMessage.TextBody.getDescribe().getLength());

        /* **** To */
        value = '';
        if(email.toAddresses != null)
        {
            Boolean seenOne= false;
            for(String to : email.toAddresses)
            {
                if(seenOne)
                {
                    value += ';\n';
                }
                to  = (to);
                system.debug('ToAddress: ' + to);
                value += to;
                seenOne = true;
            }
        }
        theEmail.ToAddress = limitLength(value,EmailMessage.ToAddress.getDescribe().getLength());

        /* **** From */
        theEmail.FromName = email.fromName;
        theEmail.FromAddress = email.fromAddress;

        /* **** CC */
        value = '';
        if(email.ccAddresses != null)
        {
            Boolean seenOne= false;
            for(String cc : email.ccAddresses)
            {
                if(seenOne)
                {
                    value += ';\n';
                }
                cc  = extractAddress(cc);
                system.debug('CcAddress: ' + cc);
                value += cc;
                seenOne = true;
            }
        }
        theEmail.CcAddress = limitLength(value,EmailMessage.CcAddress.getDescribe().getLength());

        insert theEmail;
        
        handleAttachments(theEmail, email);
    }

    /*
    Look for the case reference in the email subject line.  First search for a case reference using the
    standard Salesforce method of creating that complicated and non-user-friendly reference.  Do this first
    so it takes precedence.

    But, also search for the case number itself. This is user-friendly!
    */
    public Boolean SearchByThreadIDOrCaseNumber(String emailSubject)
    {
        String itemRef = null;
        String target = emailSubject.toLowerCase();
        Pattern thePattern;
        Matcher matcher;

        system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Email Subject ' + target);
        
        /*  Take the text between the period and ":ref"  For example in the ref [ ref:00D7JFzw.5007H3Rh8:ref ] extract 5007H3Rh8
        Take that text and remove the 5007. For example H3Rh8 
        Append H3Rh8 to https://na5.salesforce.com/5007000000  to produce https://na5.salesforce.com/5007000000H3Rh8.   This is your link to get to the case.
        */  
        thePattern = Pattern.compile('.*ref:(.{23}):ref.*');
        matcher = thePattern.matcher(emailSubject); // do not change to lower case for this test because Id's are case sensitive

        if (matcher.matches())
        {
            system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Search by thread ID');
            ID caseID = cases.getCaseIdFromEmailThreadId(matcher.group(1));
            if (caseID != null)
            {
                system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: "' + caseID + '"');
                Case[] matchingCases = [Select id, CaseNumber from Case where Id = :caseId];
                if(matchingCases.size() == 1)
                {
                    this.theCase = matchingCases[0];
                    itemRef = this.theCase.CaseNumber;
                    system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Extracted case number ' + itemRef);
                    return true;
                }
                else
                {
                    system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Could not find case by Thread ID');
                }
            }
        }
        if(itemRef == null) 
        {
            system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Search by case Number');
            // extract the Case Number from the email Subject
            thePattern = Pattern.compile('.*\\s*([0-9]{8}).*');
            matcher = thePattern.matcher(target);
            if (matcher.matches()) 
            {
                itemRef = matcher.group(1);
                system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Extracted case number ' + itemRef);
                Case[] matchingCases = [Select id, CaseNumber from Case where CaseNumber = :itemRef];
                if(matchingCases.size() == 1)
                {
                    this.theCase = matchingCases[0];
                    itemRef = this.theCase.CaseNumber;
                    system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Extracted case number ' + itemRef);
                    return true;
                } 
                else
                {
                    system.debug('CaseEmailInBoundUtilities. SearchByThreadIDOrCaseNumber: Could not find case by case number');
                }
            }
        }
        return false;
    }

    public String extractAddress(String inAddress)
    {
        String address;
        String patternString;
        Pattern thePattern;
        Matcher matcher;
        patternString = '.*<(.*)>.*';
        thePattern = Pattern.compile(patternString);
        matcher = thePattern.matcher(inAddress);
        if (matcher.matches())
        {
            address = matcher.group(1);
            system.debug('Extracted address ' + address);
        }
        else
        {
            address = inAddress;
            system.debug('Did not match angle-address ' + address);   
        }
        return address;
    }
}