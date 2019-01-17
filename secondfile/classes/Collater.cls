public class Collater implements Model {

    private  Map <String,Type> collatedDataMap=null;
    public Collater (){
    collatedDataMap= new Map <String,Type> ();
    
    }
    
    public void setCollatedData(String s ,Type t){
    collatedDataMap.put(s,t);
    }
    
    
    public Type getCollatedData(String s ){
     return collatedDataMap.get(s);
    }



}