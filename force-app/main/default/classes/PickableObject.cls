public virtual class PickableObject
{
	public boolean Selected { get; set; }
	public SObject TheObject { get; set; }

	public PickableObject(SObject o)
	{
		TheObject = o;
		Selected = false;
	}
	
}