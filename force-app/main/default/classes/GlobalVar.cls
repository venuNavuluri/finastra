public class GlobalVar {
	
	public static boolean bInFuture = false;

	public static boolean IsProduction() {
		//Returns FALSE if the current org is not equal to the Misys Production Org Id.
		try{
			return (UserInfo.getOrganizationId().startsWith('00D9E0000001fqg'));
		}catch(Exception e){
			return false;
		}
	}

	public static boolean bAlreadyUpdatedOppLineItems = false; 
    
    public static boolean bSystemAllowOppLineItemDelete = false;
    
}