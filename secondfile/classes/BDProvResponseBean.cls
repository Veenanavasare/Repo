global class BDProvResponseBean extends ATTServiceInfoBean 
{
    global String JSONResponse; 
    global String Id{get;set;}
    global Response Response {get;set;}   
    global String conversationId;     
    global String messageId; 
    global Integer MessageCode{get;set;}    //1
    global String MessageText{get;set;} //Successful.
    public static BDProvResponseBean parse(String json){
        return (BDProvResponseBean) System.JSON.deserialize(json, BDProvResponseBean.class);
    }
    global class Response {
        global String Id{get;set;}
        global String code{get;set;}
         global String description{get;set;}
        }
}