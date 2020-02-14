public class ConversionUtils
{
	public static Date DateTimeToDate(DateTime dt)
	{
		if (dt == null) { return null; }
		return Date.newInstance(dt.year(), dt.month(), dt.day());
	}
	

	public static string IntToString(Decimal d)
	{
		if (d == null) { return null; }
		return String.valueOf((Integer)d);
	}

	public static boolean NumFieldToBool(Decimal num)
	{
		return num != null && num == 1;
	}

	public static Integer StringFieldToInt(string str)
	{
		try {
			return integer.valueOf(str);
		}
		catch (Exception e) {
			return null;
		}
	}

}