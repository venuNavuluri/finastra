public class DontCallFutureMethodFromTestMethod
{
	public static Boolean isTestMethod = false;
	public static Boolean getIsTestMethod()
	{
		return isTestMethod;
	}
	public static void setIsTestMethod()
	{
		isTestMethod = true;
	}
	public static testmethod void testDontCallFutureMethodFromTestMethod()
    {
    	setIsTestMethod();
    	getIsTestMethod();
    }
}