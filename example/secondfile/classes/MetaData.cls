public class MetaData implements Cache.CacheBuilder
{
    public Map<id,Wireline_Promo_Meta_Data__c> doLoad(String id)
    {
        Map<Id,Wireline_Promo_Meta_Data__c> metaData = new Map<Id,Wireline_Promo_Meta_Data__c>([select Id,WP_Block_Promotion__c, To_Be_Counted_as_One__c,Before_Apply_Get_Price__c,WP_Configurator_Name__c,WP_Field_API_Name__c,WP_Field_Name__c,WP_Field_Value__c,WP_Object_API_Name__c,WP_Promo_Type__c,WP_Requires_Input__c,WP_Section_Name__c,WP_Section_Order__c from Wireline_Promo_Meta_Data__c]);
        return metaData;        
    }
}