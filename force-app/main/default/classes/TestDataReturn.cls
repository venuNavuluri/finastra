/**
 * @author Steve Fouracre, Tony Bave
 * RBX-317
 * This class creates SObjects from JSON strings, from TestDataJsonLibrary or custom json strings
 */
public abstract class TestDataReturn implements ITestData{

    /**
     * Creates a list of SObjects from a JSON string and sets required field values
     *
     * @param jsonStr       the JSON string representing the SObject to create
     * @param fieldValues   a map of field name/value pairs to be set in each SObject
     *
     * @return a list of SObjects with the field values set
     */
    public List<SObject> prepareSObject(String jsonStr, Map<String, Object> fieldValues) {

        // make sure it is a list
        if (!jsonStr.startsWith('[')) {
            jsonStr = '[' + jsonStr + ']';
        }

        // deserialize the JSON to create the list of objects
        List<SObject> sObj = (List<SObject>) System.JSON.deserialize(jsonStr, List<SObject>.class);

        // apply the additional field values specified
        if (fieldValues != null) {
            // for each SObject
            for (SObject so : sObj) {
                so = UtilsSObject.setSObjectFields(so, fieldValues);
            }
        }

        return sObj;
    }

}