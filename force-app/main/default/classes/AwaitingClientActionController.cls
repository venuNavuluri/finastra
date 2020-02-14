public class AwaitingClientActionController
{
    List<Account> lAcc = new List<Account>();
    Id AccId;
    public AwaitingClientActionController()
    {
        lAcc = [Select Id,Name from Account where OwnerId =: UserInfo.getUserId()];
    }
    public List<Account> getAccRecords()
    {
        return lAcc;
    }
    public String GetMySessionId() 
    {
        return UserInfo.getSessionId();
    }
    public void PutAccId()
    {
        String AId = System.currentPageReference().getParameters().get('AccId');
        AccId = AId;
    }
    public String getAccId()
    {
        return AccId;
    }
}