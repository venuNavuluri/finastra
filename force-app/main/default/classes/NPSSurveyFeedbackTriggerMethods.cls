public class NPSSurveyFeedbackTriggerMethods {
    
    public static void rollupSurveyScores(list<NPSSurveyFeedback__c> npsListNew){
        set<Id> accountIds = new set<Id>();
        map<Id, list<NPSSurveyFeedback__c>> accNPSListMap = new map<Id, list<NPSSurveyFeedback__c>>();
        map<Id, set<String>> accNPSWaveNoMap = new map<Id, set<String>>();
        map<Id, list<String>> accNPSWaveNoListMap = new map<Id, list<String>>();
        map<Id, Account> accIdAcctMap = new map<Id, Account>();
        
        for(NPSSurveyFeedback__c nps : npsListNew){
            if(nps.Survey_Status__c == 'Completed' && nps.Account__c != null){
                accountIds.add(nps.Account__c);
            }
        }
        system.debug('accountIds = ' + accountIds);
        
        list<NPSSurveyFeedback__c> npsList;
        set<String> npsWaveNoSet;
        for(NPSSurveyFeedback__c nps1 : [select id, Wave_No__c, Account__c, NPS_Score__c from NPSSurveyFeedback__c where Account__c in : accountIds and Survey_Status__c = 'Completed']){
            if(accNPSListMap.containsKey(nps1.Account__c)){
                accNPSListMap.get(nps1.Account__c).add(nps1);
            } else {
                npsList = new list<NPSSurveyFeedback__c>();
                npsList.add(nps1);
                accNPSListMap.put(nps1.Account__c, npsList);
            }
            if(accNPSWaveNoMap.containsKey(nps1.Account__c)){
                accNPSWaveNoMap.get(nps1.Account__c).add(nps1.Wave_No__c);
            } else {
                npsWaveNoSet = new set<String>();
                npsWaveNoSet.add(nps1.Wave_No__c);
                accNPSWaveNoMap.put(nps1.Account__c, npsWaveNoSet);
            }
        }
        system.debug('accNPSListMap = ' + accNPSListMap);
        system.debug('accNPSWaveNoMap = ' + accNPSWaveNoMap);

        list<String> npsWaveNoList;
        if(accNPSWaveNoMap != null && accNPSWaveNoMap.size() > 0){
            for(Id acctId : accNPSWaveNoMap.keySet()){
                npsWaveNoList = new list<String>(accNPSWaveNoMap.get(acctId));
                npsWaveNoList.sort();
                accNPSWaveNoListMap.put(acctId, npsWaveNoList);
            }
        }
        system.debug('accNPSWaveNoListMap = ' + accNPSWaveNoListMap);
        
        if(accNPSWaveNoListMap != null && accNPSWaveNoListMap.size() > 0){
            for(Id accountId : accNPSWaveNoListMap.keySet()){
            	Account acc;
                //q1[q1.size() - 1]
                list<String> waveList = accNPSWaveNoListMap.get(accountId);
                if(waveList.size() > 0){
                    String lastWave = waveList[waveList.size() -1];
                    String lastWaveInWords = convertWaveToWords(lastWave);
                    //do the processing here for this wave
                    Decimal totalNPSScore = 0;
                    Integer i = 0;
                    for(NPSSurveyFeedback__c npsSF : accNPSListMap.get(accountId)){
                    	if(npsSF.NPS_Score__c == null){
                    		npsSF.NPS_Score__c = 0;
                    	}
                        if(npsSF.Wave_No__c == lastWave){
                            totalNPSScore = totalNPSScore + npsSF.NPS_Score__c;
                            i++;
                        }
                    }
                    if(i != 0){
	                    acc = new Account(Id = accountId, Survey_Score_1__c = totalNPSScore / i, Survey_Wave_1__c = lastWaveInWords);
	                    accIdAcctMap.put(accountId, acc);
                    }
                }

                if(waveList.size() > 1){
                    String secondLastWave = waveList[waveList.size() -2];
                    String secondLastWaveInWords = convertWaveToWords(secondLastWave);
                    //do the processing here for this wave
                    Decimal totalNPSScore = 0;
                    Integer i = 0;
                    for(NPSSurveyFeedback__c npsSF : accNPSListMap.get(accountId)){
                    	if(npsSF.NPS_Score__c == null){
                    		npsSF.NPS_Score__c = 0;
                    	}
                        if(npsSF.Wave_No__c == secondLastWave){
                            totalNPSScore = totalNPSScore + npsSF.NPS_Score__c;
                            i++;
                        }
                    }
                    if(i != 0){
	                    if(accIdAcctMap.containsKey(accountId)){
	                        acc = accIdAcctMap.get(accountId);
	                        acc.Survey_Score_2__c = totalNPSScore / i;
	                        acc.Survey_Wave_2__c = secondLastWaveInWords;
	                    } else {
	                        acc = new Account(Id = accountId, Survey_Score_2__c = totalNPSScore / i, Survey_Wave_2__c = secondLastWaveInWords);
	                        accIdAcctMap.put(accountId, acc);
	                    }
                    }
                    
                }

                if(waveList.size() > 2){
                    String thirdLastWave = waveList[waveList.size() -3];
                    String thirdLastWaveInWords = convertWaveToWords(thirdLastWave);
                    //do the processing here for this wave
                    Decimal totalNPSScore = 0;
                    Integer i = 0;
                    for(NPSSurveyFeedback__c npsSF : accNPSListMap.get(accountId)){
                    	if(npsSF.NPS_Score__c == null){
                    		npsSF.NPS_Score__c = 0;
                    	}
                        if(npsSF.Wave_No__c == thirdLastWave){
                            totalNPSScore = totalNPSScore + npsSF.NPS_Score__c;
                            i++;
                        }
                    }
                    if(i != 0){
	                    if(accIdAcctMap.containsKey(accountId)){
	                        acc = accIdAcctMap.get(accountId);
	                        acc.Survey_Score_3__c = totalNPSScore / i;
	                        acc.Survey_Wave_3__c = thirdLastWaveInWords;
	                    } else {
	                        acc = new Account(Id = accountId, Survey_Score_3__c = totalNPSScore / i, Survey_Wave_3__c = thirdLastWaveInWords);
	                        accIdAcctMap.put(accountId, acc);
	                    }
                    }
                }
            }
        }
        
        system.debug('accIdAcctMap = ' + accIdAcctMap);
        if(accIdAcctMap != null && accIdAcctMap.size() > 0){
            update accIdAcctMap.values();
        }
    }
    
    private static String convertWaveToWords(String wave){
    	String retString = '';
    	if(wave.length() == 6){
    		retString = 'NPS ' + convertToMonth(wave.subString(4)) + ' ' + wave.subString(0, 4);
    	}
    	return retString;
    }
    
    private static String convertToMonth(String month){
    	String retString = '';
    	if(month == '01'){
    		retString = 'Jan';
    	} else if(month == '02'){
    		retString = 'Feb';
    	} else if(month == '03'){
    		retString = 'Mar';
    	} else if(month == '04'){
    		retString = 'Apr';
    	} else if(month == '05'){
    		retString = 'May';
    	} else if(month == '06'){
    		retString = 'Jun';
    	} else if(month == '07'){
    		retString = 'Jul';
    	} else if(month == '08'){
    		retString = 'Aug';
    	} else if(month == '09'){
    		retString = 'Sep';
    	} else if(month == '10'){
    		retString = 'Oct';
    	} else if(month == '11'){
    		retString = 'Nov';
    	} else if(month == '12'){
    		retString = 'Dec';
    	}
    	return retString;
    }
    
}