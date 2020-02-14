public class MathUtils
{
	public static Decimal NVL(Decimal val)
	{
		return (val == null ? 0 : val);
	}

}