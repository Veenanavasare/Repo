global class ATOMDealRegApprovalBatchProcess implements Database.Batchable<sObject> {

    global String opptyId;
    global Boolean discountable;
    global Boolean isAutoDealApproval;
    global Decimal customDiscountPercentage;

    global ATOMDealRegApprovalBatchProcess ( String oppId, Boolean discountable, Boolean isAutoDealApproval, Decimal customDiscountPercentage) {
        this.opptyId = oppId;
        this.discountable = discountable ;
        this.isAutoDealApproval = isAutoDealApproval;
        this.customDiscountPercentage = customDiscountPercentage;
        System.debug('@@@@opptyId'+opptyId);
        System.debug('@@@@discountable'+discountable);
        System.debug('@@@@isAutoDealApproval '+isAutoDealApproval);
        System.debug('@@@@customDiscountPercentage'+customDiscountPercentage);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT ID ,StageName, End_Customer__c, Service_type__c, X3rd_Party_Flag__c, AccountId, BroadBand_Product__c, MIS_Product__c, Cumulative_List_Price__c, Discount_Amount__c, OTC_Discount_Amount__c, Cumulative_OTC_Price__c, Cumulative_OTC_Discount_Price__c, Discounted_Price__c, Discounted_Percentage__c, Mobility__c, ATOM_Deal__c, Batch_Deal_Reg_Approved__c,Custom_Deal_Reg_Percentage__c,Number_of_Products__c FROM Opportunity WHERE Id='+'\''+opptyId+'\'';
        System.debug('@@@@Query'+queryString);
        return Database.getQueryLocator(queryString);
    }
    
    global void execute( Database.BatchableContext BC, List<Opportunity> opptyList ){
        System.debug('@@@@inside execute: opptyId'+opptyId);
        System.debug('@@@@inside execute: discountable'+discountable);
        System.debug('@@@@inside execute: isAutoDealApproval '+isAutoDealApproval );
        System.debug('@@@@inside execute: customDiscountPercentage'+customDiscountPercentage);
        
        Opportunity Opty;
        list <Apttus_Proposal__Proposal__c> proposalList = new list <Apttus_Proposal__Proposal__c>();        
        
        Opty= [SELECT ID ,StageName, End_Customer__c,Service_type__c, X3rd_Party_Flag__c, AccountId, BroadBand_Product__c, MIS_Product__c, Cumulative_List_Price__c, Discount_Amount__c, OTC_Discount_Amount__c, Cumulative_OTC_Price__c, Cumulative_OTC_Discount_Price__c, Discounted_Price__c, Discounted_Percentage__c, Mobility__c, ATOM_Deal__c, Batch_Deal_Reg_Approved__c,Custom_Deal_Reg_Percentage__c,Number_of_Products__c FROM Opportunity WHERE ID =: opptyId];      
        proposalList=[Select Id,QuoteExpirationDate__c,Deal_Registration_Expire_Date__c,Apttus_Proposal__Opportunity__r.Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__r.Id=:opptyId];
        if(customDiscountPercentage != null){
            opty.Custom_Deal_Reg_Percentage__c = customDiscountPercentage;
        }  
        
        if (!Opty.X3rd_Party_Flag__c){
            if(isAutoDealApproval){
                Opty.StageName = SIConstants.OPTY_DEAL_Auto_Approved;
            }else{
                Opty.StageName = SIConstants.OPTY_DEAL_APPROVED;    
            }
        }
        if(discountable == true){
            if(Opty.Custom_Deal_Reg_Percentage__c  != null)
            {
                Opty.Standard_Discount_Percentage__c = null;
            }
            opty.Apply_Promotions__c=true;
            opty.Promo_Deal_Reg__c='True';
            opty.Deal_Reg_Approved__c = true; 
            update opty;
            Date newdate = Date.today().addmonths(6);
            proposalList[0].QuoteExpirationDate__c= newdate;
            update proposalList;
           
            list<Promotion_Engine_Junction__c> PEJRank4 = new list<Promotion_Engine_Junction__c>();
            PEJRank4 = [select Id,Discount_Percentage__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 4 and Opportunity__c =:opty.Id limit 1];
            if(PEJRank4.size()>0)
            {
                if(Opty.Custom_Deal_Reg_Percentage__c  != null)
                {
                    PEJRank4.get(0).Discount_Percentage__c = Opty.Custom_Deal_Reg_Percentage__c;
                }
                else
                {
                    PEJRank4.get(0).Discount_Percentage__c = Opty.Standard_Discount_Percentage__c;
                }
                update PEJRank4;
           }
          
           if(opty.Service_type__c == 'ANIRA') {
                list<End_Customer__c> endCust = new list<End_Customer__c>();
                endCust = [SELECT Anira_Custom_Discount__c FROM End_Customer__c WHERE ID=:opty.End_Customer__c limit 1];
               
                if(Opty.Custom_Deal_Reg_Percentage__c  != null) {
                    endCust.get(0).Anira_Custom_Discount__c = opty.Custom_Deal_Reg_Percentage__c;
                }
                if(endCust.size() > 0) {
                    update endCust;
                }
                
            }    
        }
        else{
            Double discountableListPrice=0;
            Double nonDiscountableListPrice=0;
            Double discountableOTCPrice=0;
            Double nonDiscountableOTCPrice=0;
            AggregateResult[] groupedResults = [SELECT SUM(list_price__c) sumValue,Type__c,Discountable__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c = :opptyId) GROUP BY Type__c, Discountable__c];
       
            if(!groupedResults.isEmpty() && groupedResults!=null)
            {
                for(AggregateResult agr: groupedResults)
                {
                    if(((agr.get('Type__c'))=='MRC') && ((agr.get('Discountable__c'))==false))
                    {
                        discountableListPrice = Double.ValueOf(agr.get('sumValue'));
                    }
                    else if(((agr.get('Type__c'))=='MRC') && ((agr.get('Discountable__c'))==true))
                    {
                        nonDiscountableListPrice = Double.ValueOf(agr.get('sumValue'));
                    }
                    else if(((agr.get('Type__c'))=='NRC') && ((agr.get('Discountable__c'))==false))
                    {
                        discountableOTCPrice = Double.ValueOf(agr.get('sumValue'));
                    }
                    else if (((agr.get('Type__c'))=='NRC') && ((agr.get('Discountable__c'))==true))
                    {
                        nonDiscountableOTCPrice = Double.ValueOf(agr.get('sumValue'));
                    }
                }
            }
            Opty.Discount_Amount__c = null;
            Opty.Discounted_Percentage__c = null;
            Opty.Custom_Deal_Reg_Percentage__c = null;
            Opty.Standard_Discount_Percentage__c =null;
            Opty.OTC_Discount_Amount__c = null;
            Opty.Discounted_Price__c =nonDiscountableListPrice+discountableListPrice;
            Opty.Cumulative_OTC_Discount_Price__c = nonDiscountableOTCPrice+discountableOTCPrice;
            opty.Apply_Promotions__c=true;
            opty.Promo_Deal_Reg__c='False';
            opty.Deal_Reg_Approved__c = true; 
            update Opty;
            Date newdate = Date.today().addmonths(6);
            proposalList[0].QuoteExpirationDate__c= newdate;
            update proposalList;
            SIConstants.isDealRegApproval =true;           
        }
    }

    global void finish(Database.BatchableContext BC){            
        
        list <Opportunity> oppUpdateList =new list<Opportunity>();                    
        if(opptyId != null)
        {
            oppUpdateList = [SELECT Id,Batch_Deal_Reg_Approved__c FROM Opportunity WHERE Id =: opptyId];
            for(Opportunity opty: oppUpdateList){
                opty.Batch_Deal_Reg_Approved__c = true;
            }
            update oppUpdateList;
        }                 
    }  
}