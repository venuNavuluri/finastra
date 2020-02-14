public class PickableContract extends PickableObject
{
	public PickableContract(Contract c)
	{
		super(c);
	}

	public Contract TheContract
	{
		get {
			return (Contract)TheObject;
		}
		set;
	}

	public string getCreatedDate() { return TheContract.CreatedDate.format('dd MMM yyyy'); }
	public string getAccountName() { return TheContract.Account.Name; }
	public string getName() { return TheContract.Name; }
	public string getContractNumber() { return TheContract.ContractNumber; }
	
	
}