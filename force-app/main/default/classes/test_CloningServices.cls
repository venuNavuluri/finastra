@isTest
class test_CloningServices 
{
    static testMethod void testCloneSingleRecord()
    {
        Account a = TestUtils.getAccount('ut acc 1');
        insert a;
        Account clonedAccount = (Account)CloningServices.cloneRecord(a, false);
        clonedAccount = [Select id, Name from Account where id =: a.id];
        System.assertEquals(a.Name, clonedAccount.Name);
    }
    
    static testMethod void testCloneRecordsInBulk()
    {
        List<Account> actList = new List<Account>();
        for(Integer x=0; x< =500; x++)
        {
            Account a = TestUtils.getAccount('ut acct');
            a.AccountNumber = String.valueOf(x);
            actList.add(a);
        }
        insert actList;
        
        Set<ID> clonedAccountIDs = new Set<ID>();
        for(Account a: (List<Account>)CloningServices.cloneRecordsInBulk(actList, false))
            clonedAccountIDs.add(a.id);
        
        Integer actNumber = 0;
        for(Account clonedAccount: [Select id, Name, AccountNumber from Account where id in: clonedAccountIDs order by AccountNumber])
        {
            System.assertEquals('ut acct', clonedAccount.Name);
            System.assertEquals(String.valueOf(actNumber), clonedAccount.AccountNumber);
            actNumber++;
        }
    }
}