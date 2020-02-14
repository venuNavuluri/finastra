public class SFDC_CSFE_Controller {
    // Paul Tarpey - Saaspoint - 24 November 2008
    // This variable is used to prevent the case update notifier from running twice
    // which it did due to workflow updates
    public static Boolean emailCheckRunning = false;
    public static boolean CSFEtransactionUpdateRunning = false;
    public static boolean CSFECommentaryRunning = false;
    public static boolean CSFECommentaryRunningFuture = false;

    public static boolean preventTriggersWhenUpdatingCCfromIC = false;
    
    public static boolean preventTriggersWhenSendingMail = false;
}