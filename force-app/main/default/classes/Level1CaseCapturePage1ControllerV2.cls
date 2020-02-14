public with sharing class Level1CaseCapturePage1ControllerV2 {
public String CustomerSearch{get; set;}
    public String ContactSearch{get; set;}
    public Boolean ExactCustomerMatch{get; set;}
    public Boolean NoSearchAlertDisplay{get; set;}
    public Boolean ShowSearchResults{get; set;}
    public Boolean NoCustSelectAlertDisplay{get; set;}
    public Boolean TooManySelectAlertDisplay{get; set;}
    public List<ContactWrapper> SearchContacts{get; set;}
    public Case CustomersCase{get; set;}
    public ContactWrapper SelectedContact{get; set;}
    public Boolean ShowCustomerCases{get; set;} 
    public List<CaseWrapper> existingCustomerCases{get; set;}
    public Boolean TooManyContSelectedDisplay{get; set;}
    public Boolean NoCaseSelectAlertDisplay{get; set;}
    public Boolean TooManyCaseSelectAlertDisplay{get; set;}
    public Boolean TooManyContToEditSelectedDisplay{get; set;}
    public Boolean NoContToEditSelectedDisplay{get; set;}
    public SessionInfo CurrentSessionInfo {get; set;} 
    public ID SelectedContactID {get; set;}
 //   public Boolean IncludeLegacyID {get; set;}
    public PageReference ipr_redirect{get; set;}
    // AC 1/Jul/09 - Paging 
    public Integer currentPage        {get; set;}
    public Integer totalNumberPages   {get; set;}
    public Integer totalNumberRecords {get; set;}
    public Integer rowsPerPage        {get; set;} {rowsPerPage = 25;}
    public List<ContactWrapper>       SearchContactsFullDataSet{get; set;}
    public List<ContactWrapper>       CurrentPageDataSet       {get; set;}
    public Long elapsedTime {get; set;}
    
    private boolean firstTime {get; set;}

	public Level1CaseCapturePage1ControllerV2(ApexPages.StandardController std){
		this();
	}
	
    public Level1CaseCapturePage1ControllerV2(){
        SearchContacts = new List<ContactWrapper>();
        ShowSearchResults = false;
        NoSearchAlertDisplay = false;
        NoCustSelectAlertDisplay = false;
        TooManySelectAlertDisplay = false;
        CustomersCase = new Case();
        ShowCustomerCases = false;
        existingCustomerCases = new List<CaseWrapper>();
        TooManyContSelectedDisplay = false;
        NoCaseSelectAlertDisplay = false;
        TooManyCaseSelectAlertDisplay = false;
        TooManyContToEditSelectedDisplay = false;
        NoContToEditSelectedDisplay = false;
        ExactCustomerMatch = false;
        firstTime = true;
//        IncludeLegacyID = false;

        CurrentSessionInfo = new SessionInfo();

/* PB(12/17) : 
        //DW 02/02/09 Enhancement Request Change
        if(ApexPages.currentPage().getParameters().get('enreq') != null){
            currentSessionInfo.IsEnhancementRequest = true;
        }else{
            currentSessionInfo.IsEnhancementRequest = false;
        }
*/
        if(CurrentSessionInfo.InPortal){
            CurrentSessionInfo.setUser();
            SearchCustomers();
           // ipr_redirect = SearchCustomers();
          //  Return ipr_redirect;
        }/*else if(ApexPages.currentPage().getParameters().get('def_contact_id') != null){
			SearchCustomers();
		}*/
      //  Return null;
    }
	
	public PageReference ForwardOn(){
	  if(ipr_redirect != null){

            PageReference p = ipr_redirect;
            return p;
        }else{
            return null;
        }
	}
	 
	//Prash(11/17/2009)	:	Changed the Return type from Void to PR, so, the page can be redirected to Select record type when just one contact found.
    public PageReference SearchCustomers(){
        PageReference pr = null;
        Long startTime = System.currentTimeMillis();
        
        NoSearchAlertDisplay = false;
        existingCustomerCases = new List<CaseWrapper>();
        ShowCustomerCases = false;
        TooManyContSelectedDisplay = false;
        NoCustSelectAlertDisplay = false;
        TooManySelectAlertDisplay = false;
        SearchContacts = new List<ContactWrapper>();

		System.debug('XXX Level1CaseCapturePage1ControllerV2: SearchCustomers: contactId: ' + ApexPages.currentPage().getParameters().get('def_contact_id'));

        if(CustomerSearch == '' && ContactSearch == '' && CurrentSessionInfo.LoggedInContactId == null){
        	
            	NoSearchAlertDisplay = true;
        	
        }else{
            //Check for contact search being 10 digits, and if so format to phone number
            if(ContactSearch != null && ContactSearch != ''){
                try{
                    if(ContactSearch.length() == 10){
                        Long l = Long.valueOf(ContactSearch);
                        ContactSearch = '(' + ContactSearch.substring(0,3) + ') ' + ContactSearch.substring(3,6) + '-' + ContactSearch.substring(6,10);
                    }
                }catch(Exception e){
                    System.debug('XXXXXXXX: Input isnt an integer: ' + e.getMessage());
                }
            }

            String contactSearchValue = '%' + ContactSearch + '%';
            String customerSearchValue = '';

            if(ExactCustomerMatch){
                customerSearchValue = CustomerSearch;
            }else{
                customerSearchValue = '%' + CustomerSearch + '%';
            }
            
            boolean comingFromNewOverride = false;

            // AC 1/Jul/2009 - all queries limited at 1000 and prevent attempts to put more than 1000 records into SearchContacts
            //               - as recommended by Salesforce 
            if(CustomerSearch != null && ContactSearch != null && CustomerSearch != '' && ContactSearch != ''){
            	
			//PB(12/17) - Commented as LegcyId is not applicable for Banking and need to increase the code coverage	
          //      if(IncludeLegacyID){
                    // AC 6/Jul/09 - removed accountID != null check - on recommendation of Salesforce
         //           for(Contact contact : [Select c.Account.Id, c.AccountId, c.Account.AccountNumber, c.Account.Name, c.Id, c.Name, c.Phone, c.Email, c.Account.Site from Contact c where /*c.CS_Support_Contact__c = true and */ c.Inactive_Contact__c = false and /* c.AccountId != null and */ ((c.Name like :contactSearchValue or c.Phone like :contactSearchValue) and (c.Account.WS_Account_short_name__c like :customerSearchValue /* or c.Account.Legacy_Acct_ID__c like :customerSearchValue */ or  c.Account.Name like :customerSearchValue)) LIMIT 1000]){
          //              if (SearchContacts.size() < 1000) {
          //                SearchContacts.add(new ContactWrapper(contact,contact.Account)); 
          //              }
          //          }
         //       }else{
                	
         //       }
               
                    // AC 6/Jul/09 - removed accountID != null check - on recommendation of Salesforce
                    // PB 1/7/2010 - Added Duplicate_Check__c != 'Converted to SSO' check
                    for(Contact contact : [Select c.Account.Id, c.AccountId, c.Account.AccountNumber, c.Account.Name, c.Id, c.Name, c.Phone, c.Email, c.Account.Site from Contact c where c.Duplicate_Check__c != 'Converted to SSO' and  c.Inactive_Contact__c = false and /* c.AccountId != null and */ ((c.Name like :contactSearchValue or c.Phone like :contactSearchValue) and (c.Account.WS_Account_short_name__c like :customerSearchValue or c.Account.Name like :customerSearchValue)) LIMIT 1000]){
                        if (SearchContacts.size() < 1000) {
                            SearchContacts.add(new ContactWrapper(contact,contact.Account));
                        }
                    }

            //PB(12/17) - Commented as LegcyId is not applicable for Banking and need to increase the code coverage
               // if(IncludeLegacyID){
                 //   for(Accounts_Supported__c accountSupported : [Select a.Contact__c, a.Contact__r.Email, a.Contact__r.Id, a.Contact__r.Name, a.Contact__r.Phone, a.Supported_Account__c, a.Supported_Account__r.AccountNumber, a.Supported_Account__r.Id, a.Supported_Account__r.Name, a.Supported_Account__r.Site from Accounts_Supported__c a where ( /*a.Contact__r.CS_Support_Contact__c = true and */ a.Contact__r.Inactive_Contact__c = false and (a.Contact__r.Name like :contactSearchValue or a.Contact__r.Phone like :contactSearchValue) and (a.Supported_Account__r.WS_Account_short_name__c like :customerSearchValue /* or a.Supported_Account__r.Legacy_Acct_ID__c like :customerSearchValue */ or a.Supported_Account__r.Name like :customerSearchValue)) LIMIT 1000]){
                //        if (SearchContacts.size() < 1000) {
                  //          SearchContacts.add(new ContactWrapper(accountSupported.Contact__r,accountSupported.Supported_Account__r));
                //        }
              //      }
            //    }else{
                	
          //      }
                    for(Accounts_Supported__c accountSupported : [Select a.Contact__c, a.Contact__r.Email, a.Contact__r.Id, a.Contact__r.Name, a.Contact__r.Phone, a.Supported_Account__c, a.Supported_Account__r.AccountNumber, a.Supported_Account__r.Id, a.Supported_Account__r.Name, a.Supported_Account__r.Site from Accounts_Supported__c a where (/*a.Contact__r.CS_Support_Contact__c = true and*/ a.Contact__r.Inactive_Contact__c = false and (a.Contact__r.Name like :contactSearchValue or a.Contact__r.Phone like :contactSearchValue) and (a.Supported_Account__r.WS_Account_short_name__c like :customerSearchValue or a.Supported_Account__r.Name like :customerSearchValue)) LIMIT 1000]){
                        if (SearchContacts.size() < 1000) {
                            SearchContacts.add(new ContactWrapper(accountSupported.Contact__r,accountSupported.Supported_Account__r));
                        }
                    }
                

            }else if(ContactSearch != null && ContactSearch != ''){

                Set<Id> uniqueContactIDs =  new Set<Id>();
                Map<Id, Contact> contactMap = new Map<Id, Contact>();
				// PB 1/7/2010 - Added Duplicate_Check__c != 'Converted to SSO' check
                for(Contact contact : [Select c.Account.Id, c.AccountId, c.Account.AccountNumber, c.Account.Name, c.Id, c.Name, c.Phone, c.Email, c.Account.Site from Contact c where Duplicate_Check__c != 'Converted to SSO' and  c.Inactive_Contact__c = false and c.AccountId != null and (c.Name like :contactSearchValue or c.Phone like :contactSearchValue) LIMIT 1000]){
                    if (SearchContacts.size() < 1000) {
                        SearchContacts.add(new ContactWrapper(contact,contact.Account));
                        uniqueContactIDs.add(contact.Id);
                        contactMap.put(contact.Id, contact);
                    }
                }

                for(Accounts_Supported__c accountSupported : [Select a.Contact__c, a.Supported_Account__c, a.Supported_Account__r.AccountNumber, a.Supported_Account__r.Id, a.Supported_Account__r.Name, a.Supported_Account__r.Site from Accounts_Supported__c a where a.Contact__c in :uniqueContactIDs LIMIT 1000]){
                    if (SearchContacts.size() < 1000) {
                        SearchContacts.add(new ContactWrapper(contactMap.get(accountSupported.Contact__c),accountSupported.Supported_Account__r));
                    }
                }

            }else if((CustomerSearch != null && CustomerSearch != '') || (firstTime && ApexPages.currentPage().getParameters().get('def_account_id') != null && ApexPages.currentPage().getParameters().get('def_contact_id') == null)){

                Set<ID> uniqueAccountIDs = new Set<ID>();
                Map<ID,Account> accountMap = new Map<ID,Account>();
                

                //if(IncludeLegacyID){
                    //for(Account account : [Select Id,AccountNumber,Name, Site  from Account where WS_Account_short_name__c like :customerSearchValue /* or Legacy_Acct_ID__c like :customerSearchValue */ or Name like :customerSearchValue LIMIT 1000]){
                    //    uniqueAccountIDs.add(account.Id);
                  //      accountMap.put(account.Id,account);
                //    }
              //  }else{
                	
            //     }
            	
            	if(firstTime && ApexPages.currentPage().getParameters().get('def_account_id') != null){
            		firstTime = false;
            		for(Account account : [Select Id,AccountNumber,Name, Site  from Account where Id = :ApexPages.currentPage().getParameters().get('def_account_id') LIMIT 1000]){
            			CustomerSearch = account.Name;
                        uniqueAccountIDs.add(account.Id);
                        accountMap.put(account.Id,account);
                    }
            	}else{
                    for(Account account : [Select Id,AccountNumber,Name, Site  from Account where WS_Account_short_name__c like :customerSearchValue or Name like :customerSearchValue LIMIT 1000]){
                        uniqueAccountIDs.add(account.Id);
                        accountMap.put(account.Id,account);
                    }
            	}

                //
                //David Walshe 3/12
                //No contacts allowed for EOS
                //
                if(!CurrentSessionInfo.IsEmployeeOnSite){
                	// PB 1/7/2010 - Added Duplicate_Check__c != 'Converted to SSO' check
                    for(Contact contact : [Select Id, AccountId, Name, Phone, Email from Contact where Duplicate_Check__c != 'Converted to SSO' and Inactive_Contact__c = false and AccountId in :uniqueAccountIDs LIMIT 1000]){
                        if (SearchContacts.size() < 1000) {
                            SearchContacts.add(new ContactWrapper(contact,accountMap.get(contact.AccountId)));
                        }
                    }

                    for(Accounts_Supported__c accountSupported : [Select a.Contact__c,a.Supported_Account__c, a.Contact__r.AccountID, a.Contact__r.Name, a.Contact__r.Phone, a.Contact__r.Email from Accounts_Supported__c a where /* a.Contact__r.CS_Support_Contact__c = true and */ a.Contact__r.Inactive_Contact__c = false and a.Supported_Account__c in :uniqueAccountIDs LIMIT 1000]){
                        if (SearchContacts.size() < 1000) {
                            SearchContacts.add(new ContactWrapper(accountSupported.Contact__r,accountMap.get(accountSupported.Supported_Account__c)));
                        }
                    }
                //
                //David Walshe 3/12
                //Else just add each of the accounts for the search results
                //
                }else{

                    for(ID accountId : uniqueAccountIDs){
                        if (SearchContacts.size() < 1000) {
                            SearchContacts.add(new ContactWrapper(accountMap.get(accountId)));
                        }
                    }
                }
            }else if(CurrentSessionInfo.LoggedInContactId != null){
                Set<Id> uniqueContactIDs =  new Set<Id>();
                Map<Id, Contact> contactMap = new Map<Id, Contact>();
				// PB 1/7/2010 - Added Duplicate_Check__c != 'Converted to SSO' check
                for(Contact contact : [Select c.Account.Id, c.AccountId, c.Account.AccountNumber, c.Account.Name, c.Id, c.Name, c.Phone, c.Email, c.Account.Site from Contact c where Duplicate_Check__c != 'Converted to SSO' and c.Id= :CurrentSessionInfo.LoggedInContactId LIMIT 1000]){
                    if (SearchContacts.size() < 1000) {
                        SearchContacts.add(new ContactWrapper(contact,contact.Account));
                        uniqueContactIDs.add(contact.Id);
                        contactMap.put(contact.Id, contact);
                    }
                }

                for(Accounts_Supported__c accountSupported : [Select a.Contact__c, a.Supported_Account__c, a.Supported_Account__r.AccountNumber, a.Supported_Account__r.Id, a.Supported_Account__r.Name, a.Supported_Account__r.Site  from Accounts_Supported__c a where a.Contact__c in :uniqueContactIDs LIMIT 1000]){
                    if (SearchContacts.size() < 1000) {
                        SearchContacts.add(new ContactWrapper(contactMap.get(accountSupported.Contact__c),accountSupported.Supported_Account__r));
                    }
                }
            }else if(firstTime && ApexPages.currentPage().getParameters().get('def_contact_id') != null){
        		System.debug('XXX Level1CaseCapturePage1ControllerV2: SearchCustomers: In the first time area');
        		firstTime = false;
        		comingFromNewOverride = true;
        		Contact c = [Select c.Account.Id, c.AccountId, c.Account.AccountNumber, c.Account.Name, c.Id, c.Name, c.Phone, c.Email, c.Account.Site from Contact c where Duplicate_Check__c != 'Converted to SSO' and c.Id= :ApexPages.currentPage().getParameters().get('def_contact_id') LIMIT 1];
                SearchContacts.add(new ContactWrapper(c,c.Account));

                for(Accounts_Supported__c accountSupported : [Select a.Contact__c, a.Supported_Account__c, a.Supported_Account__r.AccountNumber, a.Supported_Account__r.Id, a.Supported_Account__r.Name, a.Supported_Account__r.Site  from Accounts_Supported__c a where a.Contact__c = :c.Id LIMIT 1000]){
                    if (SearchContacts.size() < 1000) {
                        SearchContacts.add(new ContactWrapper(c,accountSupported.Supported_Account__r));
                    }
                }
        	}

            // MOVE THIS TO AFTER WE HAVE BUILT THE CURRENTPAGEDATASET
            /* if(SearchContacts.size() == 1){
                SearchContacts[0].Selected = true;
                ContactSelected();
            }else 
            */
            
            if(SearchContacts.size() > 0){
                SearchContacts = ContactWrapper.SortItems(SearchContacts);
            }

            ShowSearchResults = true;

            // AC 1/Jul/09 - Changes for Paging
            currentPage        = 1;
            totalNumberPages   = (SearchContacts.size() / rowsPerPage) + 1;
            totalNumberRecords = SearchContacts.size();
            
            SearchContactsFullDataSet = SearchContacts;
            CurrentPageDataSet        = getPage(currentPage);

            if(SearchContacts.size() == 1){
                SearchContacts[0].Selected = true;
                ContactSelected();
                if(comingFromNewOverride){
	                pr = LogCase();
	             	pr.setRedirect(true);
                }
                // Prash(11/17/09)	:	When one search returns just one contact, redirect it to LAC page
              //  pr = LogCase();
             //	pr.setRedirect(true);

            
            }
        }
        elapsedTime = System.currentTimeMillis() - startTime;
		return pr;
    }

    // AC 1/Jul/09 - Added for Paging
    private List<ContactWrapper> getPage(Integer pageNumber) {

      for(ContactWrapper contWrap: SearchContactsFullDataSet){
        contWrap.selected = false;
      } 
      
      Integer startingPoint = (pageNumber-1) * rowsPerPage;
      List<ContactWrapper> thisPage = new List<ContactWrapper>();
      
      for (Integer i=startingPoint; i<rowsPerPage*pageNumber; i++) {
        if (i<SearchContactsFullDataSet.size()) {
          thisPage.add(SearchContactsFullDataSet[i]);
        }
      }
      
      return thisPage;      
    }

    // AC 1/Jul/09 - Added for Paging
    public PageReference getNextPage() {
      CurrentPageDataSet = getPage(++currentPage);
      ContactSelected(); // resets case section as page changes
      return null;  
    }

    // AC 1/Jul/09 - Added for Paging
    public PageReference getPreviousPage() {
      CurrentPageDataSet = getPage(--currentPage);
      ContactSelected(); // resets case section as page changes
      return null;  
    }

    public void ContactSelected(){
        if(!CurrentSessionInfo.InPortal){
            ShowCustomerCases = false;
            TooManyContSelectedDisplay = false;
            NoCustSelectAlertDisplay = false;
            TooManySelectAlertDisplay = false;
            existingCustomerCases = new List<CaseWrapper>();

            //Get the contact that is selected
            Integer selectedContacts = 0;
            ID selectedAccountID = null;

            // AC 1/Jul/09 - uses just the current page data set
            for(ContactWrapper contWrap: CurrentPageDataSet){
                if(contWrap.selected){
                    selectedContacts++;
                    SelectedContactID = contWrap.contact.Id;
                    selectedAccountID = contWrap.account.Id;
                }
            }

            if(selectedContacts > 1)
                TooManyContSelectedDisplay = true;
            //else if(selectedContacts == 1){
                //
                //David Walshe 3/12
                //For EOS we need to bring back all cases for the selected account
                //
                
                // AC 1/Jul/2009 - LIMIT 1000 
                //if(!CurrentSessionInfo.IsEmployeeOnSite){
                //    for(Case c : [Select c.RecordTypeId, c.priority, c.status, c.Description, c.CaseNumber, c.Subject from Case c where c.ContactId= :SelectedContactID and c.AccountId = :selectedAccountID and c.IsClosed = false LIMIT 1000]){
                //        //c.Select_a_Module_or_Area_of_Issue__c, c.Select_a_Product__c, c.Select_a_Service_Type__c,
                //        existingCustomerCases.add(new CaseWrapper(c));
                //    }
                //}else{
                //    //c.Select_a_Module_or_Area_of_Issue__c, c.Select_a_Product__c, c.Select_a_Service_Type__c,
                //    for(Case c : [Select c.RecordTypeId, c.priority, c.status, c.Description, c.CaseNumber,  c.Subject from Case c where c.AccountId = :selectedAccountID and c.IsClosed = false LIMIT 1000]){
                //        existingCustomerCases.add(new CaseWrapper(c));
                //    }
                //}
                ShowCustomerCases = true;
            //}
        }
    }

    public PageReference LogCase(){
        PageReference pageRef = null;
        NoCustSelectAlertDisplay = false;
        TooManySelectAlertDisplay = false;
        Integer selectedCount = 0;
        ContactWrapper selectedContact = null;

        // AC 1/Jul/09 - uses just the current page data set
        for(ContactWrapper searchContact: CurrentPageDataSet){
            if(searchContact.Selected){
                selectedCount++;
                selectedContact = searchContact;
            }
        }

        if(selectedCount == 0){
            NoCustSelectAlertDisplay = true;
            return null;
        }else if(selectedCount > 1){
            TooManySelectAlertDisplay = true;
            return null;
        }else{
            ///NoCustSelectAlertDisplay = true;

            //03/02/09 DW Create a string for the url, need to take into consideration enhancement requests too
            /*
            if(!CurrentSessionInfo.IsEmployeeOnSite){
                pageRef = new PageReference('/apex/Level1_Case_Capture_P2_V2?contactId=' + selectedContact.contact.Id + '&accountid=' + selectedContact.account.Id);
            }else{
                pageRef = new PageReference('/apex/Level1_Case_Capture_P2_V2?accountid=' + selectedContact.account.Id);
            }
            */
            
            // AC 7/Jul/09 - remove page hard-coding, as per Salesforce recommendation

            //String pageURL = '/apex/Level1_Case_Capture_P2_V2?';
            ///PageReference pr = Page.Level1_Case_Capture_P2_V2;   
            // PRASH - FIND THE BEST WAY TO GET THE NEW CASE URL at LEISURE
            //String pageURL = Label.NewCase_RecordType_Selection_URL_V2; //'https://cs2.salesforce.com/setup/ui/recordtypeselect.jsp?ent=Case&';
            String pageURL = Label.NewCase_Selection_URL_V2;      
            
            if(!CurrentSessionInfo.IsEmployeeOnSite){
                //pr.getParameters().put('contactId', selectedContact.contact.Id);
                //pr.getParameters().put('accountid', selectedContact.account.Id);
                pageURL = pageURL + 'contactid=' + selectedContact.contact.Id + '&accountId=' + selectedContact.account.Id; // PB - added Save URL
            }else{
                pageURL = pageURL + 'accountid=' + selectedContact.account.Id;
                //pr.getParameters().put('accountid', selectedContact.account.Id);
            }

		/* PB(12/17)
            if(CurrentSessionInfo.IsEnhancementRequest){
                //pr.getParameters().put('enreq', 'true');
                if(pageURL.contains('accountid'))
                    pageURL = pageURL + '&enreq=true';
                else
                    pageURL = pageURL + 'enreq=true';
            }
            */
            //pr.setRedirect(true);
            //return pr;
            
            pageRef = new PageReference(pageURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return pageRef;
    }
	
	//PB(12/17/2009)
	/*
    public PageReference CreateAndLog(){
        return Page.Level1_Case_Contact;
    }

    public PageReference EditAndLog(){
        Integer amtSelected = 0;
        ID contID = null;

        // AC 1/Jul/09 - uses just the current page data set
        for(ContactWrapper cw : CurrentPageDataSet){
            if(cw.Selected){
                amtSelected++;
                contID = cw.contact.Id;
            }
        }

        if(amtSelected == 0){
            NoContToEditSelectedDisplay = true;
            return null;
        }else if(amtSelected > 1){
            TooManyContToEditSelectedDisplay = true;
            return null;
        }else{
            // AC 7/Jul/09 - remove page hard-coding, as per Salesforce recommendation
            PageReference p = Page.Level1_Case_Contact;
            p.getParameters().put('contactID', contID);
            return p;
            //return new PageReference('/apex/Level1_Case_Contact?contactID=' + contID);
        }
    }
*/
    /* JRB: Not currently usnig this functionality ***************
    public PageReference EditSelectedCase(){
        NoCaseSelectAlertDisplay = false;
        TooManyCaseSelectAlertDisplay = false;

        Integer amtSelected = 0;
        ID selectedCaseId = null;
        for(CaseWrapper caseW : existingCustomerCases){
            if(caseW.Selected != null && caseW.Selected){
                amtSelected++;
                selectedCaseId = caseW.internalCase.Id;
            }
        }

        if(amtSelected == 0){
            NoCaseSelectAlertDisplay = true;
            return null;
        }else if(amtSelected > 1){
            TooManyCaseSelectAlertDisplay = true;
            return null;
        }else{
            return new PageReference('/' + selectedCaseId);
        }
    }
    *****************************************************************/

    public void GetCaseDetails(){
        //, c.Last_Queue_Owner__c
        CustomersCase = [select c.Id from Case c where c.Id= :ApexPages.currentPage().getParameters().get('caseid')];
    }

 
}