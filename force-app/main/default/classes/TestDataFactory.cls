/**
 * @File Name          : TestDataFactory.cls
 * @Description        :
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 30/01/2020, 16:59:24
 **/
@isTest
public class TestDataFactory {
  public static final string EMPTY_STRING = '';
  public static final String BLANK_SPACE = ' ';
  public static final String OPP_NAME = 'Test - Opp';
  public static final String ACCOUNT_NAME = 'TestAccount';
  public static final String USER_LASTNAME = 'TestUser';
  public static final String TEAM_MEMBER_ROLE = 'Inside Sales';
  public static String BYPASS_VALIDATION_ERROR_MSG = 'A validation error was raised when it was expected to be bypassed';
  public static String DML_VALIDATION_ERROR_MSG = 'DMLException should contain validation error message';
  public static String NO_DML_VALIDATION_ERROR_MSG = 'DMLException should NOT contain validation error message';
  public static final Integer BULK_TEST_RECORD_COUNT = 200;

  //Set of all the profiles required to run tests
  public static Set<String> profiles = new Set<String>{
    Constants.SYS_ADMIN_PROFILE,
    Constants.SOSS_USR_PROFILE,
    Constants.STD_USR_PROFILE,
    Constants.SALES_USR_PROFILE,
    Constants.BDR_USR_PROFILE,
    Constants.SUPPORT_REP
  };

  //Query to retrieve test users
  public static List<Profile> profileList = [
    SELECT Id, Name
    FROM Profile
    WHERE Name IN :profiles
    ORDER BY Name ASC
  ];

  /**
   * @description RUBX-466 : Test data method for single Account
   * @author Justin Baidoo-Hackman | 05/12/2019
   * @param accName - Account Name
   * @return Contact
   **/
  public static Account createAccount() {
    return createAccount(ACCOUNT_NAME);
  }

  /**
   * @description RUBX-466 : Test data method for single Account
   * @author Justin Baidoo-Hackman | 05/12/2019
   * @param accName - Account Name
   * @return Contact
   **/
  public static Account createAccount(String accName) {
    return new Account(
      Name = accName,
      Status__c = 'Active',
      Country__c = Constants.UNITED_KINGDOM_COUNTRY,
      CurrencyIsoCode = Constants.GBP_Currency
    );
  }

  public static List<Account> createAccounts(
    Integer numAccts,
    Boolean doInsert
  ) {
    List<Account> accts = new List<Account>();
    Account acct;
    for (Integer i = 1; i <= numAccts; i++) {
      acct = createAccount(ACCOUNT_NAME + '-' + i);
      accts.add(acct);
    }
    if (doInsert) {
      insert accts;
    }
    return accts;
  }
  /**
   * @description RUBX-498 : Test data method for Leads
   * @author Prity Sangwan | 04/12/2019
   * @param numLeads
   * @return List
   **/
   
  public static List<Lead> createLeads(
    Integer numLeads,
    Boolean doInsert
  ) {
    List<Lead> Leads = new List<Lead>();

    for (Integer i = 0; i < numLeads; i++) {
      Lead newLead = new Lead(
        FirstName = 'test',
        LastName = 'TestContact' + i,
        Company = 'TestCompany' + i
      );
      Leads.add(newLead);
    }
    // Insert all leads.
    if (doInsert) {
      insert Leads;
    }
    return Leads;
  }

  /**
   * @description RUBX-466 : Test data method for createContact
   * @author Justin Baidoo-Hackman | 05/12/2019
   * @return Contact
   **/
  public static Contact createContact(
    Id accountId,
    String fName,
    String lName,
    Boolean doInsert
  ) {
    Contact aContact = new Contact(
      AccountId = accountId,
      FirstName = fName,
      LastName = lName
    );
    if (doInsert) {
      Database.insert(aContact);
    }
    return aContact;
  }

  public static List<Contact> createContacts(
    Id accountId,
    Integer numContacts,
    Boolean doInsert
  ) {
    List<Contact> contacts = new List<Contact>();

    for (Integer i = 1; i <= numContacts; i++) {
      Contact c = createContact(accountId, 'test', 'TestContact-' + i, false);
      contacts.add(c);
    }
    if (doInsert) {
      insert contacts;
    }
    return contacts;
  }

  /**
   * @description RUBX-466 : Test data method for createContact
   * @author Justin Baidoo-Hackman | 05/12/2019
   * @param opporId
   * @param contactId
   * @param numOcr
   * @param
   * @return Contact
   **/
  public static List<Contact> createContacts(
    List<Account> accounts,
    Integer numContacts,
    Boolean doInsert
  ) {
    List<Contact> contacts = new List<Contact>();
    // For each account create contacts
    for (Account acct : accounts) {
      contacts.addAll(createContacts(acct.Id, numContacts, false));
    }
    if (doInsert) {
      insert contacts;
    }
    return contacts;
  }
  public static List<Opportunity> createOpportunities(
    Integer numAccts,
    Integer numOppsPerAcct,
    Boolean doInsert
  ) {
    List<Account> accounts = createAccounts(numAccts, true);
    // create a contact for each Account
    final Integer NUM_OF_CONTACTS = 1;
    List<Contact> accountContacts = createContacts(
      accounts,
      NUM_OF_CONTACTS,
      true
    );
    final String OPP_MAIN_COMPETITOR = 'Manual';

    // make a map of contact by Account Id
    Map<Id, List<Contact>> contactsByAcctId = new Map<Id, List<Contact>>();
    for (Contact acctContact : accountContacts) {
      List<Contact> contactList = contactsByAcctId.get(acctContact.AccountId);
      if (contactsByAcctId.get(acctContact.AccountId) == null) {
        contactList = new List<Contact>{acctContact};
        contactsByAcctId.put(acctContact.AccountId, contactList);
      }
      contactList.add(acctContact);
    }
    List<Opportunity> opps = new List<Opportunity>();
    for (Account acct : accounts) {
      // For each account just inserted, add opportunities
      for (Integer k = 0; k < numOppsPerAcct; k++) {
        opps.add(
          new Opportunity(
            Name = acct.Name + OPP_NAME + k,
            StageName = Constants.OPPORTUNITY_STAGE_NAME_PROSPECT,
            CAT_Logging_Stage__c = Constants.AWAITING_CAT_REVIEW,
            CloseDate = System.today().addMonths(1),
            Main_Competitor__c = OPP_MAIN_COMPETITOR,
            Power_Sponsor__c = contactsByAcctId.get(acct.Id)[0].Id,
            AccountId = acct.Id
          )
        );
      }
    }
    // Insert all opportunities for all accounts.
    if (doInsert) {
      insert opps;
      // Insert Opportunity Contact Roles for each Opportunity
      createOpportunityContactRoles(opps, contactsByAcctId, true);
    }
    return opps;
  }
  /**
   * @description RUBX-466 : Test data method for creating OpportunityContactRoles for a list of accounts
   * @author Sujith Maruthingal | 29/11/2019
   * @param opporId
   * @param contactId
   * @param numOcr
   * @param
   * @return List<OpportunityContactRole>
   **/
  public static List<OpportunityContactRole> createOpportunityContactRoles(
    List<Opportunity> oppList,
    Map<Id, List<Contact>> contactsByAccount,
    Boolean doInsert
  ) {
    List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
    OpportunityContactRole oppContactRole;
    for (Opportunity opp : oppList) {
      for (Contact acctContact : contactsByAccount.get(opp.AccountId)) {
        oppContactRole = createOpportunityContactRole(
          opp.Id,
          acctContact.Id,
          false
        );
        ocrList.add(oppContactRole);
      }
    }
    if (doInsert) {
      insert ocrList;
    }
    return ocrList;
  }

  /**
   * @description RUBX-466 : Test data method for a single OpportunityContactRole
   * @author Justin Baidoo-Hackman | 05/12/2019
   * @param oppId - Opportunity Id
   * @param contactId - Contact Id
   * @param doInsert - whether DML insert should be called or not
   * @return List<OpportunityContactRole>
   **/
  public static OpportunityContactRole createOpportunityContactRole(
    Id oppId,
    Id contactId,
    Boolean doInsert
  ) {
    OpportunityContactRole oppContactRole = new OpportunityContactRole();
    oppContactRole.Role = Constants.OPPORTUNITY_CONTACT_ROLE;
    oppContactRole.OpportunityId = oppId;
    oppContactRole.ContactId = contactId;
    if (doInsert) {
      Database.insert(oppContactRole);
    }
    return oppContactRole;
  }

  public static Case createLCACase(Id accountId, Id assetId, Boolean doInsert) {
    Map<String, Id> recordTypesMap = CommonUtils.getRecordTypesByObjectName(
      'Case'
    );

    Case newCase = new Case(
      Status = Constants.CASE_STATUS_NEW,
      Priority = Constants.CASE_PRIORITY_MED,
      LCA_Account__c = accountId,
      AccountId = accountId,
      AssetId = assetId,
      RecordTypeId = recordTypesMap.get(Constants.CASE_LCA_RECORD_TYPE_DEV_NAME)
    );

    if (doInsert) {
      insert newCase;
    }

    return newCase;
  }
  public static List<Case> createCases(
    Integer numAccts,
    Integer numCasesPerAcct,
    Boolean doInsert
  ) {
    List<Account> accounts = createAccounts(numAccts, doInsert);

    List<Case> cases = new List<Case>();
    for (Account acct : accounts) {
      // For each account just inserted, add opportunities
      for (Integer k = 0; k < numCasesPerAcct; k++) {
        cases.add(
          new Case(
            Status = Constants.CASE_STATUS_NEW,
            Priority = Constants.CASE_PRIORITY_MED,
            LCA_Account__c = acct.Id,
            AccountId = acct.Id
          )
        );
      }
    }
    // Insert all opportunities for all accounts.
    if (doInsert) {
      insert cases;
    }

    return cases;
  }
  public static Product2 createProduct(string productName, Boolean doInsert) {
    Product2 p = new Product2(Name = productName, IsActive = true);
    if (doInsert) {
      insert p;
    }
    return p;
  }
  public static Contract createContract(
    Id accountId,
    date startDate,
    Boolean doInsert
  ) {
    Contract c = new Contract(
      accountId = accountId,
      startDate = startDate,
      ContractTerm = 12
    );
    if (doInsert) {
      insert c;

      //Activate Contract
      c.Status = Constants.CONTRACT_STATUS_ACTIVATED;
      update c;
    }
    return c;
  }
  public static SBQQ__Subscription__c createSubscription(
    Id accountId,
    Id contractId,
    Id productId,
    Boolean doInsert
  ) {
    SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
      SBQQ__Account__c = accountId,
      SBQQ__Contract__c = contractId,
      SBQQ__Product__c = productId,
      SBQQ__Quantity__c = 1
    );

    if (doInsert) {
      insert subscription;
    }
    return subscription;
  }

  public static List<Asset> createAssets(
    Id accountId,
    Id contactId,
    Id productId,
    Id subscriptionId,
    Integer numAssets,
    Boolean doInsert
  ) {
    List<Asset> assets = new List<Asset>();

    for (Integer k = 0; k < numAssets; k++) {
      assets.add(
        new Asset(
          Name = 'Test Asset' + k,
          Status = Constants.ASSET_STATUS_PURCHASED,
          AccountId = accountId,
          contactId = contactId,
          Product2Id = productId,
          SBQQ__CurrentSubscription__c = subscriptionId
        )
      );
    }
    if (doInsert) {
      insert assets;
    }

    return assets;
  }

  /**
   * @description :  Build profiles as map
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : Profile Name, Profile map
   **/

  public static Map<String, Profile> getProfileMap() {
    map<String, Profile> profileMap = new Map<String, Profile>();
    for (Profile p : profileList) {
      profileMap.put(p.Name, p);
    }
    return profileMap;
  }

  /**
   * @description :  Builds unique string used as username for user
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : Unique string
   **/
  public static String getUniqueUsername() {
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(BLANK_SPACE, EMPTY_STRING)
      .replace(':', EMPTY_STRING)
      .replace('-', EMPTY_STRING);
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    return (uniqueName + '@dummy' + orgId + '.com');
  }
  /**
   * @description :  Create users for profiles in profile map
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : User List
   **/

  public static List<User> createUserList(Boolean doInsert) {
    List<User> newUserList = new List<User>();
    for (Profile p : profileList) {
      String uniqueUserEMailId = getUniqueUsername();
      User u = new User(
        Alias = 'tstUsr',
        Country = 'United Kingdom',
        Email = uniqueUserEMailId,
        EmailEncodingKey = 'UTF-8',
        LastName = USER_LASTNAME,
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = '   en_GB',
        ProfileId = p.Id,
        TimeZoneSidKey = 'Europe/London',
        UserName = uniqueUserEMailId
      );
      newUserList.add(u);
    }
    if (doInsert) {
      insert newUserList;
    }

    return newUserList;
  }

  /**
   * @description :  Updates the given sObject list and returns error map. If there are no errors it returns empty map.
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : Error map
   **/
  public static Map<Integer, String> getErrorMap(List<sObject> listToUpdate) {
    Map<Integer, String> errorMap = new Map<Integer, String>();
    List<Database.SaveResult> results = Database.update(listToUpdate, false);
    for (Database.SaveResult result : results) {
      if (!result.isSuccess()) {
        integer errorSlNumber = 0;
        for (Database.Error err : result.getErrors()) {
          errorSlNumber++;
          errorMap.put(errorSlNumber, err.getMessage());
        }
      }
    }
    return errorMap;
  }

  public static CollaborationGroup createCollaborationGroup(string groupName) {
    CollaborationGroup chatterGroup = new CollaborationGroup(
      Name = groupName,
      CollaborationType = 'Private',
      CanHaveGuests = false,
      IsArchived = false,
      IsAutoArchiveDisabled = true
    );
    insert chatterGroup;
    return chatterGroup;
  }

  /**
   * @description :  Creates SBQQ__Quote and assigns it as primary if desired
   * @author : Justin Baidoo-Hackman
   * @param : opp - the opportunity to associate with the quote
   * @param : primary - boolean to say whether it should be primary or not
   * @param : doInsert - boolean to perform DML or not
   * @return : Single SBQQ__Quote__c
   **/
  public static SBQQ__Quote__c createSBQQuote(
    Opportunity opp,
    Boolean primary,
    Boolean doInsert
  ) {
    SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
      SBQQ__Account__c = opp.AccountId,
      SBQQ__Opportunity2__c = opp.Id,
      SBQQ__Primary__c = primary,
      SBQQ__StartDate__c = Date.today(),
      SBQQ__SubscriptionTerm__c = 12,
      RecordTypeId =
        Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
          .get('Draft')
          .getRecordTypeId()
    );
    if (doInsert) {
      insert newQuote;
    }
    return newQuote;
  }
  /**
   * @description :  Creates list SBQQ__QuoteLine__c record
   * @author : Venu Navuluri
   * @param : quoteId - the billing schedule to create quote for
   * @param : doInsert - boolean to perform DML or not
   * @return : List<SBQQ__QuoteLine__c>
   **/

  public static List<SBQQ__QuoteLine__c> createSBQQuoteLines(
    Integer numqLines,
    Id quoteId,
    Id prodId,
    String prodType,
    Boolean doInsert
  ) {
    List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

    for (Integer k = 0; k < numqLines; k++) {
      quoteLines.add(
        new SBQQ__QuoteLine__c(
          ProdType__c = prodType,
          SBQQ__Product__c = prodId,
          SBQQ__Quote__c = quoteId,
          SBQQ__StartDate__c = Date.today()
        )
      );
    }
    if (doInsert) {
      insert quoteLines;
    }
    return quoteLines;
  }
  /**
   * @description :  Creates a list of SBBQ__Quotes and assigns it as primary if desired
   * @author : Justin Baidoo-Hackman
   * @param : opps - the opportunities to create quotes for
   * @param : primary - boolean to say whether it should be primary or not
   * @param : doInsert - boolean to perform DML or not
   * @return : List of SBQQ__Quote__c
   **/
  public static List<SBQQ__Quote__c> createSBQQuotes(
    List<Opportunity> opps,
    Boolean primary,
    Boolean doInsert
  ) {
    List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
    for (Opportunity anOpp : opps) {
      quotes.add(createSBQQuote(anOpp, primary, false));
    }
    if (doInsert) {
      insert quotes;
    }
    return quotes;
  }

  /**
   * @description : Retrieves one user with given profile id
   * @author : Ramesh Thulasi
   * @param : profileId - user pofile id
   * @return : Retrieved User
   **/
  public static User getProfileUser(ID profileId) {
    return [
      SELECT Id, Profile.Name
      FROM User
      WHERE ProfileId = :profileId AND LastName = :USER_LASTNAME
      LIMIT 1
    ];
  }
  /**
   * @description :  Updates opportunity with given stageName
   * @author : Ramesh Thulasi
   * @param : opp - the opportunity to be udpated
   * @param : stageName - opportunity stagename to be set
   * @return :Updated opportunity
   **/
  public static Opportunity updateOpportunityStage(
    Opportunity opp,
    String stageName
  ) {
    if (null != stageName) {
      opp.StageName = stageName;
      update opp;
    }
    return opp;
  }
  /**
   * @description :  Creates opportunity with given stageName
   * @author : Ramesh Thulasi
   * @param : stageName - opportunity stagename to be set
   * @return : Created opportunity
   **/
  public static Opportunity createOpportunityWithStage(String stageName) {
    // Please make a note that on insert CPQ process/trigger defaults the oportunity stageName to '1. Prospect'.
    // So we have to create and update the stageName in order to set the stageName with required value.
    return updateOpportunityStage(
      createOpportunities(1, 1, true)[0],
      stageName
    );
  }
  /**
   * @description :  Checks for the validation error message for any object record on update
   * @author : Ramesh Thulasi
   * @param : recordToUpdate - Any object record to be udpated
   * @param : errorMessage - Error message to check
   * @return : Check result as Boolean
   **/
  public static Boolean checkValidationErrorMessage(
    sObject recordToUpdate,
    String errorMessage
  ) {
    Boolean containsValidationMsg = false;
    Map<Integer, String> errorMap = getErrorMap(
      new List<sObject>{recordToUpdate}
    );
    for (String val : errorMap.values()) {
      containsValidationMsg = val.startswith(errorMessage);
      if (containsValidationMsg) {
        break;
      }
    }
    return containsValidationMsg;
  }
  /**
   * @description :  Sets the bypass validation custom setting for a given user
   * @author : Ramesh Thulasi
   * @param : usr - User on which the flag to be set
   * @return : None
   **/
  public static void setBypassValidationForUser(User usr) {
    // set the custom property flag to 'true'
    Bypass_Validations__c cusSetting = [
      SELECT id
      FROM Bypass_Validations__c
      WHERE SetupOwnerId = :usr.id
    ];
    cusSetting.Disable__c = true;
    update cusSetting;
  }
  /**
   * @description Creates a task
   * @author Peter Sabry | 18/12/2019
   * @param whatId
   * @param owner
   * @param status
   * @param subject
   * @param doInsert
   * @return void
   **/
  public static Task createTask(
    Id whatId,
    Id ownerId,
    String status,
    String subject,
    Boolean doInsert
  ) {
    Task newTask = new Task(
      WhatId = whatId,
      OwnerId = ownerId,
      status = status,
      Subject = subject
    );
    if (doInsert) {
      insert newTask;
    }
    return newTask;
  }

  /**
   * @description RUBX-505 : Test data method for single AccountTeamMember
   * @author Sujith Maruthingal | 20/12/2019
   * @param  accId
   * @param userId
   * @param accountAccessLevel
   * @param opportunityAccessLevel
   * @param doInsert
   * @return AccountTeamMember
   **/
  public static AccountTeamMember createAccountTeamMember(
    Id accId,
    Id userId,
    String accountAccessLevel,
    String opportunityAccessLevel,
    Boolean doInsert
  ) {
    AccountTeamMember accTeamMember = new AccountTeamMember(
      AccountId = accId,
      TeamMemberRole = TEAM_MEMBER_ROLE,
      UserId = userId,
      AccountAccessLevel = accountAccessLevel,
      OpportunityAccessLevel = opportunityAccessLevel,
      CaseAccessLevel = Constants.EDIT_ONLY,
      ContactAccessLevel = Constants.EDIT_ONLY
    );
    if (doInsert) {
      insert accTeamMember;
    }
    return accTeamMember;
  }

  /**
   * @description RUBX-505 : Test data method for single AccountShare
   * @author Sujith Maruthingal | 20/12/2019
   * @param accId
   * @param userId
   * @param accountAccessLevel
   * @param opportunityAccessLevel
   * @param doInsert
   * @return AccountTeamMember
   **/

  public static AccountShare createAccountShare(
    Id accId,
    Id userId,
    String accountAccessLevel,
    String opportunityAccessLevel,
    Boolean doInsert
  ) {
    AccountShare accShare = new AccountShare(
      AccountId = accId,
      UserOrGroupId = userId,
      AccountAccessLevel = accountAccessLevel,
      OpportunityAccessLevel = opportunityAccessLevel,
      CaseAccessLevel = Constants.EDIT_ONLY,
      ContactAccessLevel = Constants.EDIT_ONLY
    );

    if (doInsert) {
      insert accShare;
    }
    return accShare;
  }

  /**
   * @description Create OpportunityTeamMember record
   * @author Peter Sabry | 18/12/2019
   * @param opportunityId
   * @param userId
   * @param oppAccess
   * @param teamMemberRole
   * @param doInsert
   * @return OpportunityTeamMember
   **/
  public static OpportunityTeamMember createOppTeamMember(
    Id opportunityId,
    Id userId,
    String oppAccess,
    String teamMemberRole,
    Boolean doInsert
  ) {
    OpportunityTeamMember teamMember = new OpportunityTeamMember(
      UserId = userId,
      OpportunityId = opportunityId,
      TeamMemberRole = teamMemberRole,
      OpportunityAccessLevel = oppAccess
    );

    if (doInsert) {
      insert teamMember;
    }
    return teamMember;
  }
  /**
   * @description :  Returns day of week in number. Sun = 0, Sat = 6
   * @author : Ramesh Thulasi
   * @param : aDate - Date to get the number of week
   * @return : day of week as Integer
   **/
  public static Integer dayOfWeekNumber(Date aDate) {
    return Math.mod(Date.newInstance(1900, 1, 7).daysBetween(aDate), 7);
  }
  /**
   * @description :  Returns new Monday for a given date
   * @author : Ramesh Thulasi
   * @param : aDate - Date to get new Monday
   * @return : Monday as date
   **/
  public static Date getNextMonday(Date aDate) {
    Integer dayOfWeek = dayOfWeekNumber(aDate);
    Integer daysToAdvance = 0;
    if (dayOfWeek == Constants.SUNDAY) {
      daysToAdvance = 1;
    } else if (dayOfWeek == Constants.MONDAY) {
      daysToAdvance = 0;
    } else if (dayOfWeek == Constants.TUESDAY) {
      daysToAdvance = 6;
    } else if (dayOfWeek == Constants.WEDNESDAY) {
      daysToAdvance = 5;
    } else if (dayOfWeek == Constants.THURSDAY) {
      daysToAdvance = 4;
    } else if (dayOfWeek == Constants.FRIDAY) {
      daysToAdvance = 3;
    } else if (dayOfWeek == Constants.SATURDAY) {
      daysToAdvance = 2;
    }
    return aDate.addDays(daysToAdvance);
  }
  /**
   * @description :  Returns new Friday for a given date
   * @author : Ramesh Thulasi
   * @param : aDate - date for next monday
   * @return : Friday as day
   **/
  public static Date getNextFriday(Date aDate) {
    Integer dayOfWeek = dayOfWeekNumber(aDate);
    Integer daysToAdvance = 0;
    if (dayOfWeek == Constants.SUNDAY) {
      daysToAdvance = 5;
    } else if (dayOfWeek == Constants.MONDAY) {
      daysToAdvance = 4;
    } else if (dayOfWeek == Constants.TUESDAY) {
      daysToAdvance = 3;
    } else if (dayOfWeek == Constants.WEDNESDAY) {
      daysToAdvance = 2;
    } else if (dayOfWeek == Constants.THURSDAY) {
      daysToAdvance = 1;
    } else if (dayOfWeek == Constants.FRIDAY) {
      daysToAdvance = 0;
    } else if (dayOfWeek == Constants.SATURDAY) {
      daysToAdvance = 6;
    }
    return aDate.addDays(daysToAdvance);
  }

  /**
   * @description: Method to generate a single address associated either with a contact or an account
   * @author Aakanksha Sharma | 27/01/2020
   * @param accountId
   * @param contactId
   * @param doInsert
   * @return Address__c
   **/
  public static Address__c createAddress(
    Id accountId,
    Id contactId,
    Boolean doInsert
  ) {
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    Address__c addr = new Address__c(
      Name = 'Seattle' + ' - ' + 'WA' + randomInt,
      Account__c = accountId,
      Contact__c = contactId,
      City__c = 'Seattle',
      Country__c = Constants.USA_COUNTRY,
      State_Province__c = 'Washington',
      Zip_Postal_Code__c = 'WA' + randomInt
    );
    if (doInsert) {
      Database.insert(addr);
    }
    return addr;
  }
  /**
   * @description : Method to create addresses for an Account
   * @author Aakanksha Sharma | 27/01/2020
   * @param accountId
   * @param numAddresses
   * @param doInsert
   * @return List<Address__c>
   **/
  public static List<Address__c> createAccountAddresses(
    Id accountId,
    Integer numAddresses,
    Boolean doInsert
  ) {
    List<Address__c> addr = new List<Address__c>();

    for (Integer i = 1; i <= numAddresses; i++) {
      Address__c a = createAddress(accountId, null, false);
      addr.add(a);
    }
    if (doInsert) {
      insert addr;
    }
    return addr;
  }

  /**
   * @description:  Method to create addresses for a Contact
   * @author Aakanksha Sharma | 27/01/2020
   * @param contactId
   * @param numAddresses
   * @param doInsert
   * @return List<Address__c>
   **/
  public static List<Address__c> createContactAddresses(
    Id contactId,
    Integer numAddresses,
    Boolean doInsert
  ) {
    List<Address__c> addr = new List<Address__c>();

    for (Integer i = 1; i <= numAddresses; i++) {
      Address__c a = createAddress(null, contactId, false);
      addr.add(a);
    }
    if (doInsert) {
      insert addr;
    }
    return addr;
  }
  /**
   * @description :  Creates a Billing_Schedule__c record
   * @author : Venu Navuluri
   * @param : quoteId - the billing schedule to create quote for
   * @param : doInsert - boolean to perform DML or not
   * @return : Billing_Schedule__c
   **/

  public static Billing_Schedule__c createBillingSchedule(
    Boolean doInsert,
    Id QuoteId,
    String ProdType
  ) {
    Billing_Schedule__c billingSchedule = new Billing_Schedule__c(
      ProdType__c = ProdType,
      Quote__c = quoteId
    );
    if (doInsert) {
      insert billingSchedule;
    }
    return billingSchedule;
  }

  /**
   * @description :  Reusable method to insert/prepare CS Case
   * @author : Irfan Khan
   * @param : accountId
   * @param : contactId
   * @param : doInsert
   * @return : Case Object
   **/
  public static Case createCSCase(
    Id accountId,
    Id contactId,
    Boolean doInsert
  ) {
    //if account and contacts are null then insert a generic one
    if (String.IsBlank(accountId)) {
      List<Account> acc = createAccounts(1, true);
      accountId = acc[0].Id;
    }
    if (String.IsBlank(contactId)) {
      List<Contact> con = createContacts(accountId, 1, true);
      contactId = con[0].Id;
    }

    Case newCase = new Case(
      Status = Constants.CASE_STATUS_NEW,
      Priority = Constants.CASE_PRIORITY_MED,
      LCA_Account__c = accountId,
      AccountId = accountId,
      contactId = contactId,
      RecordTypeId =
        CommonUtils.getRecordTypesByObjectName('Case')
          .get(Constants.CASE_CUSTOMER_SERVICE_RECORD_TYPE_DEV_NAME)
    );
    if (doInsert) {
      insert newCase;
    }
    return newCase;
  }

  /**
   * @description :  Reusable method to insert custom settings which bypasses validation rule for given user
   * @author : Irfan Khan
   * @param : User object
   * @return : nothing
   **/

  public static void createByPassValidationRecord(User byPassingUser) {
    // init Bypass validation custom property
    List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
    // set custom property for admin user
    valCusSettings.add(
      new Bypass_Validations__c(
        SetupOwnerId = byPassingUser.id,
        Disable__c = true
      )
    );
    insert valCusSettings;
  }
}
