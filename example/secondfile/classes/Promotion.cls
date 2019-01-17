/*******************************************************************************************************************
 * Class Name: Promotion
 * Author: Accenture
 * Date: 11-Jan-2018
 * Description: Query promotion data from cache/backend
********************************************************************************************************************/
public class Promotion{

    /*Query Individual Promotion Data*/
    public static Wireline_Promotion_Rules__c get(String promotionId){
         Map<Id,Wireline_Promotion_Rules__c> wpr;
         Wireline_Promotion_Rules__c wirelinePromo;
         wpr = (Map<Id,Wireline_Promotion_Rules__c>)Cache.Org.get('Promotion');
         if(wpr == null){
             wpr= new Map<Id,Wireline_Promotion_Rules__c>([select Active__c,Discount_Percentage__c,
             Display_Promotion_End_Date__c,End_Date__c,Expired__c,Expiry_Notification__c,Configured_Fields_After__c,Configured_Fields_Before__c,
             Field_input_values_JSON__c,Field_Inputs__c,For_Testing__c,Hierarchy__c,Priority__c,Priority_Number__c,Promo_Configurator_Lookup__c,
             Promo_Configured_Fields__c,Configured_Fields_Number__c,Promotion_Certified__c,Promotion_Certified_By__c,Rule_Description__c,Promotion_Name__c,
             Promotion_Notification__c,Promo_Type__c,Rank__c,Selected_Fields__c,Select_Fields_Json__c,
             Stackable__c,Start_Date__c,Test_SP__c,Do_Not_Run__c,name,Promotion_Tag__c,Early_Stop_Date__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c from Wireline_Promotion_Rules__c where Bulk_Promotion__c = false]);
             Cache.Org.put('Promotion',wpr);
             system.debug('@@@Promotion Not Found in Cache: '+wpr);
         }
         wirelinePromo= wpr.get(promotionId);
         system.debug('@@@Retrieved Wireline Promotion Data: ' +wirelinePromo);
         return wirelinePromo;
    }
    
    /*Query All Promotion Data*/
    public static Map<Id,Wireline_Promotion_Rules__c> getAll(){
         Map<Id,Wireline_Promotion_Rules__c> wpr;
         Map<Id,Wireline_Promotion_Rules__c> wprBulkList;
         wpr = (Map<Id,Wireline_Promotion_Rules__c>)Cache.Org.get('Promotion');
         if(wpr == null){
             wpr= new Map<Id,Wireline_Promotion_Rules__c>([select Active__c,Discount_Percentage__c,
             Display_Promotion_End_Date__c,End_Date__c,Expired__c,Expiry_Notification__c,Configured_Fields_After__c,Configured_Fields_Before__c,
             Field_input_values_JSON__c,Field_Inputs__c,For_Testing__c,Hierarchy__c,Priority__c,Priority_Number__c,Promo_Configurator_Lookup__c,
             Promo_Configured_Fields__c,Configured_Fields_Number__c,Promotion_Certified__c,Promotion_Certified_By__c,Rule_Description__c,Promotion_Name__c,
             Promotion_Notification__c,Promo_Type__c,Rank__c,Selected_Fields__c,Select_Fields_Json__c,
             Stackable__c,Start_Date__c,Test_SP__c,Do_Not_Run__c,name,Promotion_Tag__c,Early_Stop_Date__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c from Wireline_Promotion_Rules__c where Bulk_Promotion__c = false]);
             Cache.Org.put('Promotion',wpr);
         }     
             
         wprBulkList = new Map<Id,Wireline_Promotion_Rules__c>([select Active__c,Discount_Percentage__c,
         Display_Promotion_End_Date__c,End_Date__c,Expired__c,Expiry_Notification__c,Configured_Fields_After__c,Configured_Fields_Before__c,
         Field_input_values_JSON__c,Field_Inputs__c,For_Testing__c,Hierarchy__c,Priority__c,Priority_Number__c,Promo_Configurator_Lookup__c,
         Promo_Configured_Fields__c,Configured_Fields_Number__c,Promotion_Certified__c,Promotion_Certified_By__c,Rule_Description__c,Promotion_Name__c,
         Promotion_Notification__c,Promo_Type__c,Rank__c,Selected_Fields__c,Select_Fields_Json__c,
         Stackable__c,Start_Date__c,Test_SP__c,Do_Not_Run__c,name,Promotion_Tag__c,Early_Stop_Date__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c from Wireline_Promotion_Rules__c where Bulk_Promotion__c = true]);     
         
         if(wprBulkList != null && wprBulkList.size()>0){
             wpr.putAll(wprBulkList);
         }
         system.debug('@@@Wireline Promotions: '+wpr);
         return wpr;
    }
}