/**
 * @author  Steve Fouracre, Tony Bave
 * @Jira    RBX-331
 * Class captures debug messages in the Debug Message / Debug Parent objects
 * Monitoring is enabled using either these Custom Settings: -
 *
 *   MonitoringCoverage - hierarchy - Monitoring is active if the Enabled flag is checked for the current User,
 *                                    their Profile, or the Org Defaults.
 *   Monitoring - List - a List of items to monitor, each has its own Active flag and optional date/time range.
 *
 */
public class UtilsMonitoring {

    /**
     * List of items to monitor, populated from Monitoring custom setting
     */
    @TestVisible
    private static Set<String> monitorSet;

    /**
     * List of debug messages grouped by item name/reference, and grouped by source object
     */
    @TestVisible
    private static Map<System.Type, Map<String, List<ErrorMessage>>> saveMonitoringMessagesMap;

    /**
     * Class representing one debug/error message
     */
    public class ErrorMessage {

        /**
         * Debug message, limit is 255 characters
         */
        public String msg;

        /**
         * Optional list of additional data associated with the message as key/value pairs
         */
        public Map<String, Object> additionalFields;

        /**
         * Constructor
         *
         * @param aMsg      a debug/error message
         * @param aFields   optional additional data as key/value pairs
         */
        public ErrorMessage(String aMsg, Map<String, Object> aFields) {
            if (aMsg != null) {
                this.msg = aMsg.abbreviate(255);
            }
            this.additionalFields = aFields;
        }
    }

    /**
     * @Jira RBX-331
     * Determines the state of monitoring coverage for the current user.
     *
     * @return  {Boolean} True if monitoring coverage is enabled for current user, their profile, or in org defaults
     */
    public static Boolean getMonitoringCoverage() {

        return (((MonitoringCoverage__c.getOrgDefaults() != null) ? MonitoringCoverage__c.getOrgDefaults().Enable__c : false)
                || MonitoringCoverage__c.getInstance(UserInfo.getUserId()).Enable__c
                || MonitoringCoverage__c.getInstance(UserInfo.getProfileId()).Enable__c);
    }

    /**
     * @Jira RBX-331
     * Initialises monitoring. Creates the monitorSet from the Monitoring custom setting. Checks which entries are
     * active and if a data/time range is given, whether the current date/time is in the range.
     */
    public static void setupMonitoring() {

        if (monitorSet == null || monitorSet.isEmpty()) {

            // get monitor items from Custom Setting
            Map<String, Monitoring__c> mon = Monitoring__c.getAll();
            if (!mon.isEmpty()) {

                // create the monitorSet
                monitorSet = new Set<String>();
                for (Monitoring__c thisMon: mon.values()) {

                    // add monitor item if item is Active and the current date/time is within range (if specified)
                    if ( (thisMon.Active__c && thisMon.Monitor_Datetime_From__c == null && thisMon.Monitor_Datetime_To__c == null)
                            || (thisMon.Active__c && thisMon.Monitor_Datetime_From__c <= Datetime.now()
                                && thisMon.Monitor_Datetime_To__c >= Datetime.now())) {
                        if (thisMon.Name != null) {
                            monitorSet.add(thisMon.Name);
                        }
                    }
                }
            }
        }

        // initialise the monitoring message map, if not already set up
        if (saveMonitoringMessagesMap == null) {
            saveMonitoringMessagesMap = new Map<System.Type, Map<String, List<ErrorMessage>>>();
        }
    }

    /**
     * @Jira RBX-331
     * Builds a debug message and adds it to the monitoring message map
     *
     * @param objMonitor    source object providing the debug message
     * @param ref           item name being reported (refers to Monitoring custom setting names)
     * @param msg           message to be captured
     * @param otherFields   optional additional data as key/value pairs
     */
    public static void buildMonitoringMessage(System.Type objMonitor, String ref, String msg, Map<String, Object> otherFields) {

        // if monitoring coverage is enabled then all monitoring messages are saved,
        // otherwise only if the item name is Active, as specified in the monitorSet
        if (getMonitoringCoverage() || (monitorSet != null && !monitorSet.isEmpty() && monitorSet.contains(ref))) {

            // create an Error Message object
            ErrorMessage newError = new ErrorMessage(msg, otherFields);

            // if the monitoring message map has an entry for this source object
            if (saveMonitoringMessagesMap != null && saveMonitoringMessagesMap.containsKey(objMonitor)) {

                // add the new error to the map for this source object
                if (saveMonitoringMessagesMap.get(objMonitor).containsKey(ref)) {
                    (saveMonitoringMessagesMap.get(objMonitor).get(ref)).add(newError);
                }
                else {
                    saveMonitoringMessagesMap.get(objMonitor).put(ref, new List<ErrorMessage>{ newError });
                }
            }
            else {
                // add the new error to a new map for the source object
                saveMonitoringMessagesMap.put(objMonitor, new Map<String, List<ErrorMessage>> {
                                                                        ref => new List<ErrorMessage> { newError }
                });
            }
        }
    }

    /**
     * @Jira RBX-331
     * Save monitoring messages for a source object type
     * So you can save only debug log coming from Trigger using <object>.class,
     * Or if you want to output only from a class you can specify <class-name>.class instead
     *
     * @param objMonitor    the source object for which to save the monitoring messages
     */
    public static void saveMonitoringMessages(System.Type objMonitor) {
        saveMonitoringMessages(objMonitor, false);
    }

    /**
     * @Jira RBX-331
     * Save all monitoring messages regardless of source object type
     */
    public static void saveMonitoringMessages() {
        saveMonitoringMessages(null, true);
    }

    /**
     * @Jira RBX-331
     * Save monitoring messages to Debug Parent and Debug Message objects for a source object type
     * So you can save only debug log coming from Trigger using <object>.class,
     * Or if you want to output only from a class you can specify <class-name>.class instead
     *
     * @param objMonitor    the source object for which to save the monitoring messages
     * @param saveAll       set True to save messages for all source objects
     */
    @TestVisible
    private static void saveMonitoringMessages(System.Type objMonitor, Boolean saveAll) {

        // check the monitoring message map has messages
        if (saveMonitoringMessagesMap != null) {

            Integer parentCount = 0;
            Map<Integer, Debug_Parent__c> newDbgParents = new Map<Integer, Debug_Parent__c>();
            Map<Integer, Debug_Message__c[]> newDbgMessages = new Map<Integer, Debug_Message__c[]>();

            // for each source object type
            for (System.Type eachType : saveMonitoringMessagesMap.keySet()) {

                // check if we are to only save one source object type or all
                if (saveAll || objMonitor == eachType) {

                    // get the messages for the source object from the monitoring map
                    Map<String, List<ErrorMessage>> saveMsgs = saveMonitoringMessagesMap.get(eachType);

                    for (String ky : saveMsgs.keySet()) {

                        // create a Debug Parent for each item type
                        newDbgParents.put(parentCount, new Debug_Parent__c(
                                Source__c = (eachType == null ? null : eachType.getName()),
                                Message_Type__c = ky
                        ));

                        for (ErrorMessage errMsg : saveMsgs.get(ky)) {

                            // create the Debug Message record
                            Debug_Message__c newDbg = new Debug_Message__c(Message__c = errMsg.msg);

                            // update additional field values
                            newDbg = (Debug_Message__c) UtilsSObject.setSObjectFields(newDbg, errMsg.additionalFields);

                            // make a list of debug messages for this parent
                            if (!newDbgMessages.containsKey(parentCount)) {
                                newDbgMessages.put(parentCount, new Debug_Message__c[]{
                                });
                            }

                            // add a new Debug Message record to the list
                            newDbgMessages.get(parentCount).add(newDbg);
                        }
                        ++parentCount;
                    }
                }
            }

            // save Debug Parent and Debug Message records
            insertDebugRecords(newDbgParents, newDbgMessages);

            // remove saved messages from the monitor message map
            if (saveAll) {
                saveMonitoringMessagesMap.clear();
            }
            else {
                saveMonitoringMessagesMap.remove(objMonitor);
            }
        }
    }

    /**
     * @Jira RBX-331
     * Performs the DML insert to save the Debug Parent and Debug Message records. Links the Debug Message records to
     * the correct Debug Parent and checks the DML Statements and Rows are within governor limits.
     *
     * @param newDbgParents     the Debug Parent records mapped by parent index
     * @param newDbgMessages    a list of Debug Messages associated with each parent index
     * @return {Boolean}        returns True if the insert is successful
     */
    @TestVisible
    private static Boolean insertDebugRecords( Map<Integer, Debug_Parent__c> newDbgParents,
            Map<Integer, Debug_Message__c[]> newDbgMessages ) {

        // Don't let any trappable errors cause the transaction to fail
        try {
            // check we have sufficient governor limits for number of DML statements
            if (Limits.getDmlStatements() <= (Limits.getLimitDmlStatements() -2)) {

                // save debug parent records
                if (!newDbgParents.isEmpty()) {

                    // check we have sufficient governor limits (number of DML records) for the Debug Parent records
                    if (newDbgParents.size() + Limits.getDmlRows() < Limits.getLimitDmlRows()) {

                        insert newDbgParents.values();

                        // create list of Debug Messages with link to correct Debug Parent record
                        Debug_Message__c[] totalDbgMessages = new Debug_Message__c[]{};
                        for (Integer thisParent : newDbgMessages.keySet()) {
                            Debug_Parent__c debugParent = newDbgParents.get(thisParent);
                            for (Debug_Message__c debugMessage : newDbgMessages.get(thisParent)) {
                                debugMessage.Debug_Parent__c = debugParent.Id;

                                // check we have sufficient governor limits (number of DML records) for the Debug Message
                                if (totalDbgMessages.size() + Limits.getDmlRows() < Limits.getLimitDmlRows()) {
                                    totalDbgMessages.add(debugMessage);
                                }
                            }
                        }
                        // save debug message records
                        if (!totalDbgMessages.isEmpty()) {
                            insert totalDbgMessages;
                        }
                    }
                }
            }

            return true;

        }
        catch( Exception e ) {
            System.debug('### Unable to Insert Debug Records : '+e.getMessage());
            return false;
        }
    }

}