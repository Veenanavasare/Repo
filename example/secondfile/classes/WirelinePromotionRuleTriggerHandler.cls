/********************************************************************************************************************    
Component Name : WirelinePromotionRuleTriggerHandler 
Component Description:  Trigger handler class for the Wireline Promotion Rules Object 
Author Name : Accenture IDC    
Created Date: 25th April 2018 
*********************************************************************************************************************/
public with sharing class WirelinePromotionRuleTriggerHandler extends SITriggerOperations.SITriggerImpl{
    public boolean isExecuted;
    
    /***Constructor to execute Trigger***/    
    public WirelinePromotionRuleTriggerHandler(){
        isExecuted = true;
    }
    
    public override boolean onAfterInsert(SObject[] newObjects){
        system.debug('---inside onAfterInsert---');
        List<Wireline_Promotion_Rules__c> insertedWireliObjList = new List<Wireline_Promotion_Rules__c>();
        
        if(newObjects!=null){
            insertedWireliObjList = newObjects;
        }
        updateRankofWirelinePromotion(insertedWireliObjList);
        
        return isExecuted;
    }
    
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject> oldObjectsMap){
        List<Wireline_Promotion_Rules__c> updatedWireliObjList = new List<Wireline_Promotion_Rules__c>();
        if(updatedObjects!=null){
            updatedWireliObjList = updatedObjects;
        }
        for(Wireline_Promotion_Rules__c  updateObj : updatedWireliObjList){
            Wireline_Promotion_Rules__c oldWp = (Wireline_Promotion_Rules__c)oldObjectsMap.get(updateObj.id);
            if((updateObj.Do_Not_Run__c == true && updateObj.Do_Not_Run__c != oldWp.Do_Not_Run__c) || (updateObj.Expired__c == true && updateObj.Expired__c != oldWp.Expired__c)){
                updateObj.Rank__c = 0;
                system.debug('@@@Rank updated to 0 for Promotion: '+updateObj);
            }
        }        
        return isExecuted;
    }
    
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  oldObjectsMap) {
        try{
            system.debug('----line no24 ---');
            List<Wireline_Promotion_Rules__c> updatedWirelineObjList = new List<Wireline_Promotion_Rules__c>();
            List<Wireline_Promotion_Rules__c> updatedWirelineObjRankList = new List<Wireline_Promotion_Rules__c>();
            
            if(updatedObjects!=null){
                updatedWirelineObjList = updatedObjects;
            }
            List<Wireline_Promotion_Rules__c> newInactiveWP = new List<Wireline_Promotion_Rules__c>();
            Set<String> promoTypeSet = new Set<String>();
            
            for(Wireline_Promotion_Rules__c  updateObj : updatedWirelineObjList){
                Wireline_Promotion_Rules__c oldWp = (Wireline_Promotion_Rules__c)oldObjectsMap.get(updateObj.id);
                if((updateObj.Do_Not_Run__c == true && updateObj.Do_Not_Run__c != oldWp.Do_Not_Run__c) || (updateObj.Expired__c == true && updateObj.Expired__c != oldWp.Expired__c)){
                    promoTypeSet.add(updateObj.Promo_Type__c);
                    newInactiveWP.add(updateObj);
                }else if(updateObj.Rank__c != oldWp.Rank__c){
                    updatedWirelineObjRankList.add(updateObj);
                }
            }
            system.debug('---promoTypeSet---'+promoTypeSet+'----newInactiveWP---'+newInactiveWP);
            if(newInactiveWP != Null && !newInactiveWP.IsEmpty()){
                List<Wireline_Promotion_Rules__c> allWirelinepromotionlist = [SELECT id,Rank__c,Promo_Type__c,Expired__c ,Do_Not_Run__c FROM Wireline_Promotion_Rules__c WHERE ID NOT IN : newInactiveWP AND Do_Not_Run__c = false AND Expired__c = False AND Promo_Type__c IN : promoTypeSet ORDER BY Rank__c ASC ];
                system.debug('---allWirelinepromotionlist---'+allWirelinepromotionlist );
                for(string promType :promoTypeSet){
                    integer count = 1;
                    for(Wireline_Promotion_Rules__c wp : allWirelinepromotionlist){
                        if(promType == wp.Promo_Type__c){
                            wp.Rank__c = count;
                            count++;
                        }
                    }
                }
                update allWirelinepromotionlist;
                system.debug('updated wirelinepromotionlist'+allWirelinepromotionlist);
            }
            if(!updatedWirelineObjRankList.isEMpty()){
                updateRankofWirelinePromotion(updatedWirelineObjRankList);
            }
        }catch(Exception e){
            system.debug('----line no ---'+e.getLinenumber());
        }
        return null;
    }

    public void updateRankofWirelinePromotion(List<Wireline_Promotion_Rules__c> wpList){
        system.debug('---inside updateRankofWirelinePromotion---');
        List<Wireline_Promotion_Rules__c> lsitTobeUpdate = new List<Wireline_Promotion_Rules__c> ();
        Set<String> promoTypeSet = new Set<String>();
        List<Wireline_Promotion_Rules__c> insertedWPList = new List<Wireline_Promotion_Rules__c>();
        Map<string, List<Wireline_Promotion_Rules__c>> promTypeWithWPListMap = new Map<string, List<Wireline_Promotion_Rules__c>>();
        Map<string, List<Wireline_Promotion_Rules__c>> tempModifiedRankWPListMap = new Map<string, List<Wireline_Promotion_Rules__c>>();
        
        for(Wireline_Promotion_Rules__c  insertedObj : wpList){
            if(String.isNotBlank(insertedObj.Promo_Type__c)){
                promoTypeSet.add(insertedObj.Promo_Type__c);
                insertedWPList.add(insertedObj);
            }
        }
        
        List<Wireline_Promotion_Rules__c> allWirelinepromotionlist = [SELECT id,Rank__c,Promo_Type__c,Expired__c ,Do_Not_Run__c FROM Wireline_Promotion_Rules__c WHERE ID NOT IN : insertedWPList AND Promo_Type__c IN : promoTypeSet ORDER BY Rank__c ASC ];
        
        for(Wireline_Promotion_Rules__c wpObj : allWirelinepromotionlist){
            if(!promTypeWithWPListMap.containsKey(wpObj.Promo_Type__c)){
                List<Wireline_Promotion_Rules__c> wpLst = new List<Wireline_Promotion_Rules__c>();
                wpLst.add(wpObj);
                promTypeWithWPListMap.put(wpObj.Promo_Type__c,wpLst);
            }else{
                List<Wireline_Promotion_Rules__c> wpLst = promTypeWithWPListMap.get(wpObj.Promo_Type__c);
                wpLst.add(wpObj);
                promTypeWithWPListMap.put(wpObj.Promo_Type__c,wpLst);
            }
        }
        system.debug('---promTypeWithWPListMap---'+promTypeWithWPListMap);
        for(Wireline_Promotion_Rules__c  insertedObj : wpList){
            if(promTypeWithWPListMap.containsKey(insertedObj.Promo_Type__c)){
                Decimal counter = insertedObj.Rank__c;
                system.debug('---tempModifiedRankWPListMap.containsKey(insertedObj.Promo_Type__c)---'+tempModifiedRankWPListMap.containsKey(insertedObj.Promo_Type__c));
                if(!tempModifiedRankWPListMap.containsKey(insertedObj.Promo_Type__c)){
                    for(Wireline_Promotion_Rules__c rule: promTypeWithWPListMap.get(insertedObj.Promo_Type__c)){   
                        if(rule.Rank__c >= insertedObj.Rank__c){
                            system.debug('@@@rule.Rank__c: '+rule.Rank__c);
                            system.debug('@@@counter: '+counter);
                            if(rule.Rank__c == counter){
                                rule.Rank__c = rule.Rank__c + 1;
                                counter = counter+1;
                                system.debug('@@@inside if');
                            }else{
                                system.debug('@@@inside else');
                                break;
                            }
                            if(!tempModifiedRankWPListMap.containsKey(insertedObj.Promo_Type__c)){
                                List<Wireline_Promotion_Rules__c> wpLst = new List<Wireline_Promotion_Rules__c>();
                                wpLst.add(rule);
                                promTypeWithWPListMap.put(rule.Promo_Type__c,wpLst);
                            }else{
                                List<Wireline_Promotion_Rules__c> wpLst = promTypeWithWPListMap.get(rule.Promo_Type__c);
                                wpLst.add(rule);
                                promTypeWithWPListMap.put(rule.Promo_Type__c,wpLst);
                            }
                            lsitTobeUpdate.add(rule);
                        }
                    }
                }else{
                    for(Wireline_Promotion_Rules__c rule: promTypeWithWPListMap.get(insertedObj.Promo_Type__c)){   
                        if(rule.Rank__c >= insertedObj.Rank__c){
                            system.debug('@@@rule.Rank__c2: '+rule.Rank__c);
                            system.debug('@@@counter2: '+counter);
                            if(rule.Rank__c == counter){
                                rule.Rank__c = rule.Rank__c + 1;
                                counter = counter+1;
                                system.debug('@@@inside if2');
                            }else{
                                system.debug('@@@inside else2');
                                break;
                            }
                            
                        }
                        if(lsitTobeUpdate.contains(rule)){
                            lsitTobeUpdate.remove(lsitTobeUpdate.indexOf(rule));
                            lsitTobeUpdate.add(rule);
                        }
                    }
                }
            }
        }
        update lsitTobeUpdate;
    }
}