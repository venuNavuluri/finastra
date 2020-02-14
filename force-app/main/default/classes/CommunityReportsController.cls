public with sharing class CommunityReportsController{
    //Modified by AHA 25/07/2016 - Added additional filter to Case.owner and Case.recordType SOQL to bring query within G limits
    public List<Report> reports {get;set;}
    
    public CommunityReportsController() {
        // The OwnerId is the report folder
        reports = [SELECT Id,LastViewedDate,LastRunDate,Description,OwnerId,Name FROM Report
                   WHERE OwnerId= '00l20000000wa5D'];              
    }
    
    Public String systemStatus {get;set;}
    Public String systemOwner {get;set;}
    Public String systemRecType {get;set;}
    Public String systemSite {get;set;}
    
    public void changedPickList() {
        //meow
    }
    
    
    //When called, this method returns a selectOption list of System Statuses in the form of a string. This is then used to populate the System Status Picklist on the VF Dashboard Filter.
    
    public List<SelectOption> getStatus(){
        
        List<SelectOption> options = new List<SelectOption>();
            
        Schema.DescribeFieldResult fieldResult = Case.System_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('null', '---Please Select---'));
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getValue() != 'Beta Site' && f.getValue() != 'Early Adopter' && f.getValue() != 'New Implementation' && f.getValue() != 'Partners' && f.getValue() != 'Post Production' && f.getValue() != 'Regression Environment' && f.getValue() != 'Upgrade'){
               options.add(new SelectOption(f.getLabel(), f.getValue())); 
            } 
           
        }       
        return options;
    }   
    
    //When called, this method returns a selectOption list of Original Case owners in the form of Name and Id pairs. This is then used to populate the Case Owner Picklist on the VF Dashboard Filter.
    
    public List<SelectOption> getCOwner(){
        
        
        List<SelectOption> options2 = new List<SelectOption>();
        Set<SelectOption> Cleaner = new Set<SelectOption>();
        Map<String, Id> cleanermap = new Map<String,Id>();
        
        
        
        List<Case> CaseList = new List<Case>();
         List<Case> CaseListtest = new List<Case>();
        Set<String> namehold = new set<string>();
        List<String> nameholtout = new List<string>();
        Datetime d = datetime.now().adddays(-546);
        system.debug(' Date ' + d);
        
        Set<String> excludedRTId = New Set<String>();
        List<RecordType> excludedRecordTypes = New List<RecordType>();
        excludedRecordTypes = [select id from recordtype WHERE sobjecttype = 'case' and isActive = true AND (name = 'Sales Operations Support Services' OR Name='Surveys' OR name='Customer Feedback' OR Name='ACE360' or name='COM Escalation' or name ='Operations Service Request' or name = 'Project Cases')];
        for(RecordType excludedIds : excludedRecordTypes ) {
          excludedRTId.add(excludedIds.Id);
        }
        system.debug(' Excluded record Types ' + excludedRTId);
        
        CaseList = [SELECT Contact.Name, ContactId FROM Case WHERE System_Status__c <> Null AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId];
        //CaseListtest = [SELECT Id, Subject FROM Case WHERE System_Status__c <> Null AND CreatedDate > :d AND IsVisibleInSelfService = true];
        // AND CreatedDate > :Date.Today().addDays(-546)
        // // 
        
        system.debug(' Case List TEST ' + CaseListtest);
        system.debug(' Case owner list ' + CaseList);
        system.debug(' Case owner list SIZE ' + CaseList.size());
        
        Schema.DescribeFieldResult dfr = Case.OwnerId.getDescribe();
        system.debug('CASELIST ' + CaseList);
        for(Case css : CaseList){
            if(css.Contact.Name != null && dfr.isAccessible()){
                namehold.add(css.Contact.Name);
                cleanermap.put(css.Contact.Name, css.ContactId);
            }
            /*if(css.Case_Owner_User_lookup__c != null){
                namehold.add(css.Case_Owner_User_lookup__r.name);
                cleanermap.put(css.Case_Owner_User_lookup__r.name, css.Case_Owner_User_lookup__c);
            }*/
            
            
        }
        
        nameholtout.addAll(namehold);
        nameholtout.sort();
        system.debug('Number of Names ' + nameholtout.size());
        system.debug('Names ' + nameholtout);
        if(nameholtout.size() > 0){
            for(String nm : nameholtout){
                if(nm <> null){
                    options2.add(new SelectOption(nm,nm));
          
                }
            }
            options2.add(0,new SelectOption('null', '---Please Select---'));
        }
        else {
            options2.add(new SelectOption('null', '---Please Select---'));
        }
        
        return options2;
        
    }
       
    //When called, this method returns a selectOption list of Case Record Types in the form of Name and Id pairs. This is then used to populate the Case Owner Picklist on the VF Dashboard Filter.
    
     public List<SelectOption> getCRecType(){
       List<SelectOption> options = new withoutshare().returnRecType();
        return options; 
         
            
     }
    
  //When called, this method returns a selectOption list of Account Sites in the form of a String. This is then used to populate the Account Site Picklist on the VF Dashboard Filter.
    
    public List<SelectOption> getSite(){
        
          
            List<SelectOption> options4 = new List<SelectOption>();
            List<Account> CaseList = new List<Account>();
            Set<String> namehold = new set<string>();
            List<String> nameholtout = new List<string>();
            
            
            CaseList = [SELECT Site FROM Account WHERE Site <> null];
            
            options4.add(new SelectOption('null', '---Please Select---'));
            for(Account css : CaseList){
                if(css.Site != null){
                    namehold.add(css.Site);
                }
            }
            nameholtout.addAll(namehold);
            nameholtout.sort();
          if(nameholtout.size() > 0){
                for(String nm : nameholtout){
                    options4.add(new SelectOption(nm,nm));
                }
            }
            return options4;
        
    }
    
    //These Methods pull through the selected value from the picklists in the VF page.
    
    public void SetsystemStatus(){
        systemStatus = Apexpages.currentpage().getparameters().get('picklist1Value');
    
    }
    public void SetsystemOwner(){
        systemOwner = Apexpages.currentpage().getparameters().get('picklist2Value');
    
    }
    
    public void SetsystemRecType(){
        systemRecType = Apexpages.currentpage().getparameters().get('picklist3Value');
    
    } 
    public void SetsystemSite(){
        systemSite = Apexpages.currentpage().getparameters().get('picklist4Value');
    
    }  
    
    public without sharing Class withoutshare{
        public List<SelectOption> returnRecType(){
        
            List<SelectOption> options3 = new List<SelectOption>();
            List<Case> CaseList = new List<Case>();
            Set<String> namehold = new set<string>();
            List<String> nameholtout = new List<string>();
          Map<String, Id> cleanermap2 = new Map<String,Id>();
           List<String> Prod = new List<string>();
           Prod.add('Almonde');
            Prod.add('Bankmaster / Bankfusion UB');
            Prod.add('Equation');
            Prod.add('Financial Messaging');
            Prod.add('Fontis');
            Prod.add('Global Cash Pooling');
            Prod.add('Loan IQ'); 
           Prod.add('Midas');
            Prod.add('Misys Portal Suite');
            Prod.add('Misys Sophis');
            Prod.add('Opics');
            Prod.add('Other');
            Prod.add('Private Banking Solution');
            Prod.add('Risk'); 
           Prod.add('Summit');
            Prod.add('Third Party Products');
            Prod.add('Trade Innovation'); 
            Prod.add('FusionBanking (Lending)'); 
            Prod.add('Digital Channels'); 
            Prod.add('Kondor');
            
            
            CaseList = [SELECT RecordType.Name FROM Case WHERE RecordType.Name <> null AND CreatedDate > :Date.Today().addDays(-546) AND RecordType.Name IN :Prod];
            
            options3.add(new SelectOption('null', '---Please Select---'));
            for(Case css : CaseList){
                if(css.RecordType.Name != null){
                  namehold.add(css.RecordType.Name);
                  cleanermap2.put(css.RecordType.Name, css.RecordTypeId);
                }
            }
            nameholtout.addAll(namehold);
            nameholtout.sort();
           if(nameholtout.size() > 0){
                for(String nm : nameholtout){
                    options3.add(new SelectOption(nm,nm));
                }
            }
            return options3;
        
    }
    }
}