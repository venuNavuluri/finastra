public class PickableOLI extends PickableObject implements Comparable
{
	public Double SumAssetized { get; set; }
	public Double SumContracted { get; set; }
	public Double Assetizing { get; set; }
	public Double SumContracted3pp { get; set; } //AK - added for 3pp field
	public Double SumContractedRlfFairValue { get; set; } //AK - added for RLF Fair Value field
	public Double SumContractedRpaList { get; set; } //AK - added for RPA List field
	public Double SumAssetized3pp { get; set; } //AK - added for 3pp field
	public Double SumAssetizedRlfOrgFairValue { get; set; } //AK - added for RLF Fair Value field
	public Double SumAssetizedRlfCurFairValue { get; set; } //AK - added for RLF Fair Value field
	public Double SumAssetizedRpaList { get; set; } //AK - added for RPA List field
	/*
	public PickableOLI(OpportunityLineItem oli, boolean pSelected, Double pSumAssetized, Double pSumContracted)
	{
		super(oli);
		Selected = pSelected;
		SumAssetized = pSumAssetized;
		SumContracted = pSumContracted;
		Assetizing = 0;
	}
	*/
	public PickableOLI(OpportunityLineItem oli, boolean pSelected, Double pSumAssetized, Double pSumContracted, 
						Double pSumContracted3pp, Double pSumContractedRlfFairValue, Double pSumContractedRpaList,
						Double pSumAssetized3pp, Double pSumAssetizedRlfOrgFairValue, Double pSumAssetizedRlfCurFairValue, Double pSumAssetizedRpaList)
	{
		super(oli);
		Selected = pSelected;
		SumAssetized = pSumAssetized;
		SumContracted = pSumContracted;
		SumContracted3pp = pSumContracted3pp;
		SumContractedRlfFairValue = pSumContractedRlfFairValue;
		SumContractedRpaList = pSumContractedRpaList;
		SumAssetized3pp = pSumAssetized3pp;
		SumAssetizedRlfOrgFairValue = pSumAssetizedRlfOrgFairValue;
		SumAssetizedRlfCurFairValue = pSumAssetizedRlfCurFairValue;
		SumAssetizedRpaList = pSumAssetizedRpaList;
		Assetizing = 0;
	}

	public OpportunityLineItem TheOLI
	{
		get {
			return (OpportunityLineItem)TheObject;
		}
		set;
	}

	public Double GetRemainingAfter()
	{
		return SumContracted - SumAssetized - Assetizing;
	}

	//Ak-added this for 3pp	
	public Double GetRemainingAfter3pp()
	{
		return SumContracted3pp - SumAssetized3pp - Assetizing;
	}

	//Ak-added this for Original Fair value	
	public Double GetRemainingAfterRlfOrgFairValue()
	{
		return SumContractedRlfFairValue - SumAssetizedRlfOrgFairValue - Assetizing;
	}

	//Ak-added this for Current fair value	
	public Double GetRemainingAfterRlfCurFairValue()
	{
		return SumContractedRlfFairValue - SumAssetizedRlfCurFairValue - Assetizing;
	}

	//Ak-added this for RPA list	
	public Double GetRemainingAfterRpaList()
	{
		return SumContractedRpaList - SumAssetizedRpaList - Assetizing;
	}

	public Double GetRemainingBefore()
	{
		return SumContracted - SumAssetized;
	}
	
	//Ak-added this for 3pp	
	public Double GetRemainingBefore3pp()
	{
		return SumContracted3pp - SumAssetized3pp;
	}

	//Ak-added this for Original Fair value	
	public Double GetRemainingBeforeRlfOrgFairValue()
	{
		return SumContractedRlfFairValue - SumAssetizedRlfOrgFairValue;
	}

	//Ak-added this for Current fair value	
	public Double GetRemainingBeforeRlfCurFairValue()
	{
		return SumContractedRlfFairValue - SumAssetizedRlfCurFairValue;
	}

	//Ak-added this for RPA list	
	public Double GetRemainingBeforeRpaList()
	{
		return SumContractedRpaList - SumAssetizedRpaList;
	}

	public string getName()
	{
		return TheOLI.PriceBookEntry.Product2.Name;
	}
	
	public string GetCoverageColorCode()
	{
		return MisysStringUtils.GetCoverageColorCode(SumAssetized, SumContracted);
	}

	public string GetAssetizingActionColorCode()
	{
		return MisysStringUtils.GetCoverageColorCode(SumAssetized + Assetizing, SumContracted);
	}
	
	public string GetSortName()
	{
		return TheOLI.Location__c + '@' + getName();
	}
	
	public Integer compareTo(Object compareTo) {
		if (GetSortName() == ((PickableOLI)compareTo).GetSortName()) { return 0; }
		else if (GetSortName() > ((PickableOLI)compareTo).GetSortName()) { return 1; }
		else { return -1; }
	}
}