/*
    This is custom exception class.
*/
public class CustomException extends Exception {
    public String customMessage;
    
    public CustomException(String message, String customMessage){
        this(message);
        this.customMessage = customMessage;
    }
}