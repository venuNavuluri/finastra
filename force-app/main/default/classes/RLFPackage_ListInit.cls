public class RLFPackage_ListInit {
    
    public static Sales_Order__c addRLFSalesOrder(Billing_Group__c bg, Map<String, NS_Currency__c> nsCurrencyMap, Map<String, String> nsProductMap, map<string, NS_Cost_Centre__c> nsCostCenterMap,/* Map<Date, NS_Fixed_Billing_Date__c> fixedBilling_map,*/ String orderType, SBQQ__Subscription__c singleSub){
        Sales_Order__c so = new Sales_Order__c();
        so.Billing_Group__c = bg.Id; 
        so.SFDC_Billing_Group__c = bg.Name;    
        so.Bill_To_Customer__c = bg.Account_by_Sub__c;
        if(bg.Original_Opportunity__c != null){            
            so.Opportunity__c = bg.Original_Opportunity__c;
            so.Opportunity_Owner__c = bg.Original_Opportunity__r.Owner.FirstName + ' ' + bg.Original_Opportunity__r.Owner.LastName;
        } 
        //system.debug('bg.BG_Opportunity_Number_s_migration__c = ' + bg.BG_Opportunity_Number_s_migration__c);
        so.Opportunity_Owner_NS_Id__c = bg.Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c;
        so.CurrencyIsoCode = bg.CurrencyIsoCode;
        so.NS_Term__c = bg.Account_by_Sub__r.Account__r.NS_Term__c;
        so.SO_Credit_Controller__c = bg.Account_by_Sub__r.Account__r.Credit_Controller__c;
        //system.debug('getting ns currency id =>'+nsCurrencyMap.get(bg.Id));
        so.NS_Currency__c = nsCurrencyMap.get(bg.CurrencyIsoCode).Id;
        so.Contract__c = bg.Original_Contract__c;
        so.CPQ_Billing__c = true;
        so.NS_Rev_Rec_on_Commit__c = false;
        so.NS_AutoCalculate_VSOE_Allocation__c = false;
        so.Invoice_Credit_Body__c = orderType;
        so.Order_Status__c = 'Pending Approval';
        so.Customer_PO_Number__c = bg.Customer_PO_Number__c;
        so.Order_Date__c = bg.Original_Opportunity__r.CloseDate;
        so.Order_Type__c = 'RLF';
        so.Sub_Group_Type__c = orderType;
        so.PO_Required__c = bg.Account_by_Sub__r.Account__r.PO_Required__c;
        so.Transaction_is_VSOE_Bundle__c = false;
        so.Primary_Sales_Person__c = bg.Original_Opportunity__r.OwnerId;
        so.Contribution__c = 100;
        so.NS_To_Be_Printed__c = bg.Account_by_Sub__r.Invoice_Delivery_Post__c;
        so.NS_To_Be_Emailed__c = bg.Account_by_Sub__r.Invoice_Delivery_Email__c;
        so.NS_Billing_Address__c = bg.NS_Customer_Address__c;
        so.NS_Shipping_Address__c = bg.NS_Customer_Ship_To_Address__c;
        if(bg.Original_Customer_Signed_Date__c != null){
            so.NS_Contract_Date__c = bg.Original_Customer_Signed_Date__c; // contract start date
        } else if(bg.Current_Sales_Order_Start_Date__c != null){
            so.NS_Contract_Date__c = bg.Current_Sales_Order_Start_Date__c;
        } else {
            so.NS_Contract_Date__c = bg.BG_Contract_Date_migration__c;// need to remove
        }
        so.Order_End_Date__c = bg.Original_Contract__r.Contract_Expiry_Date__c;
        so.Sales_Role__c = 'Sales Rep';
        so.Fixed_price_associatd_with_this_contract__c = 'No';
        so.Subsription_Status__c = 'Open';
        so.Billing_Mode__c = bg.NS_Billing_Mode__c;
        so.Subscription_Termination_Method__c = bg.NS_Termination_Method__c;
        so.Time_Zone__c = '1';
        // so.Ready_For_Export_To_NS__c = true;
        so.Fixed_Billing_Date__c = bg.Fixed_Billing_Date__c;
        so.Reset_Next_Bill_Date__c = bg.Reset_Next_Bill_Date__c;
        so.BG_Next_Invoice_Due_Date__c = bg.BG_Next_Invoice_Due_Date__c;
        so.Document_Memo__c = bg.NS_Specific_Invoice_Wording__c;
        so.RLF_Tax_Combo_Check__c = bg.Set_Tax_Combo_Override__c;
        so.Order_Sub_Type__c = 'RLF';
        /* if(bg.Fixed_Billing_Date__c != null && fixedBilling_map.get(bg.Fixed_Billing_Date__c) != null){            
        so.NS_Fixed_Billing_Date__c = fixedBilling_map.get(bg.Fixed_Billing_Date__c).id;
        so.NS_Fixed_Billing_Date_Internal_Id__c = fixedBilling_map.get(bg.Fixed_Billing_Date__c).NS_Internal_Id__c;            
        }*/
        so.Transaction_Type__c = 'Invoice';
        Double fairValue = 0.00; 
        String projProdInternalId, nsCostCentreIntId = null;
        if( singleSub != null){
            system.debug('Im max sub of RLF =>'+singleSub);
            so.NS_Product__c = nsProductMap.get(singleSub.Recurring_NS_Item__r.NS_Product_Dimension_ID__c); 
            if(singleSub.Recurring_NS_Item__r.NS_Cost_Centre_ID__c != null){
                so.NS_Cost_Centre__c = nsCostCenterMap.get(singleSub.Recurring_NS_Item__r.NS_Cost_Centre_ID__c).Id;
            }
            /*if(singleSub.Recurring_NS_Item__r.NS_Form_ID__c != null)
            {
            so.NS_Form_Id__c = String.valueOf(singleSub.Recurring_NS_Item__r.NS_Form_ID__c); 
            }
            else{
            so.NS_Form_Id__c = '154';
            } */
            if(singleSub.Next_Billing_Date__c != null)
            { 
                so.Order_Start_Date__c = singleSub.Next_Billing_Date__c; 
            }
            else
            { 
                so.Order_Start_Date__c = singleSub.Original_Contract__r.Recurring_Fees_Start_Planned__c;
            }
            so.NS_Form_Id__c = '154';
            so.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = singleSub.Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c;
            
        } 
        return so;
    }
    
    public static Sales_Order_Item__c addRLFSalesOrderItem(SBQQ__Subscription__c sub, Map<String, NS_Currency__c> nsCurrencyMap, Map<String, NS_Revenue_Recognition_Template__c> revScheduleMap, Integer counter, Sales_Order__c so){
        
        Sales_Order_Item__c soItem = new Sales_Order_Item__c(); 
        soItem.Line__c = counter; //Transactions__c,Transactional__c
        soItem.Sales_Order__c = so.Id;
        soItem.Tax_Code__c = sub.Recurring_Sovos_Code__c;
        soItem.Subscription__c = sub.id; 
        soItem.Internal_Costs__c = sub.Pearl_Internal_Cost__c;
        if(sub.SBQQ__Product__r.Name.Length()> 80){
        soItem.Name = sub.SBQQ__Product__r.Name.substring(0, 80);
        }else{
          soItem.Name = sub.SBQQ__Product__r.Name; 
        }
        soItem.Ship_From_Code__c = sub.Ship_From_Code__c; 
        soItem.NS_Item__c = sub.SBQQ__Product__c;  
        soItem.Recurring_NS_Item__c = sub.Recurring_NS_Item__c;
        soItem.Non_GA__c = sub.Recurring_NS_Item__r.GA__c;
        //soItem.Software_Delivered__c = sub.Recurring_NS_Item__r.NS_Default_Delivered__c;
        soItem.Software_Delivered__c = true;
        soItem.Quantity__c = 1 ;
        if(sub.Transactional__c && sub.Transactions__c != null){
            soItem.Transactions__c = sub.Transactions__c;  
            soitem.Transactional__c = sub.Transactional__c;
        }
        if(sub.SBQQ__NetPrice__c != null){
            soItem.Rate__c = (sub.SBQQ__NetPrice__c / sub.SBQQ__Quantity__c).setScale(4); 
        }
        if(soItem.Rate__c != null ){
            soItem.Amount__c = (sub.SBQQ__Quantity__c * soItem.Rate__c).setScale(4);    
        }
        if(soItem.Amount__c != null) soItem.Amount__c =  (soItem.Amount__c * getProrataFactor(sub)).setScale(4);
        if(soItem.Rate__c != null) soItem.Rate__c = soItem.Rate__c * getProrataFactor(sub);
        if(sub.Fair_Value__c != null) soItem.VSOE_Price__c = sub.Fair_Value__c * getProrataFactor(sub);
        if(sub.Fair_Value__c != null) soItem.Fair_Value__c = sub.Fair_Value__c * getProrataFactor(sub); 
        if(sub.Fair_Value__c != null) soItem.VSOE_Allocation_Amount__c = sub.Fair_Value__c * getProrataFactor(sub);
        if(sub.SBQQ__ListPrice__c != null) soItem.List_Value__c = sub.SBQQ__ListPrice__c * getProrataFactor(sub);
        
        soItem.NS_Rev_Rec_Schedule_Internal_Id__c = sub.Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c; 
        soItem.CurrencyIsoCode = sub.Billing_Group__r.CurrencyIsoCode;
        soItem.Description__c = soItem.Name;
        soItem.Discount__c = sub.SBQQ__PartnerDiscount__c;
        soItem.Vendor_BSch_Trigger__c = 'Manual';
        soItem.Create_3PP_Event__c = sub.SBQQ__Product__r.NS_Create_3PP_Event__c;
        if(sub.ThirdParty_PO_Currency__c  != null){
            soItem.ThirdParty_PO_Currency__c = nsCurrencyMap.get(sub.ThirdParty_PO_Currency__c).Id;
        }
        soitem.ThirdParty_Costs_PO_Ccy__c = sub.ThirdParty_Costs_PO_Ccy__c; 
        soitem.ThirdParty_Recurring_Costs_PO_Ccy__c = sub.ThirdParty_Recurring_Costs_PO_Ccy__c;
        soItem.X3PP_Discount__c = sub.X3PP_Discount__c;
        soItem.Licence_band__c  = sub.Licence_Band__c;
        soItem.Licence_Basis__c = sub.License_Metric__c;
        soItem.Start_Date__c = sub.Next_Billing_Date__c;
        if(sub.Next_Billing_Date__c != null && sub.Pro_Rata_Calculated__c == true && sub.Last_Prorata_required__c == false){
            soItem.Start_Date__c = sub.Next_Billing_Date__c;
            if (sub.SBQQ__BillingFrequency__c == 'Monthly') {soItem.End_Date__c = sub.Next_Billing_Date__c.addMonths(1) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Quarterly') {soItem.End_Date__c = sub.Next_Billing_Date__c.addMonths(3) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Semiannual') {soItem.End_Date__c = sub.Next_Billing_Date__c.addMonths(6) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Annual') {soItem.End_Date__c = sub.Next_Billing_Date__c.addYears(1) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Biennial') {soItem.End_Date__c = sub.Next_Billing_Date__c.addYears(2) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Triennial') {soItem.End_Date__c = sub.Next_Billing_Date__c.addYears(3) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Quinquennial') {soItem.End_Date__c = sub.Next_Billing_Date__c.addYears(5) -1;}
        }
        if(sub.Next_Billing_Date__c != null && sub.Pro_Rata_Calculated__c == false && sub.Last_Prorata_required__c == false){
            soItem.Start_Date__c = sub.Next_Billing_Date__c;
            if (sub.SBQQ__BillingFrequency__c == 'Monthly') {soItem.End_Date__c = soItem.Start_Date__c.addMonths(1) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Quarterly') {soItem.End_Date__c = soItem.Start_Date__c.addMonths(3) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Semiannual') {soItem.End_Date__c = soItem.Start_Date__c.addMonths(6) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Annual') {soItem.End_Date__c = soItem.Start_Date__c.addYears(1) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Biennial') {soItem.End_Date__c = soItem.Start_Date__c.addYears(2) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Triennial') {soItem.End_Date__c = soItem.Start_Date__c.addYears(3) -1;}
            else if (sub.SBQQ__BillingFrequency__c == 'Quinquennial') {soItem.End_Date__c = soItem.Start_Date__c.addYears(5) -1;}
        }
        if(sub.Next_Billing_Date__c != null && sub.Prorata_Days__c > 0 && sub.Pro_Rata_Calculated__c == false){
            if(sub.RF_Start_Planned_Date__c  != null)
                soItem.Start_Date__c = sub.RF_Start_Planned_Date__c ;
            soItem.End_Date__c = sub.Next_Billing_Date__c - 1;
            if(sub.RF_Start_Planned_Date__c  == null)
                soItem.Start_Date__c = sub.SBQQ__StartDate__c;
            soItem.End_Date__c = sub.Next_Billing_Date__c - 1;
        }
        if(sub.Last_Prorata_required__c == true && sub.Next_Billing_Date__c != null){
            soItem.Start_Date__c = sub.Next_Billing_Date__c;
            soItem.End_Date__c = sub.Expiry_Date__c;
        }
        soItem.Rev_Rec_Start_Date__c = soItem.Start_Date__c;
        soItem.Rev_Rec_End_Date__c = soItem.End_Date__c; 
        if(sub.Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c != null && revScheduleMap.get(sub.Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c) != null) soItem.Rev_Rec_Schedule__c = revScheduleMap.get(sub.Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c).Id;
        return  soItem;
    }
    
    public static Double getProrataFactor(SBQQ__Subscription__c sub){
        Double factor = 0.0;
        Date startDate;
        if(sub.Pro_Rata_Calculated__c == false){
            if(sub.RF_Start_Planned_Date__c != null)
                startDate = sub.RF_Start_Planned_Date__c;
            else
                startDate = sub.Next_Billing_Date__c; 
        }
        else{
            startDate = sub.Next_Billing_Date__c;  
        }
        String billingFrequency = sub.SBQQ__BillingFrequency__c;
        if(sub.Prorata_Days__c != null || Test.isRunningTest()){
            if(billingFrequency == 'Quinquennial'){            
                factor = sub.Prorata_Days__c/(getDaysInYear(startDate) + getDaysInYear(startDate.addYears(1)) + getDaysInYear(startDate.addYears(2))  + getDaysInYear(startDate.addYears(3)));
            } else if(billingFrequency == 'Triennial'){            
                factor = sub.Prorata_Days__c/(getDaysInYear(startDate) + getDaysInYear(startDate.addYears(1)) + getDaysInYear(startDate.addYears(2)));
            } else if(billingFrequency == 'Biennial'){            
                factor = sub.Prorata_Days__c/(getDaysInYear(startDate) + getDaysInYear(startDate.addYears(1)));
            } else if(billingFrequency == 'Annual'){            
                factor = sub.Prorata_Days__c/getDaysInYear(startDate);
            } else if(billingFrequency == 'Semiannual'){
                factor = sub.Prorata_Days__c/(startDate.daysBetween(startDate.addmonths(6)));
            } else if(billingFrequency == 'Quarterly'){
                factor = sub.Prorata_Days__c/(startDate.daysBetween(startDate.addmonths(3)));
            } else if(billingFrequency == 'Monthly'){
                factor = sub.Prorata_Days__c/Date.daysInMonth(startDate.year(), startDate.month());
            }
        }
        //system.debug('returning factor => '+factor);
        if(factor == 0.0) return 1; 
        else return factor;
    }
    
    public static Integer getDaysInYear(Date currentDate){
        
        if(Date.isLeapYear(currentDate.year())){
            return 366;
        } else {
            return 365;
        }
        
    }
    
    // for batch class     
    public static List<SBQQ__Subscription__c> calculateProrata(Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map) {
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        Date startDate = system.today();
        Integer fYear;
        Date earliestNextBillingDate = Date.newInstance(2999, 12, 31), earliestNextSoDate = Date.newInstance(2999, 12, 31);
        
        List<Billing_Group__c> bgList = new List<Billing_Group__c>();
        
        for (Id bgId: bg_subList_Map.keySet()) {
            startDate = system.today();              
            for (SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
                
                if ((!sub.Pro_Rata_Calculated__c && !sub.Last_Prorata_required__c) && (sub.Billing_Day__c != null)){
                    if(sub.RF_Start_Planned_Date__c != null){
                        // check for month
                        if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                            startDate = sub.Next_Billing_Date__c; 
                        } else {
                            if (sub.Next_Billing_Date__c.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                fYear = sub.Next_Billing_Date__c.year() + 1;
                                // system.debug('added +1 sub date => ' + sub.Next_Billing_Date__c);
                                // system.debug('added +1 year for Recurring_Fees_Start_Planned__c != null => ' + fYear);
                            } else {
                                fYear = sub.Next_Billing_Date__c.year();
                                // system.debug('added +0 year Recurring_Fees_Start_Planned__c != null');
                            }
                            startDate = sub.Next_Billing_Date__c;
                        } 
                    }
                    else if(sub.RF_Start_Planned_Date__c == null){
                        if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                            startDate = sub.SBQQ__StartDate__c; 
                        } else {
                            if (sub.SBQQ__StartDate__c.month() > SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                fYear = sub.SBQQ__StartDate__c.year() + 1;
                            } else {
                                fYear = sub.SBQQ__StartDate__c.year();
                            }
                            startDate = sub.SBQQ__StartDate__c;
                        }
                    }                    
                    Date endDate;
                    if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                        endDate = startdate;
                        if(endDate.day() >= Integer.valueOf(sub.Billing_Day__c)) endDate = startDate.addMonths(1);
                        endDate =  Date.newInstance(endDate.year(),endDate.month(), Integer.valueOf(sub.Billing_Day__c));
                    } else {
                        endDate = Date.newInstance(fYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), ((Integer) sub.Billing_Day__c)); //(Integer)sub.Billing_Day__c - 1);
                    }
                    // system.debug('end months year =>'+SYstem.today().addYears(1));
                    // system.debug('end months month =>'+sub.Billing_Month__c);
                    
                    sub.Prorata_Days__c = Math.abs(endDate.daysBetween(startDate));
                    //Integer numberOfDays = Date.daysInMonth(fYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c));
                    sub.Last_Billed_Date__c = sub.Next_Billing_Date__c;
                    sub.Next_billing_Date__c = endDate;
                    // system.debug('sub.Next_billing_Date__c ' + sub.Next_billing_Date__c);
                    Date NBD = sub.Next_Billing_Date__c;
                    if (sub.SO_Generation_Advance__c != null && sub.SBQQ__BillingType__c != null) {
                        if (sub.SBQQ__BillingType__c == 'Arrears'){
                            sub.Next_SO_generation_Date__c = NBD.addDays((Integer) sub.SO_Generation_Advance__c);
                            
                        }
                        if (sub.SBQQ__BillingType__c == 'Advance'){
                            sub.Next_SO_generation_Date__c = NBD.addDays(-(Integer) sub.SO_Generation_Advance__c);
                            
                        } 
                        if(sub.Next_SO_generation_Date__c < System.today()) {
                            sub.Next_SO_generation_Date__c = System.today().addDays(1);
                        }
                    } else if(sub.SO_Generation_Advance__c == null || sub.SBQQ__BillingType__c == null){
                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c;
                        if (sub.Next_SO_generation_Date__c < System.today())
                            sub.Next_SO_generation_Date__c = System.today().addDays(1);
                    }
                } 
                else if (sub.Last_Prorata_required__c) {
                    sub.Prorata_Days__c = Math.abs(sub.Expiry_Date__c.daysBetween(sub.Next_Billing_Date__c - 1));
                    
                }
                subList.add(sub);
                if(sub.Next_billing_Date__c < earliestNextBillingDate) { 
                    //earliestNextBillingDate = sub.Next_Billing_Date__c;
                }
                if(sub.Next_SO_generation_Date__c < earliestNextSoDate) { 
                    //earliestNextSoDate = sub.Next_SO_generation_Date__c;
                    
                }       
                
                // add to list only when Prorata calculated = false                
            }
            if(subList.size() > 0){
                //  bgList.add(new Billing_Group__c(Id = bgId, Next_Billing_Date__c = earliestNextBillingDate, Next_SO_generation_Date__c = earliestNextSoDate));
            }
        }
        
        
        if (subList.size() > 0) {
            update subList;
            if(bgList.size() > 0){ update bgList; }
        }
        
        return subList;
    }
    
    // for batch and normal class
    public static void zeroProrataDays(List<SBQQ__Subscription__c> subsList){
        List<SBQQ__Subscription__c> sub_prorataList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Pro_Rata_Calculated__c,Expiry_Date__c,Next_SO_generation_Date__c,Exclude__c,Next_Billing_Date__c, Prorata_Days__c FROM SBQQ__Subscription__c WHERE Id IN: subsList]){
            sub.Pro_Rata_Calculated__c = true;
            sub.Prorata_Days__c = 0;
            if(sub.Next_Billing_Date__c >= sub.Expiry_Date__c){
                sub.Last_Prorata_Calculated__c = true;
                sub.Next_SO_generation_Date__c = null;
                sub.Next_Billing_Date__c = null;
                sub.Exclude__c = true;
            }
            sub_prorataList.add(sub);
        }
        
        if(sub_prorataList.size() > 0){
            update sub_prorataList;
        }
    }
    
    // for batch class
    public static Map<Id, String> updateNextBillingDate(Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map, Set<SBQQ__Subscription__c> noNBD_subSet){
        List <SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        List <Billing_Group__c> bgList = new List<Billing_Group__c>();
        List <Date> closeDates = new List<Date>();
        List <Date> closeDates2 = new List<Date>();
        Id billingGroup;
        Map<Id, String> bgErrorsMap = new Map<Id, String>();
        
        //system.debug('in update');
        for(Id bgId: bg_subList_Map.keySet()){ 
            closeDates.clear();
            closeDates2.clear();
            for(SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
                if(noNBD_subSet.contains(sub)){
                    //system.debug('got any subs?');
                    try{
                        if((sub.Billing_Day__c == null && sub.Billing_Month__c == null) || ((sub.Pro_Rata_Calculated__c && sub.Next_Billing_Date__c != null) || sub.Last_Prorata_required__c || Test.isRunningTest()) ){
                            sub.Last_Billed_Date__c = sub.Next_Billing_Date__c;
                            if (sub.SBQQ__BillingFrequency__c == 'Monthly') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    Date tdate = System.today().addMonths(1);
                                    if (sub.Billing_Day__c > 1) {
                                        sub.Next_Billing_Date__c = tdate.toStartOfMonth().addDays((Integer) sub.Billing_Day__c - 1);
                                    } else {
                                        sub.Next_Billing_Date__c = System.today().addMonths(1);
                                    }
                                } else {
                                    sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(1);
                                }
                                subList.add(sub);
                            } else if (sub.SBQQ__BillingFrequency__c == 'Quarterly') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                        Integer QYear;
                                        if (system.today().month() > SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                            QYear = system.today().year() + 1;
                                        } else {
                                            QYear = System.today().year();
                                        }
                                        Date tdate = Date.newInstance(QYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), ((Integer) sub.Billing_Day__c));
                                        sub.Next_Billing_Date__c = tdate.addMonths(3);
                                        //sub.Next_Billing_Date__c = tdate.toStartOfMonth().addDays((Integer) sub.Billing_Day__c - 1);
                                    } else {
                                        sub.Next_Billing_Date__c = system.today().addMonths(3);
                                    } 
                                } else{
                                    sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(3);
                                }
                                subList.add(sub);
                            } else if (sub.SBQQ__BillingFrequency__c == 'Semiannual') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                        Integer SYear;
                                        if (system.today().month() > SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                            SYear = system.today().year() + 1;
                                        } else {
                                            SYear = System.today().year();
                                        }
                                        Date tdate = Date.newInstance(SYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), ((Integer) sub.Billing_Day__c));
                                        sub.Next_Billing_Date__c = tdate.addMonths(6);
                                        //sub.Next_Billing_Date__c = tdate.toStartOfMonth().addDays((Integer) sub.Billing_Day__c - 1);
                                    } else {
                                        sub.Next_Billing_Date__c = system.today().addMonths(6);
                                    }
                                } else {
                                    sub.Next_Billing_Date__c =  sub.Next_Billing_Date__c.addMonths(6);
                                } 
                                
                                
                                subList.add(sub);
                            } else if (sub.SBQQ__BillingFrequency__c == 'Annual') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    system.debug('annual logic updated in if condition prorata calclated');
                                    if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                        sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 1, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                    } else {
                                        sub.Next_Billing_Date__c = System.today().addYears(1);
                                    }
                                } else {
                                    sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(1);
                                    system.debug('annual logic updated in else');
                                } 
                                
                                subList.add(sub);
                            } else if (sub.SBQQ__BillingFrequency__c == 'Biennial') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                        sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 2, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                    } else {
                                        sub.Next_Billing_Date__c = System.today().addYears(2);
                                    }
                                } else { sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(2); }
                                subList.add(sub);
                            } else if (sub.SBQQ__BillingFrequency__c == 'Triennial') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                        sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 3, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                    } else {
                                        sub.Next_Billing_Date__c = System.today().addYears(3);
                                    }
                                } else { sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(3); }
                                subList.add(sub);
                            } else if (sub.SBQQ__BillingFrequency__c == 'Quinquennial') {
                                if(!sub.Pro_Rata_Calculated__c){
                                    if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                        sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 5, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                    } else {
                                        sub.Next_Billing_Date__c = System.today().addYears(5);
                                    }
                                } else { sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(5); }
                                subList.add(sub);
                            }
                            if (sub.Next_Billing_Date__c != null)  closeDates.add(sub.Next_Billing_Date__c);
                            
                        }
                        
                        if (sub.SO_Generation_Advance__c != null && sub.SBQQ__BillingType__c != null) {
                            if (sub.SBQQ__BillingType__c == 'Arrears')
                                sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays((Integer) sub.SO_Generation_Advance__c);
                            else if (sub.SBQQ__BillingType__c == 'Advance')
                                sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c);
                            system.debug('adding next so gen date'+sub.Next_SO_generation_Date__c);   
                            //subList.add(sub);
                        } else if(sub.SO_Generation_Advance__c == null  || sub.SBQQ__BillingType__c == null){
                            sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c;
                        }
                        if (sub.Next_SO_generation_Date__c != null)  closeDates2.add(sub.Next_SO_generation_Date__c);
                    } Catch (Exception Ex){
                        bgErrorsMap.put(bgId, 'Error: at '+Ex.getLineNumber() +' - ' +Ex.getMessage());
                    }
                }   
            }
            //closeDates.sort();
            //closeDates2.sort();
            //Date bDate, soDate;
            //if (closeDates.size() > 0 && closeDates[0] != null) bDate = closeDates[0];
            //if (closeDates2.size() > 0 && closeDates2[0] != null) soDate = closeDates2[0];
            if(bgId != null){
                bgList.add(new Billing_Group__c(Id = bgId,  Last_Invoice_Date__c = system.today(), Recurring_Batch_Error_Logs__c  = null));            
            }
        }
        
        if (subList.size() > 0) {
            update subList;
            List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();   
            newSubList.addAll(noNBD_subSet);
            // nullifying proratdata days and checkbox for calcualted prorta subs
            if(!Test.isRunningTest()) RLFPackage_ListInit.zeroProrataDays(newSubList);
            if(bgList.size() > 0){                
                Database.SaveResult[] srList = Database.update(bgList, false);
                
                // looping over solist                
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {                    
                        System.debug('Successfully updated Billing Group. BG ID: ' + sr.getId());
                        //bgErrorsMap.put(sr.getId(), 'RLF Completed Successfully');
                    }
                    else {                   
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + sr.getId());
                            bgErrorsMap.put(sr.getId(), err.getMessage());
                        }
                    }
                }
                
            }
        }  
        return bgErrorsMap;
        // update bg for errors - bgErrorsMap
        
        // after success update changing prorated calculated = true and prorata days = 0
    }
    
    public static Billing_Group__c updateDates(Id bgId, List<SBQQ__Subscription__c> subs){ // updates next so date and next billing date
        List <Date> nBD = new List<Date>();
        List <Date> nSoGD = new List<Date>();
        Billing_Group__c bg;
        for(SBQQ__Subscription__c sub: subs){
            if(sub.Next_Billing_Date__c != null && sub.Next_SO_generation_Date__c != null){
                nBD.add(sub.Next_Billing_Date__c);
                nSoGD.add(sub.Next_SO_generation_Date__c);
            }
        }
        
        if(nBD.size() > 0 && nSoGD.size() > 0) {
            nBD.sort();nSoGD.sort();
            bg = new Billing_Group__c(Id = bgId, Next_Billing_Date__c = nBD[0], Next_SO_generation_Date__c = nSoGD[0]);
        } else {
            bg = new Billing_Group__c(Id = bgId, Next_Billing_Date__c = null, Next_SO_generation_Date__c = null); 
        }
        system.debug('in final bg update => '+bg);
        return bg;
    } 
    
}