/**************************************************************************************
 Apex Class Name     : ATTException
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : Exception class to manage exception related activities
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/

public with sharing class ATTException extends Exception{
    /*
     * Method name  : createException
     * Description  : Method to create exception in an assynchronous manner
     * Return Type  : void
     * Parameter    : String, String, String
     */

    @future
    public static void createException(String functionPoint, String exceptionType, String exceptionMessage){
        //Create an exception record
        Exception__c exceptionInstance=new Exception__c();
        exceptionInstance.Function_Point__c=functionPoint;
        exceptionInstance.Exception_Type__c=exceptionType;
        exceptionInstance.Exception_Message__c=generateRandomNumber() +'-'+exceptionMessage;
        try {
            insert exceptionInstance;
        } catch(Exception e){
            // exception occured while record insertion, notify calling method.
            return;
        }
        //inserted successfully. return true
        return;
    }

    /*
     * Method name  : createException
     * Description  : Method to create exception 
     * Return Type  : void
     * Parameter    : String, String, String
     */

    public static void createExceptionWithoutFuture(String functionPoint,String exceptionType, String exceptionMessage){
        //Create an exception record
        Exception__c exceptionInstance=new Exception__c();
        exceptionInstance.Function_Point__c=functionPoint;
        exceptionInstance.Exception_Type__c=exceptionType;
        exceptionInstance.Exception_Message__c=generateRandomNumber() +'-'+exceptionMessage;
        try {
            insert exceptionInstance;
            } catch(Exception e){
            // exception occured while record insertion, notify calling method.
            return;
        }
        //inserted successfully. return true
        return;
    }

    /*
     * Method name  : constructExceptionMessageString
     * Description  : Method to construct the exception message from exception object
     * Return Type  : String
     * Parameter    : Exception
     */

    public static String constructExceptionMessageString(Exception exceptionInstance){
           String exceptionString='\n Line Number : ' + exceptionInstance.getLineNumber();
           exceptionString+='\n Exception Cause: ' + exceptionInstance.getCause();
           exceptionString+='\n Exception Message: ' + exceptionInstance.getMessage();
           exceptionString+='\n Stack Trace: ' + exceptionInstance.getStackTraceString();
           return exceptionString;
    }

    /*
     * Method name  : generateRandomNumber
     * Description  : Method to generate a random number
     * Return Type  : None
     * Parameter    : String
     */

    public static String generateRandomNumber() {
        String sn = String.valueOf(system.now().getTime())+Math.random().intValue();
        return sn;
    }
    /*
     * Method name  : logException
     * Description  : Method to log an exception into exception object
     * Return Type  : None
     * Parameter    : String, string
     */
    public static void logException(String exceptionType, String exceptionMessage){
        system.debug('###'+exceptionType);
        if(exceptionType == 'system.DMLException'){
            //Only in case of DML Exception this will be called as it is FUTURE
            ATTException.createException(null,exceptionType, exceptionMessage);
        }
        else{
            ATTException.createExceptionWithoutFuture(null,exceptionType, exceptionMessage);
        }
    }

}