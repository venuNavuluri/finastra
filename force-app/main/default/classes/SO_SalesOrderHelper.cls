public class SO_SalesOrderHelper {
    
    public static Sales_Order__c[] createSalesOrder(Billing_Group__c bg, Map < String, Integer > soType_counter_Map, Map < String, NS_Project__c > soType_proj_map, Map < String, NS_Currency__c > nsCurrencyMap, Map < String, String > nsProductMap, /*Map < Date, NS_Fixed_Billing_Date__c > fixedBillingMap,*/ Map < String, NS_Cost_Centre__c > nsCostCenterMap, String orderType, Map < String, SBQQ__Subscription__c > obs_sub_map, Map < String, NS_Account__c > NsAccountMap) {
        List < Sales_Order__c > soList = new List < Sales_Order__c > ();
        system.debug('mark here =>' + soType_proj_map);
        boolean isILFCreated = false;
        
        for (String s: soType_counter_Map.keySet()) {
            if(soType_counter_Map.get(s) > 0){
                if (s.contains('ILF') && !isILFCreated) {
                    soList.add(ILFPackage_ListInit.addILFSalesOrder(bg, soType_proj_map.get(s), nsCurrencyMap, s, NsAccountMap));
                    isILFCreated = true;
                } else if (s.contains('PS')) {
                    //if(psSalesOrderCounter < psObsList.size()){
                    NS_Project__c proj = new NS_Project__c();
                    if(soType_proj_map.get(s) != null){
                        proj = soType_proj_map.get(s);
                    } else {
                        proj = soType_proj_map.get('Pipeline');
                    }
                    if(proj != null) soList.add(PSPackage_ListInit.addPSSalesOrder(bg, proj, nsCurrencyMap, s, NsAccountMap));
                    //psSalesOrderCounter++;
                    //}
                }
            }
        }
        
        if (soList.size() > 0) {
            insert soList;
        }
        
        return soList;
    }
    
    public static void updateCustomerBillingSchedule(Sales_Order__c[] soList) {
        Map < Id, Id > proj_so_map = new Map < Id, Id > ();
        for (Sales_Order__c so: [SELECT Id, BIlling_GROUP__C, NS_Project__c FROM Sales_Order__c WHERE Id IN: soList]) {
            proj_so_map.put(so.NS_Project__c, so.Id);
        }
        
        List < NS_Customer_Billing_Schedule__c > cbsList = new List < NS_Customer_Billing_Schedule__c > ();
        
        for (NS_Customer_Billing_Schedule__c bs: [select Id, Sales_Order__c, Project__C from NS_Customer_Billing_Schedule__c where Project__c in: proj_so_map.keySet()]) {
            bs.Sales_Order__c = proj_so_map.get(bs.Project__c);
            cbsList.add(bs);
        }
        
        if (cbsList.size() > 0) {
            try {
                update cbsList;
                //tempResponse += '=>Customer Billing Schdule - updated with ILF SalesOrder \n';
            }
            Catch(Exception Ex) {
                //tempResponse += '=>Customer Billing Schdule - Failed to link with ILF SalesOrder - ' + Ex.getMessage() + '\n';
            }
        }
    } 
   
    public static void createSalesOrderItems(Sales_Order__c[] soList, Map < String, List < SBQQ__Subscription__c >> soType_subs_map, Map < String, NS_Currency__c > nsCurrencyMap, map < String, NS_Revenue_Recognition_Template__c > revScheduleMap, map < String, NS_OpenAir_Revenue_Rules__c > internalIdOARevenueRuleMap, map < String, NS_List_Table__c > internalIdOABillingRuleMap, Map<string, string> proj_obs_map, map < String, product2> prod2UPID) {
        system.debug('Entered into Create SO Items => ' + soType_subs_map);
        List < Sales_Order_Item__c > itemsList = new List < Sales_Order_Item__c > ();
        Integer i = 0;
        string tempType;
        Set < NS_Vendor_Billing_Schedule__c > vbsList = new Set < NS_Vendor_Billing_Schedule__c > ();
        
        // SO Items Creation for Only ILF
        Sales_Order__c ILF_SO = new Sales_Order__c();
        string temp_Type;
        for (Sales_Order__c so: soList) {
            system.debug('so sub gropu type => ' + so.Sub_Group_Type__c);
            if (so.Sub_Group_Type__c.contains('ILF')) {
                ILF_SO = so;
            }
        }
        
        List < SBQQ__Subscription__c > sub_allList = new List < SBQQ__Subscription__c > ();
        for (String s: soType_subs_map.keySet()) {
            if (s.contains('ILF')) {
                sub_allList.addAll(soType_subs_map.get(s));
            }
        }
        
        Sales_Order_Item__c soiItem = new Sales_Order_Item__c();
        i = 1;
        for (SBQQ__Subscription__c sub: sub_allList) {
            if (sub.Initial_Sales_Order_Type__c.contains('ILF')) {
                system.debug('calling ILF so Item --');
                soiItem = ILFPackage_ListInit.addILFSalesOrderItem(sub, i, ILF_SO, revScheduleMap, nsCurrencyMap);
                itemsList.add(soiItem);
                i++;
                if (sub.Inital_NS_Item__r.Payaway__c) {
                    system.debug('Adding VBS =>' + soiItem);
                    vbsList.add(ILFPackage_ListInit.addVendorBillingScheule(ILF_SO, soiItem, sub));
                }
            }
        }
        
        // SO Items creation for only PS
        for (Sales_Order__c so: soList) {
            if(so.Order_Type__c.contains('PS')){
                i = 1;
                for(SBQQ__Subscription__c sub: soType_subs_map.get(proj_obs_map.get(so.NS_Project__c))){
                    system.debug(' am '+sub.Name);
                    system.debug(proj_obs_map.get(so.NS_Project__c)+' am giving my sub to PS SO items => '+sub.Opportunity_Billing_Schedule__c);
                    itemsList.addAll(PSPackage_ListInit.addPSSalesOrderItem(sub, i, so, revScheduleMap, internalIdOARevenueRuleMap, internalIdOABillingRuleMap, prod2UPID));
                    i++;
                }
            }
        }
        
        if (itemsList.size() > 0) {
            try{
                insert itemsList;
            } Catch (Exception Ex){
                system.debug('error inserting items list => '+itemsList);
            }
        }
        
        if (vbsList.size() > 0) {
            try {
                List < NS_Vendor_Billing_Schedule__c > vbsList_list = new List < NS_Vendor_Billing_Schedule__c > ();
                vbsList_list.addAll(vbsLIst);
                insert vbsList_list;
                system.debug('insert vbs =>' + vbsList);
                //tempResponse += '=> Success! Vendor Billing schedule Created \n';
                ILFPackage_ListInit.createVBSItem(vbsList_list, ILF_SO.NS_Project__C);
                
                // update so
                Map < Id, Id > sub_vbsId_Map = new Map < Id, Id > ();
                Map < Id, Id > sub_proj_Map = new Map < Id, Id > ();
                for (NS_Vendor_Billing_Schedule__c vbs: vbsList_list) {
                    sub_vbsId_Map.put(vbs.Subscription_Id__c, vbs.Id);
                    sub_proj_Map.put(vbs.Subscription_Id__c, vbs.NS_Project__c);
                }
                
                system.debug('sub vbs mapping =>' + sub_vbsId_Map);
                List < Sales_Order_Item__c > soi_list = new List < Sales_Order_Item__c > ();
                for (Sales_Order_Item__c soi: [SELECT Id, Name, Subscription__c, NS_Vendor_Billing_Schedule__c, Sales_Order__r.NS_Project__c FROM Sales_Order_Item__c WHERE Subscription__c IN: sub_vbsId_Map.keySet()]) {
                    if (sub_proj_Map.get(soi.Subscription__c) == soi.Sales_Order__r.NS_Project__c) {
                        soi.NS_Vendor_Billing_Schedule__c = sub_vbsId_Map.get(soi.Subscription__c);
                        soi_list.add(soi);
                        system.debug('added soi list of ' + soi.Id + ' =>' + sub_vbsId_Map.get(soi.Subscription__c));
                    }
                }
                
                update soi_list;
            }
            Catch(Exception Ex) {
                system.debug('vbs error here => ' + ex.getMessage());
                system.debug('vbs error here => ' + ex.getlineNumber());
                //tempResponse += '=> Error! Vendor Billing schedule insertion failed' + Ex.getMessage() + '\n';
            }
        }
        
        
    }
    
    public static void updateHolidayPeriod(Map < String, List < SBQQ__Subscription__c >> soType_subs_map, Contract con) {
        system.debug('got map in holiday => ' + soType_subs_map);
        SBQQ__Subscription__c earliestSub = new SBQQ__Subscription__c();
        List < SBQQ__Subscription__c > subList = new List < SBQQ__Subscription__c > ();
        Date earliestNextBillingDate = Date.newInstance(2999, 12, 31), earliestNextSoDate = Date.newInstance(2999, 12, 31);
        for (String s: soType_subs_map.keySet()) {
            if (s.contains('RLF')) {
                system.debug('holiday rlf subs =>' + soType_subs_map.get(s));
                for (SBQQ__Subscription__c sub: soType_subs_map.get(s)) {
                    
                    if (con.Reccuring_Payment_Holiday__c != null || (con.Recurring_Fees_Start_Planned__c != null && con.Recurring_Fees_Start_Planned__c > system.today()) ) {
                        if (con.Recurring_Fees_Start_Planned__c != null)
                            sub.Next_Billing_Date__c = con.Recurring_Fees_Start_Planned__c;
                        if (sub.SO_Generation_Advance__c != null && sub.SBQQ__BillingType__c != null) {
                            if (sub.SBQQ__BillingType__c == 'Arrears')
                                sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays((Integer) sub.SO_Generation_Advance__c);
                            if (sub.SBQQ__BillingType__c == 'Advance') {
                                sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c);
                                if (sub.Next_SO_generation_Date__c <= System.today())
                                    sub.Next_SO_generation_Date__c = System.today().addDays(1);
                            }                            
                        }
                        if (sub.SBQQ__BillingType__c == null || sub.SO_Generation_Advance__c == null) {
                            sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c;
                        }
                        subList.add(sub);
                        if (sub.Next_billing_Date__c < earliestNextBillingDate) {
                            earliestNextBillingDate = sub.Next_Billing_Date__c;
                        }
                        if (sub.Next_SO_generation_Date__c < earliestNextSoDate) {
                            earliestNextSoDate = sub.Next_SO_generation_Date__c;
                        }
                    }
                    
                }
            }
        }
        
        if (subList.size() > 0) {
            update subList;
            if(earliestNextBillingDate.year() == 2999) earliestNextBillingDate = null;
            if(earliestNextSoDate.year() == 2999) earliestNextSoDate = null;            
            updateBG_billingDate(earliestNextBillingDate, earliestNextSoDate, subList[0].Billing_group__c);
        }
        
    }
    
    public static void updateNextBillingDate(Id bgId) {
        List < SBQQ__Subscription__c > subList = new List < SBQQ__Subscription__c > ();
        List < Date > closeDates = new List < Date > ();
        List < Date > closeDates2 = new List < Date > ();
        Id billingGroup;
        system.debug('in update');
        for (SBQQ__Subscription__c sub: [SELECT Id, SBQQ__BillingFrequency__c,Last_Prorata_Calculated__c , Prorata_Days__c,SBQQ__StartDate__c,RF_Start_Planned__c , SBQQ__BillingType__c, Pro_Rata_Calculated__c, SO_Generation_Advance__c, Next_SO_generation_Date__c, Billing_Day__c, Billing_Month__c, Next_Billing_Date__c, Billing_Group__c, order_type__c, Last_Prorata_required__c
                                         FROM SBQQ__Subscription__c
                                         WHERE Billing_Group__c =: bgId
                                         AND Recurring_Sales_Order_Type__c LIKE 'RLF%'
                                        ]) {
                                            
                                            if ((sub.Billing_Day__c == null && sub.Billing_Month__c == null) || (sub.Pro_Rata_Calculated__c && sub.Next_Billing_Date__c != null) || ((sub.RF_Start_Planned__c <= system.today()) && sub.Prorata_Days__c == 0)) {
                                                if (sub.SBQQ__BillingFrequency__c == 'Monthly') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
                                                        Date tdate = System.today().addMonths(1);
                                                        if (sub.Billing_Day__c > 1) {
                                                            sub.Next_Billing_Date__c = tdate.toStartOfMonth().addDays((Integer) sub.Billing_Day__c - 1);
                                                        } else {
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addMonths(1);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(1);
                                                    }
                                                    subList.add(sub);
                                                } else if (sub.SBQQ__BillingFrequency__c == 'Quarterly') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
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
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addMonths(3);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(3);
                                                    }
                                                    subList.add(sub);
                                                } else if (sub.SBQQ__BillingFrequency__c == 'Semiannual') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
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
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addMonths(6);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addMonths(6);
                                                    }
                                                    
                                                    
                                                    subList.add(sub);
                                                } else if (sub.SBQQ__BillingFrequency__c == 'Annual') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
                                                        if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                                            sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 1, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                                        } else {
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addYears(1);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(1);
                                                    }
                                                    
                                                    subList.add(sub);
                                                } else if (sub.SBQQ__BillingFrequency__c == 'Biennial') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
                                                        if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                                            sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 2, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                                        } else {
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addYears(2);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(2);
                                                    }
                                                    subList.add(sub);
                                                } else if (sub.SBQQ__BillingFrequency__c == 'Triennial') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
                                                        if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                                            sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 3, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                                        } else {
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addYears(3);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(3);
                                                    }
                                                    subList.add(sub);
                                                } else if (sub.SBQQ__BillingFrequency__c == 'Quinquennial') {
                                                    if (!sub.Pro_Rata_Calculated__c) {
                                                        if (sub.Billing_Day__c > 1 && sub.Billing_Month__c != null) {
                                                            sub.Next_Billing_Date__c = date.newInstance(System.today().Year() + 5, SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c), (Integer) sub.Billing_Day__c);
                                                        } else {
                                                            sub.Next_Billing_Date__c = sub.SBQQ__StartDate__c.addYears(5);
                                                        }
                                                    } else {
                                                        sub.Next_Billing_Date__c = sub.Next_Billing_Date__c.addYears(5);
                                                    }
                                                    subList.add(sub);
                                                }
                                                if (sub.Next_Billing_Date__c != null) closeDates.add(sub.Next_Billing_Date__c);
                                                
                                                
                                                if (sub.SO_Generation_Advance__c != null && sub.SBQQ__BillingType__c != null) {
                                                    if (sub.SBQQ__BillingType__c == 'Arrears')
                                                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays((Integer) sub.SO_Generation_Advance__c);
                                                    else if (sub.SBQQ__BillingType__c == 'Advance')
                                                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c);
                                                    system.debug('adding next so gen date' + sub.Next_SO_generation_Date__c);
                                                    //subList.add(sub);
                                                } else if (sub.SO_Generation_Advance__c == null || sub.SBQQ__BillingType__c != null) {
                                                    sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c;
                                                }
                                                if (sub.Next_SO_generation_Date__c != null) closeDates2.add(sub.Next_SO_generation_Date__c);
                                                
                                            }
                                        }
        
        if (subList.size() > 0) {
            update subList;
            closeDates.sort();
            closeDates2.sort();
            system.debug('ready to update bg next billing date =>' + closeDates[0]);
            Billing_Group__c bg = [SELECT Id, Next_Billing_Date__c, Next_SO_generation_Date__c FROM Billing_Group__c WHERE Id =: subList[0].Billing_Group__c];
            if (closeDates[0] != null)
                bg.Next_Billing_Date__c = closeDates[0];
            if (closeDates2.size() > 0 && closeDates2[0] != null)
                bg.Next_SO_generation_Date__c = closeDates2[0];
            try {
                update bg;
            }
            Catch(Exception Ex) {
                system.debug('failed to update BG billing date => ' + Ex.getMessage());
            }
        }
    }
    
    public static void calculateProrata(Map < String, List < SBQQ__Subscription__c >> soType_subs_map, Contract con) {
        List < SBQQ__Subscription__c > subList = new List < SBQQ__Subscription__c > ();
        Date startDate = system.today();
        Integer fYear;
        Date earliestNextBillingDate = Date.newInstance(2999, 12, 31), earliestNextSoDate = Date.newInstance(2999, 12, 31);
        for (String s: soType_subs_map.keySet()) {
            if (s.contains('RLF')) {
               system.debug('prorata rlf subs =>'+soType_subs_map.get(s));
                for (SBQQ__Subscription__c sub: soType_subs_map.get(s)) {
                    
                    //if( con.Recurring_Fees_Start_Planned__c <= System.today()){
                        if ((!sub.Pro_Rata_Calculated__c && !sub.Last_Prorata_required__c) && (sub.Billing_Day__c != null)) {
                           // if (con.Recurring_Fees_Start_Planned__c <= system.today()) {
                                if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                                    startDate = sub.Next_Billing_Date__c; 
                                } else {
                                    if (sub.Next_Billing_Date__c.month() >= SO_SalesOrderMapUtils.getMonth(sub.Billing_Month__c)) {
                                        fYear = sub.Next_Billing_Date__c.year() + 1;
                                        system.debug('added +1 sub date => ' + sub.Next_Billing_Date__c);
                                        //system.debug('added +1 year for Recurring_Fees_Start_Planned__c != null => ' + fYear);
                                    } else {
                                        fYear = sub.Next_Billing_Date__c.year();
                                        system.debug('added +0 year Recurring_Fees_Start_Planned__c != null');
                                    }
                                    startDate = sub.Next_Billing_Date__c;
                                }
                           // }
                            Date endDate;
                            if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                                endDate = startdate;
                                if(endDate.day() >= Integer.valueOf(sub.Billing_Day__c)) endDate = startDate.addMonths(1);
                                endDate =  Date.newInstance(endDate.year(),endDate.month(), Integer.valueOf(sub.Billing_Day__c));
                            } else {
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
                    //} 
                    else if (sub.Last_Prorata_required__c && sub.Last_Prorata_Calculated__c == false ) { // need to put extra condition
                        sub.Prorata_Days__c = Math.abs(sub.Expiry_Date__c.daysBetween(sub.Next_Billing_Date__c - 1));
                    }
                    subList.add(sub);
                    if (sub.Next_billing_Date__c < earliestNextBillingDate) {
                        earliestNextBillingDate = sub.Next_Billing_Date__c;
                    }
                    if (sub.Next_SO_generation_Date__c < earliestNextSoDate) {
                        earliestNextSoDate = sub.Next_SO_generation_Date__c;
                        
                    }
                    //}                    
                }
            }
        }
        
        if (subList.size() > 0) {
            update subList;
            if(earliestNextBillingDate.year() == 2999) earliestNextBillingDate = null;
            if(earliestNextSoDate.year() == 2999) earliestNextSoDate = null;  
            updateBG_billingDate(earliestNextBillingDate, earliestNextSoDate, subList[0].Billing_group__c);
        }
        
    }
    
    public static void updateBG_billingDate(Date nbd, Date nsd, Id bgId) {
        Billing_Group__c bg = [SELECT Id, Next_Billing_Date__c, Next_SO_generation_Date__c FROM Billing_Group__c WHERE Id =: bgId];
        bg.Next_Billing_Date__c = nbd;
        bg.Next_SO_generation_Date__c = nsd;
        bg.Last_Invoice_Date__c = system.today();
        if (bg.Next_SO_generation_Date__c < system.today()) {
            bg.Next_SO_generation_Date__c = System.today().addDays(1);
        }
        update bg;
    }
    
    public static Map < Id, String > updateProrataCalculatedCheckBox(List < Sales_Order_Item__c > itemsList) {
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
        }
        Map < Id, String > bgErrorsMap = new Map < Id, String > ();
        if (sub_prorataList.size() > 0) {
            Database.SaveResult[] srList = Database.update(sub_prorataList, false);
            
            // looping over solist                
            for (Database.SaveResult sr: srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated Subscription: ' + sr.getId());
                    //bgErrorsMap.put(sr.getId(), 'RLF Completed Successfully');
                } else {
                    for (Database.Error err: sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + sr.getId());
                        bgErrorsMap.put(sr.getId(), err.getMessage());
                    }
                }
            }
            //update ;
        }
        return bgErrorsMap;
    }
    
    
}