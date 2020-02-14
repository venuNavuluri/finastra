public class WizAssetCrtTwinSliderRowController
{
	public final Integer MAX_SLIDER_WIDTH_PERCENTAGE = 48;
	private WACAccountWithSystem pair;
	
	public Double SumLoadingPercentage { get; set; }
	public WACAccountWithSystem ThePair {
		get {
			return pair;
		}
		set {
			pair = value;
		}
	}

	public Integer GetLoadingPercentageInt() {
		return getIntPart(ThePair.LoadingPercentage);
	}
	public Integer GetLoadingPercentageDec() {
		return getDecPart(ThePair.LoadingPercentage);
	}

	private Double getRemainingCapacity() { return 100 - SumLoadingPercentage;}
	public Double GetMaxAvailable() { return ThePair.LoadingPercentage + getRemainingCapacity(); }
	public Integer GetMaxAvailableIntegerPart() { return getIntPart(GetMaxAvailable()); }
	public Integer GetMaxAvailableDecimalPart() { return getDecPart(GetMaxAvailable()); }

	public Integer GetSeparatorWidth() { return 100 - 2 * MAX_SLIDER_WIDTH_PERCENTAGE; }	
	public Integer GetIntegerSliderMaxValue() {
		Integer maxValInt = GetMaxAvailableIntegerPart();
		Integer maxValDec = GetMaxAvailableDecimalPart();
		Integer startValDec = GetLoadingPercentageDec();
		if (maxValDec < startValDec) { return maxValInt - 1; }
		else { return maxValInt; }
	}
	public Integer GetDecimalSliderMaxValue() {
		Integer startValInt = GetLoadingPercentageInt();
		Integer startValDec = GetLoadingPercentageDec();
		Integer maxValInt = GetMaxAvailableIntegerPart();
		Integer maxValDec = GetMaxAvailableDecimalPart();
		if (startValInt < maxValInt) { return 99; }
		else {
			return max(maxValDec, startValDec);
		}
	}
	
	public Integer GetIntegerSliderWidth() { return Math.Round((GetIntegerSliderMaxValue() * MAX_SLIDER_WIDTH_PERCENTAGE)/100); }
	public Integer GetDecimalSliderWidth() { return Math.Round((GetDecimalSliderMaxValue() * MAX_SLIDER_WIDTH_PERCENTAGE)/100); }

	public Integer GetIntegerSliderPaddingWidth() {	return MAX_SLIDER_WIDTH_PERCENTAGE - GetIntegerSliderWidth(); }
	public Integer GetDecimalSliderPaddingWidth() {	return MAX_SLIDER_WIDTH_PERCENTAGE - GetDecimalSliderWidth(); }

	private static Integer getIntPart(Double num) { return (Integer)num; }
	private static Integer getDecPart(Double num) {	return (Integer)Math.Round((num - getIntPart(num)) * 100); }
	private static Integer max(Integer a, Integer b) {
		if (a < b) return b;
		else return a;
	}
	
}