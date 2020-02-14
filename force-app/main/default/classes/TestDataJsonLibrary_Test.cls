@IsTest
private class TestDataJsonLibrary_Test {

    @IsTest
    static void testStandard() {
        // GIVEN nothing
        // WHEN TestDataJsonLibrary.Standard class is instantiated
        TestDataJsonLibrary.Standard standard = new TestDataJsonLibrary.Standard();
        // THEN the Json map is available
        Map<String, String> jsonMap = standard.jsonMap;
        System.assertEquals(true, jsonMap != null);
        // AND contains expected values
        Set<String> supportedMappings = new Set<String>{ Constants.TDF_USER, Constants.TDF_ACCOUNT,
                Constants.TDF_CONTACT, Constants.TDF_LEAD, Constants.TDF_OPPORTUNITY, Constants.TDF_OPP_LINE_ITEM,
                Constants.TDF_OPP_CONTACT_ROLE, Constants.TDF_PRODUCT };
        System.assertEquals(true, jsonMap.keySet().containsAll(supportedMappings));
    }

    @IsTest
    static void testCustom() {
        // GIVEN nothing
        // WHEN TestDataJsonLibrary.Custom class is instantiated
        TestDataJsonLibrary.Custom custom = new TestDataJsonLibrary.Custom();
        // THEN the Json map is available
        Map<String, String> jsonMap = custom.jsonMap;
        System.assertEquals(true, jsonMap != null);
        // AND contains expected values
        Set<String> supportedMappings = new Set<String>{ Constants.TDF_CUSTOM_ACCOUNT };
        System.assertEquals(true, jsonMap.keySet().containsAll(supportedMappings));
    }

}