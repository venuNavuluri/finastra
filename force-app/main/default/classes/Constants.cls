/**
 * @File Name          : Constants.cls
 * @Description        : Apex constants are variables whose values don’t change after being initialized once. Constants can be defined using the final keyword.
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 28/01/2020, 13:20:51
 **/
public with sharing class Constants {
  public static final String CAT_LOGGING_STAGE_COMPLETE = 'CAT Review Complete';
  public static final String AWAITING_CAT_REVIEW = 'Awaiting CAT Review';
  public static final String STAGE_NAME_CLOSED_WON = 'Closed Won';

  public static final String CASE_LCA_RECORD_TYPE_DEV_NAME = 'License_Compliance_Audit';
  public static final String CASE_CUSTOMER_SERVICE_RECORD_TYPE_DEV_NAME = 'Customer_Service';
  //Case Status
  public static final String CASE_STATUS_DESELECTION_APPROVAL = 'Awaiting Deselection Approval';
  public static final String CASE_STATUS_NEW = 'New';
  public static final String CASE_STATUS_PRE_WORK = 'Pre-work';
  public static final String CASE_STATUS_WITH_AM_TO_REVIEW = 'With AM to Review';
  public static final String CASE_STATUS_CLOSED = 'Closed';
  public static final String CASE_STATUS_AUDITED = 'Audited (Closed)';
  public static final String CASE_STATUS_NOT_AUDITED = 'Not Audited (Closed)';
  public static final String COMPLIANCE_SUB_STATUS_COMPLIANT = 'Compliant';

  //Lead Status
  public static final String LEAD_STATUS_CONVERTED = 'Converted';
  public static final String LEAD_STATUS_NEW = 'New';
  public static final String LEAD_STATUS_QUALIFIED = 'Qualified';

  //Opportunity Stage Status
  public static final String OPPORTUNITY_STAGE_NAME_PROSPECT = '1. Prospect';
  public static final String OPPORTUNITY_STAGE_NAME_CREATE = '2. Create';
  public static final String OPPORTUNITY_STAGE_NAME_QUALIFY = '3. Qualify';
  public static final String OPPORTUNITY_STAGE_NAME_DEVELOP = '4. Develop';
  public static final String OPPORTUNITY_STAGE_NAME_PROVE = '5. Prove';
  public static final String OPPORTUNITY_STAGE_NAME_NEGOTIATE = '6. Negotiate';
  public static final String OPPORTUNITY_STAGE_NAME_CQO = 'Closed Qualified Out';
  public static final String OPPORTUNITY_STAGE_NAME_CL = 'Closed Lost';
  public static final String OPPORTUNITY_STAGE_NAME_CWP = 'Closed Won Pending';
  public static final String OPPORTUNITY_STAGE_NAME_CW = 'Closed Won';
  //Opportunity Assignment Error Message
  public static final String OPPORTUNITY_ASSIGNMENT_ERROR_MSG = 'Please update the opportunity by creating a Completed task with details of the meeting held with the customer.';
  public static final String OPPORTUNITY_ASSIGNMENT_REJ_ERROR_MSG = 'Please select a Rejection Reason.';

  //Opportunity Forecast Category
  public static final String OPPORTUNITY_FORECAST_LIKELY = 'Likely';

  public static final String OPP_CONTACT_ROLE_ERROR_MSG = 'It is mandatory to create at-least one contact role on the opportunity';

  //Opportunity Assignment Status
  public static final String OPPORTUNITY_ASSIGNMENT_STATUS_NOT_ASSIGNED = 'Not Assigned';
  public static final String OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT = 'Pending Assignment';
  public static final String OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT_OVERDUE = 'Pending Assignment (Overdue)';
  public static final String OPPORTUNITY_ASSIGNMENT_STATUS_ASSIGNED = 'Assigned';
  public static final String OPPORTUNITY_ASSIGNMENT_STATUS_REJECTED = 'Rejected';

  //Task Status
  public static final String TASK_STATUS_COMPLETED = 'Completed';

  //Account Team Member
  public static final String ACC_TEAM_MEMBER_ERROR_MSG = 'Read/Write permission cannot be enabled for Account and Opportunities,They will be Read Only.';

  //Opportunity Contact Role
  public static final String OPPORTUNITY_CONTACT_ROLE = 'Decision Maker';

  //Case Priority
  public static final String CASE_PRIORITY_MED = 'Medium';

  //Case Environment
  public static final String CASE_ENVIRONMENT_PROD = 'Production';

  //Contract Status
  public static final String CONTRACT_STATUS_ACTIVATED = 'Activated';

  //Asset Status
  public static final String ASSET_STATUS_PURCHASED = 'Purchased';

  public static final Boolean isSubmitted = false;
  public static final String EDIT_ONLY = 'Edit';
  public static final String READ_ONLY = 'Read';
  // PROFILE NAMES
  public static final String SYS_ADMIN_PROFILE = 'System Administrator';
  public static final String SOSS_USR_PROFILE = 'SOSS User';
  public static final String STD_USR_PROFILE = 'Standard User';
  public static final String BDR_USR_PROFILE = 'BDR User';
  public static final String SALES_USR_PROFILE = 'Sales User';
  public static final String SUPPORT_REP = 'Support Rep';

  //Test Class Messages
  public static final String DMLEXC_WITHOUT_VALIDATION_ERR_MSG = 'DMLException should NOT contain validation error message';
  public static final String DMLEXC_WITH_VALIDATION_ERR_MSG = 'DMLException should contain validation error message';
  public static final String BYPASS_ERROR_MSG = 'A validation error was raised when it was expected to be bypassed';

  //Number of Days to create LCA Cases
  public static final Integer LCA_DAYS_TO_CREATE_CASE = 7;

  public static final String LCA_TEAM_QUEUE_NAME = 'License_Compliance_Audit_Team';
  public static final String LICENSE_PRINCIPLE_TEAM = 'License Principle Team';

  public static final Integer NO_OF_REC_FOR_BULK_TEST = 200;

  //Opportunity
  public static final String FULL_RECORD_TYPE = 'Full';
  public static final String EXEMPT_FORECAST = 'Exempt';
  public static final String GSC_REQUESTED = 'Requested';

  //Currency Codes
  public static final String GBP_CURRENCY = 'GBP';
  public static final String USD_CURRENCY = 'USD';

  //Countries
  public static final String USA_COUNTRY = 'USA';
  public static final String UNITED_KINGDOM_COUNTRY = 'United Kingdom';

  // Billing Schedule
  public static String ILF = 'ILF';
  //Record Types
  public static final Id OPPORTUNITY_FULL_RECORDTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
    .get(Constants.FULL_RECORD_TYPE)
    .getRecordTypeId();

  // Week days
  public static final Integer SUNDAY = 0;
  public static final Integer MONDAY = 1;
  public static final Integer TUESDAY = 2;
  public static final Integer WEDNESDAY = 3;
  public static final Integer THURSDAY = 4;
  public static final Integer FRIDAY = 5;
  public static final Integer SATURDAY = 6;
}
