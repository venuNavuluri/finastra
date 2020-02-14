public class RLF_SOCreation {
        
        public static Sales_Order__c addRLFSalesOrder( Billing_Group__c bg, Map<String, NS_Currency__c> nsCurrencyMap, SBQQ__Subscription__c s){
            Sales_Order__c so = new Sales_Order__c();
            so.Opportunity__c = bg.Original_Opportunity__c;
            so.Billing_Group__c = bg.Id;
            so.Bill_To_Customer__c = bg.Account_by_Sub__c;
            so.CurrencyIsoCode = bg.CurrencyIsoCode;
            so.Opportunity_Owner__c = bg.Original_Opportunity__r.Owner.FirstName + ' ' + bg.Original_Opportunity__r.Owner.LastName;
            so.Opportunity_Owner_NS_Id__c = bg.Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c;
            so.NS_Term__c = bg.Account_by_Sub__r.Account__r.NS_Term__c;
            so.SO_Credit_Controller__c = bg.Account_by_Sub__r.Account__r.Credit_Controller__c;
            so.NS_Currency__c = nsCurrencyMap.get(bg.CurrencyIsoCode).Id;
            so.Contract__c = bg.Original_Contract__c;
            so.CPQ_Billing__c = true;
            so.NS_Rev_Rec_on_Commit__c = false;
            so.NS_AutoCalculate_VSOE_Allocation__c = false;
            so.Invoice_Credit_Body__c = 'RLF';
            so.Order_Status__c = 'Pending Approval';
            so.Customer_PO_Number__c = bg.Customer_PO_Number__c;
            //so.Order_Date__c = bg.Original_Opportunity__r.CloseDate;
            so.Order_Date__c = system.today();
            so.Order_Type__c = 'RLF';
            so.Sub_Group_Type__c = s.ProdType__c;
            so.PO_Required__c = bg.Account_by_Sub__r.Account__r.PO_Required__c;
            so.Transaction_is_VSOE_Bundle__c = false;
            so.Primary_Sales_Person__c = bg.Original_Opportunity__r.OwnerId;
            so.Contribution__c = 100;
            so.NS_To_Be_Printed__c = bg.Account_by_Sub__r.Invoice_Delivery_Post__c;
            so.NS_To_Be_Emailed__c = bg.Account_by_Sub__r.Invoice_Delivery_Email__c;
            so.NS_Billing_Address__c = bg.NS_Customer_Address__c;
            so.NS_Shipping_Address__c = bg.NS_Customer_Ship_To_Address__c;
            so.Order_End_Date__c = bg.Original_Contract__r.Contract_Expiry_Date__c;
            so.Sales_Role__c = 'Sales Rep';
            so.Fixed_price_associatd_with_this_contract__c = 'No';
            so.Subsription_Status__c = 'Open';
            so.Time_Zone__c = '1';
            so.Document_Memo__c = bg.NS_Specific_Invoice_Wording__c;
            so.Order_Sub_Type__c = 'RLF';
            so.Transaction_Type__c = 'Invoice';
            so.NS_Form_Id__c = '154';
            so.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = s.SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c;
            so.Main_Product__c = s.SBQQ__Product__c;
            so.NS_Cost_Centre_Internal_Id__c = s.SBQQ__Product__r.NS_Cost_Centre_ID__c;
            so.NS_Product_Analysis_Internal_Id__c = s.SBQQ__Product__r.NS_Product_Dimension_ID__c;
            return so;
        }
      
        public static Sales_Order_Item__c addRLFSalesOrderItem(SBQQ__Subscription__c sub, Map<String, NS_Currency__c> nsCurrencyMap, Integer counter, Sales_Order__c so){
            
           Sales_Order_Item__c soItem = new Sales_Order_Item__c(); 
            soItem.Line__c = counter; //Transactions__c,Transactional__c
            soItem.Sales_Order__c = so.Id;
            //soItem.Tax_Code__c = sub.Recurring_Sovos_Code__c;
            soItem.Subscription__c = sub.id; 
            if(sub.SBQQ__Product__r != null && sub.SBQQ__Product__r.name != null)
                if(sub.SBQQ__Product__r.Name.Length()> 80){
                    soItem.Name = sub.SBQQ__Product__r.Name.substring(0, 80);
                }else{
                    soItem.Name = sub.SBQQ__Product__r.Name; 
                } 
            soItem.Ship_From_Code__c = sub.Ship_From_Code__c; 
            soItem.NS_Item__c = sub.SBQQ__Product__c;  
            soItem.Non_GA__c = sub.SBQQ__Product__r.GA__c;
            soItem.Software_Delivered__c = true;
            if(sub.SBQQ__Quantity__c != null)
            soItem.Quantity__c = sub.SBQQ__Quantity__c;
            if(sub.Transactional__c && sub.Transactions__c != null){
                soItem.Transactions__c = sub.Transactions__c;  
                soitem.Transactional__c = sub.Transactional__c;
            }
            if(sub.SO_Amount__c != null){
                soItem.Rate__c = (sub.SO_Amount__c / sub.SBQQ__Quantity__c).setScale(4); 
            }
            if(soItem.Rate__c != null ){
                soItem.Amount__c = (sub.SBQQ__Quantity__c * soItem.Rate__c).setScale(4);    
            }
            system.debug('factor' +(soItem.Amount__c * getProrataFactor(sub)));
            if(soItem.Amount__c != null) soItem.Amount__c =  (soItem.Amount__c * getProrataFactor(sub)).setScale(4);
            if(soItem.Rate__c != null) soItem.Rate__c = soItem.Rate__c * getProrataFactor(sub);
            soItem.VSOE_Price__c = soItem.Amount__c;
            soItem.Fair_Value__c = soItem.Amount__c;
            soItem.VSOE_Allocation_Amount__c = soItem.Amount__c;
            if(sub.SBQQ__ListPrice__c != null) soItem.List_Value__c = sub.SBQQ__ListPrice__c * getProrataFactor(sub);
            soItem.NS_Rev_Rec_Schedule_Internal_Id__c = sub.SBQQ__Product__r.NS_Rev_Rec_Template_ID__c; 
            soItem.CurrencyIsoCode = sub.Billing_Group__r.CurrencyIsoCode;
            soItem.Description__c = (sub.Asset_Name__c != null ? sub.Asset_Name__c : soItem.Name);
            soItem.Discount__c = sub.SBQQ__PartnerDiscount__c;
            soItem.Vendor_BSch_Trigger__c = 'Manual';
            //soitem.ThirdParty_Costs_PO_Ccy__c = sub.ThirdParty_Costs_PO_Ccy__c; 
           // soitem.ThirdParty_Recurring_Costs_PO_Ccy__c = sub.ThirdParty_Recurring_Costs_PO_Ccy__c;
            //soItem.Licence_band__c  = sub.Licence_Band__c;
            //soItem.Licence_Basis__c = sub.License_Metric__c;
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
            if(factor == 0.0 || factor > 1 ) return 1; 
            else return factor;
        }
        
        public static Integer getDaysInYear(Date currentDate){
            
            if(Date.isLeapYear(currentDate.year())){
                return 366;
            } else {
                return 365;
            }
            
        }
    
        public static List<SBQQ__Subscription__c> calculateProrata(Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map) {
        List < SBQQ__Subscription__c > subList = new List < SBQQ__Subscription__c > ();
        Date startDate, endDate;
        Integer fYear;
        List<Billing_Group__c> bgList = new List<Billing_Group__c>();
        
        for (Id bgId: bg_subList_Map.keySet()) {
            startDate = system.today();              
            for (SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
                
                if ((!sub.Pro_Rata_Calculated__c && !sub.Last_Prorata_required__c) && (sub.Billing_Day__c != null)) {
                                   
                                   startDate = sub.Next_Billing_Date__c;
                                   if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                                       if(startDate.day() >= Integer.valueOf(sub.Billing_Day__c)) 
                                        endDate = startDate.addMonths(1);
                                        endDate =  Date.newInstance(endDate.year(),endDate.month(), Integer.valueOf(sub.Billing_Day__c));
                                   }else if(sub.SBQQ__BillingFrequency__c == 'Quarterly'){
                        
                                        Date fiscalYearStartDate;
                                        Integer quarter;
        
                                        if(startDate.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c))
                                        {
                                            fiscalYearStartDate = date.newinstance(startDate.year(), SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                            quarter = ((system.today().month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 3) + 1;
                                        }
                                        else
                                        {
                                            fiscalYearStartDate = date.newinstance(startDate.year() - 1, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                            SYSTEM.debug('fiscalYearStartDate' + fiscalYearStartDate);
                                            quarter = ((12 + startDate.month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 3) + 1;
                                            SYSTEM.debug('quarter' + quarter);
                                        }   
                                        Integer addMonths = quarter * 3;
                                        Date lastDateOfThisQuarter = fiscalYearStartDate;
        
                                        // this is the last date of the current quarter
                                        //lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths).addDays(-1);
                                        lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths);
                                        endDate = lastDateOfThisQuarter;
                                        SYSTEM.debug('END DATE' +lastDateOfThisQuarter);
                                   }else if(sub.SBQQ__BillingFrequency__c == 'Semiannual'){
                                        Date fiscalYearStartDate;
                                        Integer quarter;
        
                                        if(startDate.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c))
                                        {
                                            fiscalYearStartDate = date.newinstance(startDate.year(), SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                            quarter = ((system.today().month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 6) + 1;
                                        }
                                        else
                                        {
                                            fiscalYearStartDate = date.newinstance(startDate.year() - 1, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                            SYSTEM.debug('fiscalYearStartDate' + fiscalYearStartDate);
                                            quarter = ((12 + startDate.month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 6) + 1;
                                            SYSTEM.debug('quarter' + quarter);
                                        }   
                                        Integer addMonths = quarter * 6;
                                        Date lastDateOfThisQuarter = fiscalYearStartDate;
        
                                        // this is the last date of the current quarter
                                        //lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths).addDays(-1);
                                        lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths);
                                        endDate = lastDateOfThisQuarter;
                                        SYSTEM.debug('END DATE' +lastDateOfThisQuarter);
                                   }else{
                                       if (sub.Next_Billing_Date__c.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                                fYear = sub.Next_Billing_Date__c.year() + 1;
                                                system.debug('added +1 sub date => ' + sub.Next_Billing_Date__c);
                                                //system.debug('added +1 year for Recurring_Fees_Start_Planned__c != null => ' + fYear);
                                            } else {
                                                fYear = sub.Next_Billing_Date__c.year();
                                                system.debug('added +0 year Recurring_Fees_Start_Planned__c != null');
                                            }
                                        endDate = Date.newInstance(fYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), ((Integer) sub.Billing_Day__c)); //(Integer)sub.Billing_Day__c - 1);
                                        system.debug('end month date ' + endDate);
                                   }
                                     system.debug('end months year =>'+SYstem.today().addYears(1));
                                     system.debug('end months month =>'+sub.Billing_Month__c);
                                     system.debug('end month date ' + endDate);
                                    
                                    sub.Prorata_Days__c = Math.abs(endDate.daysBetween(startDate));
                                    //Integer numberOfDays = Date.daysInMonth(fYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c));
                                    sub.Next_billing_Date__c = endDate;
                                    //Date NBD = sub.Next_Billing_Date__c;
                                    if (sub.SO_Generation_Advance__c != null && sub.SBQQ__BillingType__c != null) {
                                        if (sub.SBQQ__BillingType__c == 'Arrears') {
                                            sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays((Integer) sub.SO_Generation_Advance__c);
                                            if (sub.Next_SO_generation_Date__c < System.today())
                                                sub.Next_SO_generation_Date__c = System.today().addDays(1);
                                        }
                                        if (sub.SBQQ__BillingType__c == 'Advance') {
                                            sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c);
                                            if (sub.Next_SO_generation_Date__c < System.today())
                                                sub.Next_SO_generation_Date__c = System.today().addDays(1);
                                        }
                                    }
                                    if (sub.SBQQ__BillingType__c == null || sub.SO_Generation_Advance__c == null){
                                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c;
                                        if (sub.Next_SO_generation_Date__c < System.today())
                                            sub.Next_SO_generation_Date__c = System.today().addDays(1);
                                    }
                                }  
                            else if (sub.Last_Prorata_required__c && sub.Last_Prorata_Calculated__c == false ) { // need to put extra condition
                                sub.Prorata_Days__c = Math.abs(sub.Expiry_Date__c.daysBetween(sub.Next_Billing_Date__c - 1));
                            }
                            subList.add(sub);
            }
            
        }
        
        if (subList.size() > 0) {
            update subList;            
        }
        
        return subList;
    }
    
        
        /*public static void calculateProrata(Map < String, List < SBQQ__Subscription__c >> soType_subs_map, Billing_Group__c bg) {
            List < SBQQ__Subscription__c > subList = new List < SBQQ__Subscription__c > ();
            Date startDate, endDate;
            Integer fYear;
            for (String s: soType_subs_map.keySet()) {
                if (s.contains('RLF')) {
                   system.debug('prorata rlf subs =>'+soType_subs_map.get(s));
                    for (SBQQ__Subscription__c sub: soType_subs_map.get(s)) {
    
                            if ((!sub.Pro_Rata_Calculated__c && !sub.Last_Prorata_required__c) && (sub.Billing_Day__c != null)) {
                               
                               startDate = sub.Next_Billing_Date__c;
                               if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                                   if(startDate.day() >= Integer.valueOf(sub.Billing_Day__c)) 
                                    endDate = startDate.addMonths(1);
                                    endDate =  Date.newInstance(endDate.year(),endDate.month(), Integer.valueOf(sub.Billing_Day__c));
                               }else if(sub.SBQQ__BillingFrequency__c == 'Quarterly'){
                    
                                    Date fiscalYearStartDate;
                                    Integer quarter;
    
                                    if(startDate.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c))
                                    {
                                        fiscalYearStartDate = date.newinstance(startDate.year(), SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                        quarter = ((system.today().month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 3) + 1;
                                    }
                                    else
                                    {
                                        fiscalYearStartDate = date.newinstance(startDate.year() - 1, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                        SYSTEM.debug('fiscalYearStartDate' + fiscalYearStartDate);
                                        quarter = ((12 + startDate.month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 3) + 1;
                                        SYSTEM.debug('quarter' + quarter);
                                    }   
                                    Integer addMonths = quarter * 3;
                                    Date lastDateOfThisQuarter = fiscalYearStartDate;
    
                                    // this is the last date of the current quarter
                                    //lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths).addDays(-1);
                                    lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths);
                                    endDate = lastDateOfThisQuarter;
                                    SYSTEM.debug('END DATE' +lastDateOfThisQuarter);
                               }else if(sub.SBQQ__BillingFrequency__c == 'Semiannual'){
                                    Date fiscalYearStartDate;
                                    Integer quarter;
    
                                    if(startDate.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c))
                                    {
                                        fiscalYearStartDate = date.newinstance(startDate.year(), SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                        quarter = ((system.today().month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 6) + 1;
                                    }
                                    else
                                    {
                                        fiscalYearStartDate = date.newinstance(startDate.year() - 1, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), Integer.valueOf(sub.Billing_Day__c));
                                        SYSTEM.debug('fiscalYearStartDate' + fiscalYearStartDate);
                                        quarter = ((12 + startDate.month() - SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) / 6) + 1;
                                        SYSTEM.debug('quarter' + quarter);
                                    }   
                                    Integer addMonths = quarter * 6;
                                    Date lastDateOfThisQuarter = fiscalYearStartDate;
    
                                    // this is the last date of the current quarter
                                    //lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths).addDays(-1);
                                    lastDateOfThisQuarter = lastDateOfThisQuarter.addMonths(addMonths);
                                    endDate = lastDateOfThisQuarter;
                                    SYSTEM.debug('END DATE' +lastDateOfThisQuarter);
                               }else{
                                   if (sub.Next_Billing_Date__c.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                            fYear = sub.Next_Billing_Date__c.year() + 1;
                                            system.debug('added +1 sub date => ' + sub.Next_Billing_Date__c);
                                            //system.debug('added +1 year for Recurring_Fees_Start_Planned__c != null => ' + fYear);
                                        } else {
                                            fYear = sub.Next_Billing_Date__c.year();
                                            system.debug('added +0 year Recurring_Fees_Start_Planned__c != null');
                                        }
                                    endDate = Date.newInstance(fYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), ((Integer) sub.Billing_Day__c)); //(Integer)sub.Billing_Day__c - 1);
                                    system.debug('end month date ' + endDate);
                               }
                                 system.debug('end months year =>'+SYstem.today().addYears(1));
                                 system.debug('end months month =>'+sub.Billing_Month__c);
                                 system.debug('end month date ' + endDate);
                                
                                sub.Prorata_Days__c = Math.abs(endDate.daysBetween(startDate));
                                //Integer numberOfDays = Date.daysInMonth(fYear, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c));
                                sub.Next_billing_Date__c = endDate;
                                //Date NBD = sub.Next_Billing_Date__c;
                                if (sub.SO_Generation_Advance__c != null && sub.SBQQ__BillingType__c != null) {
                                    if (sub.SBQQ__BillingType__c == 'Arrears') {
                                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays((Integer) sub.SO_Generation_Advance__c);
                                        if (sub.Next_SO_generation_Date__c < System.today())
                                            sub.Next_SO_generation_Date__c = System.today().addDays(1);
                                    }
                                    if (sub.SBQQ__BillingType__c == 'Advance') {
                                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c);
                                        if (sub.Next_SO_generation_Date__c < System.today())
                                            sub.Next_SO_generation_Date__c = System.today().addDays(1);
                                    }
                                }
                                if (sub.SBQQ__BillingType__c == null || sub.SO_Generation_Advance__c == null){
                                    sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c;
                                    if (sub.Next_SO_generation_Date__c < System.today())
                                        sub.Next_SO_generation_Date__c = System.today().addDays(1);
                                }
                            }  
                        else if (sub.Last_Prorata_required__c && sub.Last_Prorata_Calculated__c == false ) { // need to put extra condition
                            sub.Prorata_Days__c = Math.abs(sub.Expiry_Date__c.daysBetween(sub.Next_Billing_Date__c - 1));
                        }
                        subList.add(sub);
                                            
                    }
                }
            }
            
            if (subList.size() > 0) {
                update subList;
            }
            
        }*/
        
        public static Map<Id, String> updateNextBillingDate(Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map){
        
        List <SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        List <Billing_Group__c> bgList = new List<Billing_Group__c>();
        Id billingGroup;
        Map<Id, String> bgErrorsMap = new Map<Id, String>();
        
        for(Id bgId: bg_subList_Map.keySet()){
            for(SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
                try{
                    if((sub.Billing_Day__c == null && sub.Billing_Month__c == null) || (sub.Pro_Rata_Calculated__c && sub.Next_Billing_Date__c != null) || sub.Last_Prorata_required__c || sub.SBQQ__BillingFrequency__c != null){
                        sub.Last_Billed_Date__c = date.today();
                        if (sub.SBQQ__BillingFrequency__c == 'Monthly') {
                            sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(1);
                            subList.add(sub);
                        } else if (sub.SBQQ__BillingFrequency__c == 'Quarterly') {
                            sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(3);
                            subList.add(sub);
                        } else if (sub.SBQQ__BillingFrequency__c == 'Semiannual') {
                            sub.Next_Billing_Date__c =  sub.Next_Billing_Date__c.addMonths(6);
                            subList.add(sub);
                        } else if (sub.SBQQ__BillingFrequency__c == 'Annual') {
                            sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(1);
                            subList.add(sub);
                        } else if (sub.SBQQ__BillingFrequency__c == 'Biennial') {
                            sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(2); 
                            subList.add(sub);
                        } else if (sub.SBQQ__BillingFrequency__c == 'Triennial') {
                            sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(3); 
                            subList.add(sub);
                        } else if (sub.SBQQ__BillingFrequency__c == 'Quinquennial') {
                            sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(5); 
                            subList.add(sub);
                        }
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
                    
                }Catch (Exception Ex){
                    bgErrorsMap.put(bgId, 'Error: at '+Ex.getLineNumber() +' - ' +Ex.getMessage());
                }
            }
            
            if(bgId != null){
                bgList.add(new Billing_Group__c(Id = bgId,  Last_Invoice_Date__c = system.today(), Recurring_Batch_Error_Logs__c  = null));            
            }
        }
        
        if (subList.size() > 0) {
            update subList;
           // List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();   
           // newSubList.addAll(noNBD_subSet);
            // RLFPackage_ListInit.zeroProrataDays(newSubList);
            if(bgList.size() > 0){                
                Database.SaveResult[] srList = Database.update(bgList, false);
                
                // looping over solist                
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {                    
                        System.debug('Successfully updated Billing Group. BG ID: ' + sr.getId());
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
        
    }
    
        public static void updateProrataCalculatedCheckBox(List < Sales_Order_Item__c > itemsList) {
            Map < Id, Id > sub_soi_map = new Map < Id, Id > ();
            for (Sales_Order_Item__c soi: [SELECT Id, subscription__c FROM Sales_Order_Item__c WHERE Id IN: itemsList]) {
                sub_soi_map.put(soi.Subscription__c, soi.Id);
            }
            List < SBQQ__Subscription__c > sub_prorataList = new List < SBQQ__Subscription__c > ();
            for (SBQQ__Subscription__c sub: [SELECT Id, Expiry_Date__c, Next_Billing_Date__c, Next_SO_generation_Date__c, Pro_Rata_Calculated__c, Last_Prorata_required__c, Last_Prorata_Calculated__c, Prorata_Days__c FROM SBQQ__Subscription__c WHERE Id IN: sub_soi_map.keySet()]) {
                sub.Pro_Rata_Calculated__c = true;
                sub.Prorata_Days__c = 0;
                if (sub.Next_Billing_Date__c >= sub.Expiry_Date__c) {
                    sub.Last_Prorata_Calculated__c = true;
                    sub.Next_SO_generation_Date__c = null;
                    sub.Next_Billing_Date__c = null;
                }
                sub_prorataList.add(sub);
                if (sub_prorataList.size() > 0) {
                    update sub_prorataList;
                }
            }
        }
    
        public static void bgDatesUpdate(Id[] bgIdList){
        
        system.debug('bg id list in finish method => '+bgIdList);
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List <Date> nBD = new List<Date>();
        List <Date> nSoGD = new List<Date>();
        Billing_Group__c bg;
        for(SBQQ__Subscription__c sub: [SELECT 
                                        Id, 
                                        Billing_Group__c,
                                        Next_Billing_Date__c, 
                                        Next_SO_generation_Date__c
                                        FROM
                                        SBQQ__Subscription__c 
                                        WHERE 
                                        Sales_Order_Type__c LIKE 'RLF%' 
                                        AND Billing_Status__c = 'Active billing'
                                        AND Billing_Group__c in : bgIdList
                                       ] ){
                                           if(bg_subList_Map.get(sub.Billing_Group__c)!=null) {
                                               bg_subList_Map.get(sub.Billing_Group__c).add(sub);
                                           } else {
                                               bg_subList_Map.put(sub.Billing_Group__c,new List<SBQQ__Subscription__c>{sub});
                                           }
                                       }
        
        system.debug('bg subs map => '+bg_subList_Map);
        List<Billing_Group__c> update_bgList = new List<Billing_Group__c>();
        for(Id bgId: bg_subList_Map.keySet()){
            nBD.clear();
            nSoGD.clear();
           // update_bgList.add(updateDates(bg, bg_subList_Map.get(bg)));  
            for(SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
            if(sub.Next_Billing_Date__c != null && sub.Next_SO_generation_Date__c != null){
                nBD.add(sub.Next_Billing_Date__c);
                nSoGD.add(sub.Next_SO_generation_Date__c);
            }
        }
            
        
        if(nBD.size() > 0 && nSoGD.size() > 0) {
            nBD.sort();nSoGD.sort();
            bg = new Billing_Group__c(Id = bgId, Next_Billing_Date__c = nBD[0], Next_SO_generation_Date__c = nSoGD[0]);
            update_bgList.add(bg);
        } else {
            bg = new Billing_Group__c(Id = bgId, Next_Billing_Date__c = null, Next_SO_generation_Date__c = null); 
            update_bgList.add(bg);
        }
        }
        if(!update_bgList.isempty()){
            try{
                update update_bgList;
                system.debug('updated update_bgList');
            } Catch (Exception Ex){
                system.debug('Failed to update update_bgLIst; reason => '+Ex.getMessage());
            }
        }
    }
     
    }