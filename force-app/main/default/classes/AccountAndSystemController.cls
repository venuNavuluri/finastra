public class AccountAndSystemController
{
	public final Integer MAX_SLIDER_WIDTH_PERCENTAGE = 70;
	private WACAccountWithSystem pair;
	
	public Integer SumLoadingPercentage { get; set; }
	public WACAccountWithSystem ThePair {
		get {
			return pair;
		}
		set {
			pair = value;
			System.debug('@@@ setting the pair: ' + pair.GetMyId() + '--' + pair.LoadingPercentage);
		}
	}
	
	public Integer GetSliderMaxValue()
	{
		return (Integer)ThePair.LoadingPercentage + 100 - SumLoadingPercentage;
	}
	
	public Integer GetSliderWidth()
	{
		return Math.Round((GetSliderMaxValue() * MAX_SLIDER_WIDTH_PERCENTAGE)/100);
	}

	public Integer GetSliderPaddingWidth()
	{
		return MAX_SLIDER_WIDTH_PERCENTAGE - GetSliderWidth();
	}
}