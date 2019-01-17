/************************************************************************************* 
 Apex Class Name     : uiLoggingController 
 Version             : 1.0 
 Created Date        : 7 July 2016
 Function            : This class handles UI logging metrics.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikanth Reddy Chalamalla   07/07/2016             Original Version

*************************************************************************************/

public class uiLoggingController {
    public AggregateResult[] groupedResults {get;set;}
  	public List<wrapperClass> wpList {get; set;}
    public Boolean noRecordsExists{get;set;}
    public String dateSelected{get;set;}
    public String buttonValue{get;set;}
    
    public uiLoggingController(){}

    public void getAllRecords(){
        noRecordsExists = false;
        buttonValue = 'Submit';        
        groupedResults = new List<AggregateResult>();
        wpList = new List<wrapperClass>();
        groupedResults = [SELECT pageName__c,AVG(requestStartTime__c)requestStart,AVG(latencyTime__c)latencyTime,AVG(processingTime__c)processingTime,AVG(pageLoadTime__c)pageLoad
                          FROM UI_Logging_Metric__c
                          GROUP BY pageName__c];
        if(groupedResults.size() > 0){
            for(AggregateResult ar : groupedResults){
                wrapperClass wp = new wrapperClass(ar);
                wpList.add(wp);
            } 
      		System.debug('List of All records=='+wpList);            
        }else{
            noRecordsExists = true;
        }        
    }

    public class wrapperClass{
        public String pageName {get; set;}
        public Integer requestStart {get; set;}
        public Integer latencyTime {get; set;}
        public Integer processingTime {get; set;}
        public Integer pageLoad {get; set;}
        
        public wrapperClass(AggregateResult ar){
            pageName = (String) ar.get('pageName__c');
            requestStart = Integer.valueOf(ar.get('requestStart'));
            latencyTime = Integer.valueOf(ar.get('latencyTime'));
            processingTime = Integer.valueOf(ar.get('processingTime'));
            pageLoad = Integer.valueOf(ar.get('pageLoad'));
        }
    }
    
    @RemoteAction
    public static Integer savePerformanceMetrics(Integer requestStartTime,Integer latencyTime,Integer processingTime,Integer pageLoadTime,String pageName,String browser){
        String recordMetricsFlag = Global_Variable__c.getValues('Record_UI_Metrics') != null ? Global_Variable__c.getValues('Record_UI_Metrics').Value__c : '';
        if(recordMetricsFlag == 'true' || recordMetricsFlag == 'True'){
            UI_Logging_Metric__c loggingMetrics = new UI_Logging_Metric__c(); //Custom Object
            loggingMetrics.requestStartTime__c = requestStartTime;
            loggingMetrics.latencyTime__c = latencyTime;
            loggingMetrics.processingTime__c = processingTime;
            loggingMetrics.pageLoadTime__c = pageLoadTime;
            loggingMetrics.pageName__c = pageName;
            loggingMetrics.Browser__c = browser;
            insert loggingMetrics;            
        }
        return null;
    }

    public void fetchRecordsByDate(){
        System.debug('selected Date to show Records=='+dateSelected);
        List<String> dateParts = dateSelected.split('/');
        Datetime selectedDayStartTime = DateTime.newInstanceGmt(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 00, 00, 00);
        Datetime selectedDayEndTime = DateTime.newInstanceGmt(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 23, 59, 59);
        System.debug('Formated Date=='+selectedDayStartTime);
        System.debug('Formated Date=='+selectedDayEndTime);
        buttonValue = 'Reset';
        groupedResults.clear();
        wpList.clear();
        groupedResults = new List<AggregateResult>();
        wpList = new List<wrapperClass>();
        groupedResults = [SELECT pageName__c,AVG(requestStartTime__c)requestStart,AVG(latencyTime__c)latencyTime,AVG(processingTime__c)processingTime,AVG(pageLoadTime__c)pageLoad
              FROM UI_Logging_Metric__c WHERE (CreatedDate >=: selectedDayStartTime AND CreatedDate <=: selectedDayEndTime)
              GROUP BY pageName__c];
        if(groupedResults.size() > 0){
            for(AggregateResult ar : groupedResults){
                wrapperClass wp = new wrapperClass(ar);
                wpList.add(wp);
            }
            System.debug('Records on Selected Date=='+wpList);
        }else{
            noRecordsExists = true;
        }        
    }
    
    public void resetAllRecords(){
        System.debug('Reset Method Triggered');
        groupedResults.clear();
        wpList.clear();
    	getAllRecords();         
    }    
}