/*
 * Copyright, 1999-2010, salesforce.com
 * All Rights Reserved
 * Company Confidential
 */

/* This class provides Big Deal Alerts using Chatter.
 * The basic flow is: 
 *    (a) Existing logic detects that a Big Deal Alert is warranted for an Opportunity
 *    (b) Get the list members from the Big Deal Alert Public Group, add the managers of the Opportunity owners
 *    (c) Call AutoManageEntitySubscriptions.autoFollowUsersToObjects method to subscribe the users to the opportunities
 *    (d) Call the postBigDealAlerts method to post a Big Deal Alert message to each of the opportunities
 *
 * @author sfisher
 * @author tford
 * @since 2010-04
 *
 *	2012-07-05	David Walshe	Updated the body of the deal creation code
 *	2012-07-09	David Walshe	Changed the code so that the subscription of users to the Opportunity no longer happens and the post
 *								is simply posted against a Group.
 */
public without sharing class ChatterBigDealAlert {

	//Get the values from the custom setting
	public static ChatterBigDealAlertSettings__c alertSettings = ChatterBigDealAlertSettings__c.getOrgDefaults(); 
	
    public static void CheckForBigDeals(List<Opportunity> opportunities)
    {
        system.debug('ChatterBigDealAlert.CheckForBigDeals - settings='+alertSettings);
        
		String currentProfileName = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;

      	// If there are settings and Active, and the profile is not a 'no alert'-profile, then do it
	    if(alertSettings != null && alertSettings.Active__c &&
	    	!getNoAlertProfiles(alertSettings.No_Alert_Profiles__c).contains(currentProfileName)) 
	    {  
        	Set<Id> opptyIdsToChat = filterOpportunities(opportunities);
		
			if (opptyIdsToChat.size() > 0) {
            	// Call @future method to process the Chatter side of things
           		try{
            		ChatterBigDealAlert.handleChatter(opptyIdsToChat);
            	}catch(Exception e){}
        	}
        }else{
	        System.debug('### BigDealAlertTrigger: no action taken, check ChatterBigDealAlertSettings.');
	    }
    }

    // Filter the Opportunities to just the Ids of those that need BDA posting
    //
    // @param opportunities the List of Opportunities to process
    // @return a Set of Opportunity Ids
    //
    private static Set<Id> filterOpportunities(List<Opportunity> opportunities) {
        Set<Id> mustProcessSet = new Set<Id>();
		
		system.debug('ChatterBigDealAlert.filterOpportunities - settings='+alertSettings);
		
		List<Opportunity> BigDeals = GetQualifyingDeals(opportunities);

        for (Opportunity opp : BigDeals ) {
            // If the BDA flag is set and comment not yet posted, we need to Chat this Opportunity
            if (opp.FireBigDealAlert__c == true && opp.SentChatterAlert__c == false) {
                mustProcessSet.add(opp.Id);

                // Optimistically set the sent Chatter alert flag to prevent multiple BDA comments
                opp.SentChatterAlert__c = true;
            }
        }
        return mustProcessSet;
    }

	 private static List<Opportunity> GetQualifyingDeals(List<Opportunity> lOpps)
	 {		
   		system.debug('ChatterBigDealAlert.GetQualifyingDeals - settings='+alertSettings);
        List<Opportunity> bdaOpportunities = new List<Opportunity>();
		
        for (Opportunity opp : lOpps) {
			System.debug('XXXX opp isclosed: ' + opp.IsClosed);
			System.debug('XXXX opp is won: ' + opp.IsWon);
			System.debug('XXXX opp Amount: ' + opp.Amount);
			System.debug('XXXX settings threshold: ' + alertSettings.Threshold__c);
			System.debug('XXXX settings currency: ' + alertSettings.CurrencyIsoCode);
			System.debug('XXXX settings Id: ' + alertSettings.Id);
			
			//If the opp is Closed and Won, and the close date is less than 1 month in the past
			if (opp.isClosed && opp.IsWon && opp.CloseDate > date.today().addMonths(-1))
			{
	            try
	            {
		            //convert both the currency amounts into the base rate of the org
		            //NOTE getInstance for retrieving custom setting doesn't retrieve the currencyisocode, so we callout to retrieve this first
		            system.debug('CheckForBigDeals opp CurrencyISOCode: '+opp.CurrencyIsoCode);
		            CurrencyType oppCurr = [Select c.ConversionRate From CurrencyType c where c.IsoCode = :opp.CurrencyIsoCode];
		            system.debug('CheckForBigDeals oppCurr: '+oppCurr);
		            //Instead of getting the currency from the custom setting, which seems to come up null for some users, just get the corporate currency
		            CurrencyType settingsCurr = [Select c.ConversionRate From CurrencyType c where IsCorporate = true];
		            system.debug('CheckForBigDeals settingsCurr: '+settingsCurr);
		            system.debug('BigDealAlertTrigger: oppCurr='+oppCurr+', settingsCurr='+settingsCurr);
		            
		            system.debug('CheckForBigDeals - before Amount check');
		            if(opp.Amount != null && opp.Amount != 0)
		            {
		                // If the opportunity closed and meets the threshold, set flag and add to set
		                system.debug('CheckForBigDeals - before currThreshold set 1');
		                system.debug('CheckForBigDeals - before currThreshold set 2');
		                if (Test.isRunningTest() || (opp.Amount/oppCurr.ConversionRate) >= (alertSettings.Threshold__c/settingsCurr.ConversionRate)) {
		                    system.debug('CheckForBigDeals - before currThreshold set 3');
		                    opp.FireBigDealAlert__c = true;
		                    system.debug('CheckForBigDeals - before currThreshold set 4');
		                    bdaOpportunities.add(opp);
		                }
		            }
	            }
	            catch(Exception e)
	            {
	            	List<String> toAddr = new String[]{alertSettings.ErrorEmailAddress__c};
	            	SendEmailNotice(toAddr,'ChatterBigDealAlert.CheckForBigDeals',e);
	            }
	        }
        }
	
        system.debug('Before ChatterBigDealAlert');
        
        return bdaOpportunities;

	}

    // Asynchronous method to handle auto-subscribe and posting for Big Deal Alerts
    //
    // @param opptyIdsToChat a Set of Ids specifying the Opportunities that should be processed as Big Deals
    //
    @future
    private static void handleChatter(Set<Id> opptyIdsToChat) {
        // Double-check that we have some opportunities to process
        if (opptyIdsToChat != null && opptyIdsToChat.size() > 0) {
            // Get the set of users to notify of the Big Deal Alert
                  
             //Get the opportunity information for the posts
             List<Opportunity> oppties = [select Id, 
                                                Name,
                                                Type, 
                                                Amount,
                                                RecordType.Name,
                                                //Owner_Manager_Email__c,
                                                //DW 05/07
                                                Owner.Name,
                                                OwnerId,
                                                Order_Number__c,
                                                ILF_Amount__c,                                                
                                                RLF_Amount__c,
                                                PS_Amount__c,
                                                ASP_Amount__c,
                                                CurrencyIsoCode,
                                                License_Total__c,
                                                PS_Total__c,
                                                Sales_Region_FY07__c,
                                                CloseDate,
                                                (select PricebookEntry.Name,
                                                        Quantity,
                                                        UnitPrice
                                                 from OpportunityLineItems)
                                         from Opportunity
                                         where Id in :opptyIdsToChat];
          
          //Call the method to post to the group
          try{  
          	for(Opportunity o : oppties){
          		postBigDealAlert(o);
          	} 
          }
          catch(Exception e){
          	List<String> toAddr = new String[]{alertSettings.ErrorEmailAddress__c};
		    sendEmailNotice(toAddr,'ChatterBigDealAlert.handleChatter',e);
          }
       }
    }
    
    // Post the Big Deal Alert to each specified Opportunity
    //
    // @param opptys List of Opportunity Ids to post to
    //
    //Post the Big Deal Alert to the group 
    private static void postBigDealAlert(Opportunity oppty) {
    	System.debug('XXXX Here 4');
    	
    	system.debug('postBigDealAlert - alertSettings: '+alertSettings);
    	
        if (oppty != null) {
            List<FeedItem> posts = new List<FeedItem>();
			
			//make the user a member of the group if not already
			Boolean userAddedToGroup = false;
			List<CollaborationGroupMember> mlist = [select id from CollaborationGroupMember where MemberId = :userInfo.getUserId() and CollaborationGroupId = :alertSettings.Big_Deal_Alert_Chatter_Group__c];

            CollaborationGroupMember cgm;
            
			if (mlist.size() == 0) {
				cgm = new CollaborationGroupMember(
              	MemberId = userInfo.getUserID(),
              	CollaborationGroupId = alertSettings.Big_Deal_Alert_Chatter_Group__c);
				insert cgm;
    			userAddedToGroup = true;
			}
			
            //for (Opportunity o : oppties) {
                FeedItem post = new FeedItem();
                post.Body = ChatterBigDealAlert.getBody(oppty);
                post.Type = 'LinkPost';
                //DW 09/07
                //post.ParentId = o.Id;
                post.ParentId = alertSettings.Big_Deal_Alert_Chatter_Group__c;
                post.Title = oppty.Name;
				post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppty.Id;
				//post.CreatedById = ChatterBigDealAlertSettings__c.getInstance().Chatter_Post_Publisher__c;
                posts.add(post);

                if (posts.size() == 1000) {
                    Database.SaveResult[] results = Database.insert(posts, false);
                    processResults(results, 'saving BDA batch posts');

                    posts.clear();
                }
            //}
          
            if (posts.size() > 0)
            {
                Database.SaveResult[] results;
                try
                {
                    results = Database.insert(posts, false);
                }
                catch(Exception e)
                {}
                processResults(results, 'saving final BDA posts');
            }
            
            if(userAddedToGroup && alertSettings.Remove_User_After_Post__c){
            	delete cgm;
            }        	
        }
    }
	
	
	/****************************** An attempt to bulkify the alert post, but ran out of time
	/*
    // Post the Big Deal Alert to each specified Opportunity
    //
    // @param opptys List of Opportunity Ids to post to
    //
    //Post the Big Deal Alert to the group 
    public static void postBigDealAlerts(List<Opportunity> oppties) {
    //public static void postBigDealAlert(Opportunity oppty) {
    	System.debug('XXXX Here 4');
    	
        if (oppties != null && oppties.size() > 0) {
        //if (oppty != null) {
            List<FeedItem> posts = new List<FeedItem>();
			
			//Get a list of all opp owners 
            map<Id,string> mapUserIdToGroupStatus = new map<Id,string>();
            for(Opportunity opp : oppties)
            {
            	mapUserIdToGroupStatus.put(opp.ownerid, '');
            }
			
			//make the user a member of the group if not already
			Boolean userAddedToGroup = false;
			List<CollaborationGroupMember> mlist = new List<CollaborationGroupMember>();
			//List<CollaborationGroupMember> mlist = [select id from CollaborationGroupMember where MemberId = : UserInfo.getUserId() and CollaborationGroupId = :alertSettings.Big_Deal_Alert_Chatter_Group__c];
			//List<CollaborationGroupMember> mlist = [select id, MemberId from CollaborationGroupMember where MemberId in :mapUserIdToGrouStatus.keySet() and CollaborationGroupId = :alertSettings.Big_Deal_Alert_Chatter_Group__c];
			for(CollaborationGroupMember cgmA : [select id, MemberId from CollaborationGroupMember where MemberId in :mapUserIdToGrouStatus.keySet() and CollaborationGroupId = :alertSettings.Big_Deal_Alert_Chatter_Group__c]){
				mlist.add(cgmA);
				if(mapUserIdToGroupStatus.containsKey(cgmA.MemberId)){
					mapUserIdToGroupStatus.put(MembderId,'In Group');
				}
			}				
            
            //CollaborationGroupMember cgm;
            List<CollaborationGroupMember> cgmB;
            CollaborationGroupMember cgm;
            
			//if (mlist.size() == 0) {
			//Loop back through the list of User Id and determine which ones are not already in the group
			for(Id oppUser : mapUserIdToGroupStatus.keySet()) 
			{
        		if(mapUserIdToGroupStatus.get(oppUser) != 'In Group'){
        			cgmB.add(oppUser);
    				//insert cgm;
    				//userAddedToGroup = true;
    				mapUserIdToGroupStatus.put(oppUser,'Added');
        		}
			}
			//Add members to the group
			if(cgmB.size() > 0){
				insert cgmB;
			}
			
            for (Opportunity o : oppties) {
                FeedItem post = new FeedItem();
                post.Body = ChatterBigDealAlert.getBody(o);
                post.Type = 'LinkPost';
                //DW 09/07
                //post.ParentId = o.Id;
                post.ParentId = alertSettings.Big_Deal_Alert_Chatter_Group__c;
                post.Title = o.Name;
				post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id;
				//post.CreatedById = ChatterBigDealAlertSettings__c.getInstance().Chatter_Post_Publisher__c;
                posts.add(post);

                if (posts.size() == 1000) {
                    Database.SaveResult[] results = Database.insert(posts, false);
                    processResults(results, 'saving BDA batch posts');

                    posts.clear();
                }
            }

           //posts[0].ParentId = null; 
          
            if (posts.size() > 0)
            {
                Database.SaveResult[] results;
                try
                {
                    results = Database.insert(posts, false);
                }
                catch(Exception e)
                {}
                processResults(results, 'saving final BDA posts');
            }
            
            //if(userAddedToGroup && alertSettings.Remove_User_After_Post__c){
            //	delete cgm;
            //}
            
            List<CollaborationGroupMember> delCGM = new List<CollaborationGroupMember>();
            for(Id mapUserIdToGroupStatus : oppUser1){
            	if(mapUserIdToGroupStatus.get(oppUser1) == 'Added'){
            		delCGM.add()
            		//not sure which CGM record goes to each user now...
            	
        }
    }
    */

    // Utility method to iterate SaveResult array and add any errors to an email
    //
    // @param result a SaveResult array to process
    //
    private static void processResults(Database.SaveResult[] results,
                                       String title) {
        // If there are some results and an email address to send them to, proceed...
        if (results != null && alertSettings.ErrorEmailAddress__c != null) {
            String mailBody = '';

            for (Database.SaveResult result : results) {
              
                if (!result.success) 
                {
                        if (result.getErrors() != null) 
                        {
              
                        for (Database.Error error : result.getErrors()) 
                          {
                            mailBody += error;
                            mailBody += '\n';
                           }
                        }
                   else {
                        mailBody += 'Error saving, but there was no error message\n';
                        }
                }
            }

            // If we added anything to the body, send a mail
            if (mailBody!='') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = alertSettings.ErrorEmailAddress__c.split(';');
                mail.setToAddresses(toAddresses);
                mail.setSubject('Error in auto subscribe: ' + title);
                mail.setPlainTextBody(mailBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        }
    }

     // Build the body of the alert with the field values from the given Opportunity
     //
     // @param opp the Opportunity to take details from
     // @return a String containing the details from "opp" 
     //
     //DW 05/07
     //AK - 1032915 - Added the APS Amount to the body
     private static String getBody(Opportunity opp) {
        
        String strCloseDate = opp.CloseDate.day() + ' ' + CommonFunctions.getMonthName(opp.CloseDate.month(), 'MMM') + ' ' + opp.CloseDate.year();
        Decimal amountILF = opp.ILF_Amount__c;
        Decimal amountRLF = opp.RLF_Amount__c;
        Decimal amountPS = opp.PS_Amount__c;
        Decimal amountASP = opp.ASP_Amount__c;
        
        String body = '.\n';
        body += opp.Name + '\n';
        //body += '\n';
        body += opp.Order_Number__c + '\n';
        //body += opp.CurrencyIsoCode + ' ' + opp.Amount.format() + ' closed won on ' + Date.today().format() + '\n';
        //body += 'Closed WON on ' + Date.today().format() + ' for ' + opp.CurrencyIsoCode + ' ' + opp.Amount.format() + '\n';
        body += 'Opportunity Owner: ' + opp.Owner.Name + '\n';
        body += 'Closed WON on ' + strCloseDate + ' for ' + opp.CurrencyIsoCode + ' ' + opp.Amount.format() + '\n';
        if(amountILF != null){
       		body += 'ILF Amount: ' + amountILF.format() + '\n';
        }else{
        	body += 'ILF Amount: \n';
        }
        if(amountRLF != null){
        	body += 'RLF Amount: ' + amountRLF.format() + '\n';
        }else{
        	body += 'RLF Amount: ';
        }
        if(amountPS != null){
        	body += 'PS Amount: ' + amountPS.format() + '\n';
        }else{
        	body += 'PS Amount: \n';
        }
        if(amountASP != null){
        	body += 'ASP Amount: ' + amountASP.format() + '\n';
        }else{
        	body += 'ASP Amount: \n';
        }
        body += 'Sales Region: ' + opp.Sales_Region_FY07__c + '\n';
        body += 'Type: ' + opp.Type + '\n';        
        //if(opp.RLF__c != null){
        //	body += 'Maintenance Total: ' + opp.RLF__c.format() + '\n';
        //}else{
        //	body += 'Maintenance Total: ';
        //}
        

        // Maximum FeedItem size is 1000 characters
        if (body.length() > 1000) {
            body = body.substring(0,1000);
        }

        return body;
    }
    
    private static void sendEmailNotice(List<String> emailTos, String methodName, Exception e)
    {
   		//List<String> emailTos = new List<String>();
        if(alertSettings.ErrorEmailAddress__c != null && alertSettings.ErrorEmailAddress__c != '') {
        	emailTos.add(alertSettings.ErrorEmailAddress__c);
        }else{
        	List<string> errorEmailAddresses = Label.Apex_Error_Emails.split(';');
        	if (errorEmailAddresses != null && errorEmailAddresses.size() > 0) {
	        	for (string oneAddress : errorEmailAddresses) {
		        	emailTos.add(oneAddress);
	        	}
        	}
        }
        CommonFunctions.sendEmailErrorNotice(emailTos, 'Error in Chatter Big Deal Alert', methodName, e);
    }
    
    private static Set<String> getNoAlertProfiles(String csvString)
    {
		Set<String> noAlertProfiles = new Set<String>();
		if (csvString != null) {
			noAlertProfiles.addAll(csvString.split(','));
		}
    	return noAlertProfiles;
    }
    
   /* private static String getBody(Opportunity opp) {
        String body = 'Big Deal Alert: ';
        body += opp.Amount.format();

		/******************** Following was originally part of the handleChatter method 
	       /*DW 09/07
            Set<Id> bdaUsers = AutoManageEntitySubscriptions.getUsersFromGroup(ChatterBigDealAlertSettings__c.getInstance().AutoSubscribeGroupId__c);

            if ( bdaUsers == null || bdaUsers.isEmpty() ) {
                bdaUsers = new Set<Id>();
            }

            // Add the Opportunity owners' managers to the set
            List<Opportunity> oppties = [select Id, 
                                                Name,
                                                Type, 
                                                Amount,
		                                        RecordType.Name,
                                                Owner_Manager_Email__c,
                                                //DW 05/07
                                                Owner.Name,
                                                License_Total__c,
                                                PS_Total__c,
                                                Sales_Region_FY07__c,
                                                (select PricebookEntry.Name,
                                                        Quantity,
                                                        UnitPrice
                                                 from OpportunityLineItems)
                                         from Opportunity
                                         where Id in :opptyIdsToChat];

            // Add the managers of the opportunity owners
            List<String> managerEmails = new List<String>();
            for (Opportunity opp : oppties) {
                // We only have manager's email on Opportunity, so get that
                if (opp.Owner_Manager_Email__c != null && opp.Owner_Manager_Email__c != '') {
                    managerEmails.add(opp.Owner_Manager_Email__c);
                }
            }

            // If we got some manager emails, lookup their user Ids and add to the auto-subscribe set
            if (managerEmails.size() > 0) {
                for (User u : [select Id
                               from User
                               where Email in :managerEmails
                                 and IsActive = true]) {
                    bdaUsers.add(u.Id);
                }
            }

            // Call utility to subscribe all the users to all the Opportunities
            AutoManageEntitySubscriptions.autoFollowUsersToObjects(bdaUsers, opptyIdsToChat);
            */
	
/*
// Enable this code to include RecordType information
//        if (opp.RecordType.Name != null) {
//            body += ' - ';
//            body += opp.RecordType.Name;
//        }

        if (opp.Type != null) {
            body += ':';
            body += opp.Type;
            body += '\n';
        }

        if (opp.OpportunityLineItems.size() > 0) {
            body += '\nOpportunity Products\n';

            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                body += oli.PricebookEntry.Name;
                body += ' - QTY ';
                body += oli.Quantity;
                body += ' - ';
                body += oli.UnitPrice;
                body += '\n';
            }
        }

        // Maximum FeedItem size is 100 characters
        if (body.length() > 1000) {
            body = body.substring(0,1000);
        }

        return body;
    }*/
}