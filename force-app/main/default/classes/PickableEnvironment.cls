public class PickableEnvironment implements Comparable
{
	public string Name { get; set; }
	public string DisplayName { get; set; }
	public boolean Selected { get; set; }
	public string SystemPostfix { get; set;}
	public Id ID { get; set; }
	
	public PickableEnvironment(string pName, string pDisplayName, boolean pSelected)
	{
		Name = pName;
		DisplayName = pDisplayName;
		Selected = pSelected;
	}
	
	public Integer compareTo(Object compareTo) {
		if (DisplayName == ((PickableEnvironment)compareTo).DisplayName) { return 0; }
		else if (DisplayName > ((PickableEnvironment)compareTo).DisplayName) { return 1; }
		else { return -1; }
	}
	
}