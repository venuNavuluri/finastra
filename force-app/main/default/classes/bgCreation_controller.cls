public class bgCreation_controller {
    
    public string errorMsg {get; set;}
    public string successMsg {get; set;}
    string response;
    public Id contractId {get; set;}
    
    public bgCreation_controller(APexPages.StandardController sc){
        contractId = sc.getId();
    }
    
    public PageReference pageAction(){
        response = BillingGroupCreation.BillingGroupCreation(contractId);
        if(response.contains('<ul')){
            errorMsg = response;
        } else {
            successMsg = response;
        }
        //return response;
        return null;
    }
}