/************************************************************************************** 
 Apex Class Name     : SIRecursiveCheck
 Version             : 1.0 
 Created Date        : May 2017
 Function            : This class tracks the Recursive booleans
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Accenture            May 2017              Original Version
*************************************************************************************/

public with sharing class SIRecursiveCheck{
    
    /*
     * @description: default constructor
     *
     */
    public SIRecursiveCheck() {
        system.debug('This constructor is for SIRecursiveCheck');
    }
    
    public static Boolean recursiveAccountTriggerHandler_BirchAccountUpdate = false;
}