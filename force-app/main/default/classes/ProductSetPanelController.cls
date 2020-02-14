public class ProductSetPanelController
{
	public PickableProductSet TheProductSet { get; set; }
	public boolean EditMode { get; set; }

	public PageReference dummy() {
		return null;
	}
	
	public void ToggleExpanded()
	{
		TheProductSet.ToggleExpanded();
	}
	
	
	public void ProductSetSelectChanged()
	{
		TheProductSet.TickleAllProducts();
	}
	
	public void ProductSelectChanged()
	{
		TheProductSet.UpdateSelection();
	}

}