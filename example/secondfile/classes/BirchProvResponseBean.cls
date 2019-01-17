global class BirchProvResponseBean extends ATTServiceInfoBean 
{
    //to store the raw json Response
    global String JSONResponse; 
    global String Id{get;set;}
    global Response Response {get;set;}   
    global String conversationId;     
    global String messageId; 
    global Integer MessageCode{get;set;}	//1
	global String MessageText{get;set;}	//Successful.
	public static BirchProvResponseBean parse(String json){
		return (BirchProvResponseBean) System.JSON.deserialize(json, BirchProvResponseBean.class);
	}
    global class Response {
        global String Id{get;set;}
        global String code {get;set;}
        global String description {get;set;}
    }
}