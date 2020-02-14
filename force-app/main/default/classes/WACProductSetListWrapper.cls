public class WACProductSetListWrapper
{
	public PickableProductSet[] ProductSets { get; set; }
	
	public WACProductSetListWrapper(PickableProductSet[] pList)
	{
		ProductSets = pList;
	}
}