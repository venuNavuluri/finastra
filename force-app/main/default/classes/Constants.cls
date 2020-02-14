/**
 * @File Name          : Constants.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 25/07/2019, 10:35:44
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    25/07/2019, 10:35:44   Peter Sabry     Initial Version
**/
public with sharing class Constants {
	
/* Constants class
*
* 11/03/2011 - Naushad Sunnivohra (Bluewolf)
* Constants class 

* 6/Feb/2013 - David Jordan Appiro
* Added DEFECT
*   
*/

	/******** From Turaz Production org - July 2012
	*
	*	4 Jul 2012 - JRB
	*	Reimplenting this using Custom Labels instead of a class, so that it does not require a code deployment to change...
	*	If line starts with '//JRB ', it has been moved to a custom label
	*	
	********/
	//public with sharing class Constants
	//{
	    public static final String SELECT_ONE = 'Select One';
	    public static boolean DISABLE_INDIVIDUAL_TRIGGER = false;
	    public static final String NO_PROJECTS_AVAILABLE = 'No Projects Available';
	    public static final String NO_CONTACTS_AVAILABLE = 'No Contacts Available';
	    public static final String NO_ENTITLEMENTS_AVAILABLE = 'No Entitlements Available';
	    public static final String NO_SYSTEMS_AVAILABLE = 'No Systems Available';
	    public static final String NO_ASSETS_AVAILABLE = 'No Assets Available';
	    public static final String NO_ENVIRONMENTS_AVAILABLE = 'No Environments Available';
	    public static final String NO_ASSET_VERSIONS_AVAILABLE = 'No Asset Versions Available';
	    public static final String NO_COMPONENTS_AVAILABLE = 'No Components Available';
	    
	    public static final String QRY_STRING_ACCOUNT_ID = 'def_account_id';
	    public static final String QRY_STRING_CONTACT_ID = 'def_contact_id';
	    public static final String QRY_STRING_CHANGE_ASSET = 'isChangeAsset';
	    public static final String QRY_STRING_CASE_ID = 'id';
	    public static final String QRY_STRING_CONVERT_TO_TECH_FUNC_ISSUE = 'convertToTechFuncIssue';
	    
	    public static final String DEFAULT_SEVERITY = '3';
	    public static final String DEFAULT_PRIORITY = '4';
	    public static final String DEFAULT_ORIGIN = 'Email';
	    public static final String DEFAULT_ORIGIN_PORTAL = 'Web';
	    public static final String DEFAULT_TYPE = 'Technical';
	    public static final String ORIGIN_PHONE = 'Phone';
	    
	    //JRB public static final String STATUS_NEW = 'New';
	    //public static final String STATUS_ESCALATED = 'Escalated to Engineering';
	    public static final String DEFECT = 'Defect';
	    public static final String STATUS_ESCALATED = 'In Progress';
	    public static final String SUB_STATUS_ESCALATED = 'Engineering';
	    public static final String STATUS_CLOSED = 'Closed';
	    //public static final String STATUS_FIXED = 'Fixed';
	    //AK - 994224 - Resolved is getting changed to Solution Provided
	    //public static final String STATUS_FIXED = 'Resolved';
	    public static final String STATUS_FIXED = 'Solution Provided';
	    //public static final String STATUS_WAITING_ON_CS_PS = 'Waiting on CS/PS';
	    public static final String SUB_STATUS_WAITING_ON_CS_PS = 'CS';
	    public static final String STATUS_CANCELLED = 'Cancelled';
	    public static final String STATUS_ON_MAINTENANCE = 'On Maintenance';
	    public static final String STATUS_PENDING_MAINTENANCE = 'Pending Maintenance';
	    //public static final String STATUS_ESCALATED_TO_DEV = 'Escalated to Development';
	    public static final String STATUS_ESCALATED_TO_DEV = 'In Progress';
	    public static final String SUB_STATUS_ESCALATED_TO_DEV = 'Development';
	    
	    public static final String PRODUCT_FAMILY_ACCRUENT = 'Accruent';
	    public static final String PRODUCT_FAMILY_FAMIS = 'FAMIS';
	    public static final String PRODUCT_FAMILY_SITERRA = 'Siterra';   
	    
	    public static final String ORDER_TYPE_COMPLIANCE = 'Compliance';
	    public static final String ORDER_TYPE_ADD_ON = 'Add-On';
	    public static final String ORDER_TYPE_CHANGE_ORDER = 'Change Order';
	    public static final String ORDER_TYPE_RENEWAL = 'Maintenance Renewal';
	    public static final String ORDER_TYPE_UPGRADE = 'Upgrade';
	    public static final String ORDER_TYPE_NEW_PRODUCT = 'New Product';
	    
	    public static final String FINANCE_REVIEW_APPROVED = 'Approved';
	    public static final String FINANCE_REVIEW_LICENSED_ISSUED = 'License Issued';
	    public static final String FINANCE_REVIEW_IN_REVIEW = 'In Review';
	    public static final String FINANCE_REVIEW_APPROVED_ISSUE_LICENSE = 'Approved - Issue License';
	    public static final String FINANCE_REVIEW_NOT_APPROVED = 'Not Approved';
	    
	    public static final String OPPORTUNITY_RECORD_TYPE_CHANGE_ORDER = 'Change Order';
	    public static final String OPPORTUNITY_RECORD_TYPE_STANDARD = 'Licenses with/without PS';
	    
	    public static final String QUOTE_GROUP_RECORD_TYPE_PRIMARY = 'Primary Quote System';
	    public static final String QUOTE_GROUP_RECORD_TYPE_ADDITIONAL = 'Additional Quote System';
	    
	    public static final String REDIRECT_PARENT = 'parent';
	    public static final String REDIRECT_ATTACH = 'attach';
	    
	    public static final String CUSTOMER_PORTAL_LICENSE_KEY = 'PID_Customer_Portal_Standard';
	    
	    public static final String ENGINEERING_CASE_RECORD_TYPE = 'Engineering (Turaz)';
	    public static final String TECH_FUNC_ISSUE_CASE_RECORD_TYPE = 'Technical/Functional Issue';
	    public static final String TECH_FUNC_ISSUE_PORTAL_CASE_RECORD_TYPE = 'Portal Technical/Functional Issue';
	    public static final String PROJECT_ISSUE_CASE_RECORD_TYPE = 'Project Issue';
	    public static final String PROJECT_ISSUE_PORTAL_CASE_RECORD_TYPE = 'Portal Project Issue';
	    
	    public static final String QUEUE_TYPE = 'Queue';
	    //public static final String DEVELOPMENT_QUEUE_NAME = 'EngineeringTuraz';
	    public static final String DEVELOPMENT_QUEUE_NAME = Label.Development_Queue_Name;
	    
	    public static final String GENERAL_SETTING_OPPTY_RECORD_TYPE_SELECTION_URL = 'OpportunityRecordTypeSelectionURL';
	    public static final String GENERAL_SETTING_REGION_FIELD_CODE = 'RegionFieldCode';
	    public static final String GENERAL_SETTING_HUB_FIELD_CODE = 'HUBFieldCode';
	    public static final String GENERAL_SETTING_COUNTRY_FIELD_CODE = 'CountryFieldCode';
	    public static final String GENERAL_SETTING_ENABLE_ACCOUNT_SHARING_TRIGGERS = 'EnableAccountSharingTriggers';
	    
	    public final static string CONTACT_OBJECT_PREFIX = '003';
    	public final static string LEAD_OBJECT_PREFIX = '00Q';
  
	    public static final String ACTIVE_STATUS = 'Active';
	    public static final String ON_MAINTENANCE_STATUS = 'On Maintenance';
	    public static final String MONTHLY_TYPE = 'Monthly';
	//}
	
	    //KK: SD Ticket-1468075 : Constants added for the MQL task processing requirement. 
	    public static final String TASKPROGACT_INVALID_MQL = 'Invalid MQL';
	    public static final String TASKPROGACT_SANCTIONED_COUNTRY_REG = 'Sanctioned Country/Region';
	    public static final String TASKPROGACT_DETAILS_TOO_GENERIC = 'Details Too Generic';
	    public static final String TASKPROGACT_UNRESPONSIVE = 'Unresponsive';  
	    public static final String TASKPROGACT_COMPETITIVE_CONTRACT = 'Currently in Competitive Contract';
	    public static final String TASKPROGACT_INAPPROPRIATE_CONTACT = 'Not an appropriate contact';
	    public static final String TASKPROGACT_NO_CURRENT_NEED = 'No current need';
	    public static final String TASKPROGACT_INTERESTED_FOR_RESEARCH = 'Interested for research';
	    public static final String TASKPROGACT_SOLN_NOT_SUITABLE = 'Misys solution not suitable';
	    public static final String TASKPROGACT_OPPORTUNITY_CREATED = 'Opportunity Created';
	    public static final String TASKPROGACT_COMPETITOR = 'Competitor';
        public static final String TASKPROGACT_STRATEGIC_ACCOUNT = 'Strategic Account';
        public static final String TASKPROGACT_CONSULTANT_TECH_PROVIDER = 'Consultant/Technology Provider';
        public static final String TASKPROGACT_EXISTING_OPPORTUNITY = 'Existing Opportunity';
        public static final String TASKPROGACT_PASSED_TO_DH = 'Passed to DH';
	    public static final String LEAD_CONTACT_STATUS_SAL = 'Sales Accepted Lead (SAL)';
	    public static final String LEAD_CONTACT_STATUS_RECYCLE = 'Recycle';
	    public static final String LEAD_CONTACT_STATUS_NOT_A_LEAD = 'Not a Lead';
	    public static final String TASK_STATUS_COMPLETED = 'Completed';
	    public static final String MQL_MARKETING_CAMPAIGN_NAME = 'Develop and Nurture';

		// RBX-317: Test Data Framework - Standard library
		public static final String TDF_USER                         = 'USER';
		public static final String TDF_ACCOUNT                      = 'ACCOUNT';
		public static final String TDF_CONTACT                      = 'CONTACT';
		public static final String TDF_LEAD                         = 'LEAD';
		public static final String TDF_OPPORTUNITY                  = 'OPPORTUNITY';
		public static final String TDF_OPP_LINE_ITEM                = 'OPP_LINE_ITEM';
		public static final String TDF_OPP_CONTACT_ROLE             = 'OPP_CONTACT_ROLE';
		public static final String TDF_PRODUCT                      = 'PRODUCT';

		// RBX-317: Test Data Framework - Custom Library
		public static final String TDF_CUSTOM_ACCOUNT               = 'CUSTOM_ACCOUNT';

		//REQ-3694: Picklist value for No Increase
		public static final String RF_INDEX_TYPE_NO_INCREASE 		= 'No Increase';

	public static void checkConstant()
	{ 
		String testConstant = Constants.ACTIVE_STATUS;
		system.debug(testConstant);
	}
	
	public static boolean stopRecurrsionflag=true;
    
    public static boolean runonce(){
        if(stopRecurrsionflag){
            stopRecurrsionflag=false;
        }else {
            return stopRecurrsionflag;
        }
        return true;
    }

}