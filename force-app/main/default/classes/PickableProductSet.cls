public class PickableProductSet
{
	public string Name { get; set; }
	public boolean Selected { get; set; }
	public boolean Expanded { get; set; }
	public PickableOLI[] Products { get; set; }
	public Double SumAssetized { get; set; }
	public Double SumContracted { get; set; }
	public Double Assetizing { get; set; }
	
	public PickableProductSet(string psName)
	{
		Name = psName;
		Products = new PickableOLI[]{}; 
		Selected = null;
		SumContracted = SumAssetized = Assetizing = 0;
	}

	public string GetNonNullName()
	{
		if (Name == null || Name == '') {
			return '[N/A]';
		}
		return Name;
	}
	
	public PickableOLI[] GetSortedProducts()
	{
		Products.sort();
		return Products;
	}
	
	public void AddOLI(PickableOLI oli)
	{
		Products.add(oli);
		SumAssetized += MathUtils.nvl(oli.SumAssetized);
		SumContracted += MathUtils.nvl(oli.SumContracted);
		Assetizing += MathUtils.nvl(oli.Assetizing);
	}
	
	public void ToggleExpanded()
	{
		if (Expanded == null) {
			Expanded = true;
		}
		else {
			Expanded = !Expanded;
		}
	}
	
	public boolean getIsExpanded()
	{
		return (Expanded != null && Expanded);
	}

	public void TickleAllProducts()
	{
		for (PickableOLI prod : Products) {
			prod.Selected = Selected;
		}
	}
	
	public void UpdateSelection()
	{
		if (GetAreAllProductsSelected()) {
			Selected = true;
		}
		else {
			Selected = false;
		}
	}
	
	public boolean GetHasSelectedProducts()
	{
		for (PickableOLI prod : Products) {
			if (prod.Selected == true) { return true; }
		}
		return false;
	}
	
	public boolean GetAreAllProductsSelected()
	{
		for (PickableOLI prod : Products) {
			if (prod.Selected != true) { return false; }
		}
		return true;
	}

	public string GetCoverageColorCode()
	{
		return MisysStringUtils.GetCoverageColorCode(SumAssetized, SumContracted);
	}

	public string GetAssetizingActionColorCode()
	{
		return MisysStringUtils.GetCoverageColorCode(SumAssetized + Assetizing, SumContracted);
	}

	public Double GetRemainingBefore()
	{
		return SumContracted - SumAssetized;
	}
	
	public Double GetRemainingAfter()
	{
		return SumContracted - SumAssetized - Assetizing;
	}
	
}