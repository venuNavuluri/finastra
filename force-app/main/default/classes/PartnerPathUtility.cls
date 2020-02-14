public class PartnerPathUtility {
    /*
    Method: getEndPoint
    Description: This method is used to fetch the partnerpath endpoint URL from partnerpath custom settings
    Parameters: NA
    Return: String - partnerpath endpoint
    */
   public static String getEndPoint() {
      String ppEnpoint;
      PartnerPathConfig__c ppConfig = PartnerPathUtility.getConfig();
      if(null!=ppConfig){
            ppEnpoint= ppConfig.Endpoint__c;
      }
      return ppEnpoint;
   }
   
     /*
    Method: getConfig
    Description: This method is used to fetch the partnerpath custom settings
    Parameters: NA
    Return: custom setting - PartnerPathConfig__c
    */
   public static PartnerPathConfig__c getConfig() {
      System.debug('PartnerPathUtility :: getConfig():: get partnerpath custom settings' );  
      String env = 'Production';
      if (PartnerPathUtility.isSandbox()){
          env = 'Acceptance';
      }
      PartnerPathConfig__c config = PartnerPathConfig__c.getInstance(env); 
      return (config);
   }
     /*
    Method: getToken
    Description: This method is used to fetch the partnerpath Token from partnerpath custom settings
    Parameters: NA
    Return: String - partnerpath token 
    */
   public static String getToken() {
      String ppToken;
      PartnerPathConfig__c ppConfig = PartnerPathUtility.getConfig();
      if(null!=ppConfig){
          ppToken=ppConfig.Token__c;
      }
      return ppToken;
   }
   
    /*
    Method: isSandbox
    Description: This method is used to check if the current environment on which the code is running is sandbox
    Parameters: NA
    Return: Boolean
    */
    public Static Boolean isSandbox(){
         System.debug('PartnerPathUtility :: isSandbox() ');
        return [SELECT isSandbox FROM Organization].isSandbox;       
    }
}