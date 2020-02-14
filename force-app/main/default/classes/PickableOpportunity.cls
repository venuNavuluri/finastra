public class PickableOpportunity extends PickableObject
{
	public PickableOpportunity(Opportunity o)
	{
		super(o);
	}

	public Opportunity TheOpportunity
	{
		get {
			return (Opportunity)TheObject;
		}
		set;
	}

	public string getName() { return TheOpportunity.Name; }
}