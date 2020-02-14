public interface ITestData {
    List<SObject> prepareSObject(String jsonStr, Map<String, Object> fieldValues);
}