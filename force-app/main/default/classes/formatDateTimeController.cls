public class formatDateTimeController {
/*
	public DateTime dateTimeValue { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format();
            return localeFormatDT;
        }
        return null;
    }
}
*/
public DateTime dateTimeValue { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('yyyy/MM/dd HH:mm');
            return localeFormatDT;
        }
        return null;
    }
}