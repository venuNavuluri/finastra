/**
 * @author  Steve Fouracre, Tony Bave
 * @Jira    RBX-331
 * A utility class to perform useful functions related to SObject records.
 *
 */
public class UtilsSObject {

    /**
     * @Jira RBX-331
     * Assigns values to any fields of any SObject
     *
     * @param sObj          the SObject record to be updated. If NULL, will return NULL.
     * @param fieldValues   a map of field name/value pairs. If NULL/empty, will return SObject unchanged.
     *
     * @return  the updated SObject
     */
    public static SObject setSObjectFields(SObject sObj, Map<String, Object> fieldValues) {
        if (sObj != null && fieldValues != null) {
            for (String field : fieldValues.keySet()) {
                sObj.put(field, fieldValues.get(field));
            }
        }

        return sObj;
    }

    /**
     * @Jira RBX-332
     * Returns any new SObject records (Id = Null) from a list of SObject records, and removes them from the source list
     * Useful for separating records to be inserted from those that need updating.
     *
     * @param sourceRecords Source list of SObjects.
     *
     * @return {SObject[]}  A list containing only the new records, that were removed from the source list
     */
    public static SObject[] extractNewRecords(SObject[] sourceRecords) {
        SObject[] newRecords = new SObject[]{};
        Integer i = 0;
        while (i < sourceRecords.size()) {
            if (sourceRecords[i].Id == null) {
                newRecords.add(sourceRecords.remove(i));
            }
            else {
                i++;
            }
        }
        return newRecords;
    }

}