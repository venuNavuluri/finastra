public class IdManager
{
	private static string pMarketingFollowUpRecTypeId;
	private static string pSalesTaskRecTypeId; //Sales_Task
	private static string pLicensesWithWithoutPSRecTypeId;
    private static string pPartnerLeadRecTypeId; // Partner_Lead

	public static string MarketingFollowUpRecTypeId {
		get {
			if (pMarketingFollowUpRecTypeId == null) {
				RecordType[] rts = [
					select Id from RecordType
					where DeveloperName = 'Marketing_Follow_up_Task'
					and SObjectType = 'Task'
				];
				if (rts.size() > 0) { pMarketingFollowUpRecTypeId = rts[0].Id; }
			}
			return pMarketingFollowUpRecTypeId;
		}
		
		private set { }
	}

	public static string salesTaskRecTypeId {
		get {
			if (pSalesTaskRecTypeId == null) {
				RecordType[] rts = [
					select Id from RecordType
					where DeveloperName = 'Sales_Task'
					and SObjectType = 'Task'
				];
				if (rts.size() > 0) { pSalesTaskRecTypeId = rts[0].Id; }
			}
			return pSalesTaskRecTypeId;
		}
		private set { }
	}
	
     /*
    Method: OPP_LicensesWithWithoutPSRecTypeId
    Description: It is used to fetch the recordtype Id of Opportunity record type 'Licenses_with_without_PS'
    Parameters: NA
    Return: String - recordtypeId
    */
	public static string OPP_LicensesWithWithoutPSRecTypeId {
		get {
			if (pLicensesWithWithoutPSRecTypeId == null) {
				RecordType[] rts = [
					select Id from RecordType
					where DeveloperName = 'Licenses_with_without_PS'
					and SObjectType = 'Opportunity'
				];
				if (rts.size() > 0) { pLicensesWithWithoutPSRecTypeId = rts[0].Id; }
			}
			return pLicensesWithWithoutPSRecTypeId;
		}
			private set { }
	}
    
     /*
    Method: Lead_PartnerLeadRecTypeId
    Description: It is used to fetch the recordtype Id of Lead record type 'Partner_Reseller_Lead'
    Parameters: NA
    Return: String - recordtypeId
    */
    public static string Lead_PartnerLeadRecTypeId {
		get {
			if (pPartnerLeadRecTypeId == null) {
				RecordType[] rts = [
					select Id from RecordType
					where DeveloperName = 'Partner_Reseller_Lead'
					and SObjectType = 'Lead'
				];
				if (rts.size() > 0) { pPartnerLeadRecTypeId = rts[0].Id; }
			}
			return pPartnerLeadRecTypeId;
		}
		private set { }
	}

}