/**

REQ-2872 - G.B 20.05.2019
RLFContractHolidayController test class

**/

    @isTest
    public class ContractRLFHolidayController_Test {

        @TestSetup
        static void setupTestData() {
           
            Test.startTest();
            Account acc = TestDataFactory.createAccount('Test Account'); // Inserts a 'Test Account' Account        
            Opportunity opp = TestDataFactory.createOpportunity(acc); // Inserts a 'Test Opp' Opportunity        
            Contract con = TestDataFactory.createContract(acc, opp);
            //Insert product
            Product2 prod = new Product2(Name = 'Product', Product_Set__c = 'Product Family');
            insert prod;
            Billing_Group__c bGroup = TestDataFactory.createBillingGroup(con, false);
            bGroup.Next_Billing_Date__c = Date.today().addDays(365);
            insert bGroup;
            
            SBQQ__Subscription__c arrearsRLFsub = TestDataFactory.createRLF_Subscription(con, false);
            arrearsRLFsub.SBQQ__BillingType__c = 'Arrears';
            arrearsRLFsub.SO_Generation_Advance__c = 5;
            arrearsRLFsub.Billing_Group__c = bGroup.Id;
            arrearsRLFsub.Initial_Sales_Order_Type__c = 'PS - PS';
            arrearsRLFsub.SBQQ__Product__c = prod.Id;
            arrearsRLFsub.RF_Start_Planned_Date__c = Date.today().addDays(60);
            arrearsRLFsub.CPI_Uplift_Review_Date__c = Date.today().addDays(60);
            arrearsRLFsub.Next_Billing_Date__c = Date.today().addDays(60);
            arrearsRLFsub.Next_SO_generation_Date__c = Date.today().addDays(60);
            
            SBQQ__Subscription__c advanceRLFsub = arrearsRLFsub.clone(false);
            advanceRLFsub.SBQQ__BillingType__c = 'Advance';
            advanceRLFsub.RF_Start_Planned_Date__c = Date.today().addDays(120);

            insert new List<SBQQ__Subscription__c>{arrearsRLFsub,advanceRLFsub};
            TestDataFactory.bypassCPQValidation();
            
            Test.stopTest();
        }
        
        private static testMethod void testGetAndSaveSubs (){
            
            User runningUser = TestDataFactory.getRunningUser('M B&RA / CAT profile');
            System.runAs(runningUser){
                List <Contract> contractList = new List <Contract>([Select Id FROM Contract LIMIT 1]);
                
                if(!contractLIst.isEmpty()){
                    Test.startTest();
                        List <SBQQ__Subscription__c> subList = ContractRLFHolidayController.getSubscriptions(contractLIst.get(0).Id);
                        system.assertNotEquals(null, subList);
                        system.assert(!subList.isEmpty());
                        
                        List<String> filterOpts = ContractRLFHolidayController.getRLFsubscriptionTypes(contractLIst.get(0).Id);
                        system.assertNotEquals(null, filterOpts);
                        system.assert(!filterOpts.isEmpty());

                        //User update the date
                        Date originalrLFDate =  subList.get(0).RF_Start_Planned_Date__c;
                        Date originalUpLiftDate =  subList.get(0).CPI_Uplift_Review_Date__c;
                        
                        SBQQ__Subscription__c newSub = subList.get(0).clone(true);
                        newSub.RF_Start_Planned_Date__c = originalrLFDate.addDays(10);
                        newSub.CPI_Uplift_Review_Date__c = originalUpLiftDate.addDays(10);
                        
                        List <SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>{newSub};

                        ContractRLFHolidayController.saveSubscriptions(newSubList);
                        List<SBQQ__Subscription__c> updatedSub = [Select Id,
                                                                   RF_Start_Planned_Date__c,
                                                                   Next_Billing_Date__c,
                                                                   SBQQ__BillingType__c,
                                                                   Next_SO_generation_Date__c,
                                                                   Billing_Group__r.Next_Billing_Date__c,
                                                                   Billing_Group__r.Next_SO_generation_Date__c
                                                                   FROM SBQQ__Subscription__c 
                                                                   WHERE SBQQ__Contract__c =:newSub.SBQQ__Contract__c 
                                                                   ORDER BY RF_Start_Planned_Date__c desc
                                                                   limit 2];
                        
                        system.assertNotEquals(updatedSub.get(0).RF_Start_Planned_Date__c,originalrLFDate);
                        system.assertEquals(updatedSub.get(0).RF_Start_Planned_Date__c,updatedSub.get(0).Next_Billing_Date__c);
                        system.assertEquals(updatedSub.get(0).Next_SO_generation_Date__c,updatedSub.get(0).Next_Billing_Date__c.addDays(-5));
                        
                        system.assertEquals(updatedSub.get(0).Billing_Group__r.Next_Billing_Date__c,updatedSub.get(1).Next_Billing_Date__c);
                        system.assertEquals(updatedSub.get(0).Billing_Group__r.Next_SO_generation_Date__c,updatedSub.get(1).Next_SO_generation_Date__c);
                        //Text Exception
                        try{
                            ContractRLFHolidayController.saveSubscriptions(new List<SBQQ__Subscription__c> ());
                            system.assert(false);
                        }catch (Exception e){
                                system.assertEquals(e.getMessage(), 'No subscriptions to save. Please select at least one subscription and enter a date.');
                        }
                    Test.stopTest();
                }

            }
            
       }
        
   }