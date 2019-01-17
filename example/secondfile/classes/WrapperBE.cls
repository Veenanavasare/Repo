public class WrapperBE implements SIVARWrapper { //was abstract class
    private  List<String> beWrapList;
    private  Map<String,String>wrapMapBE;
    private  Map<String,Map<String,String>>wrapperMapBE;
    private  Set<date> attHolSet;
    private Date minMaxDate;
    private WrapperUIRenderComponent wrc;

   //WrapperUIRenderComponent 
private Collater collatedData;
    
    
  public void setCollatedData(String s, Type t){
  collatedData.setCollatedData(s,t);
  }  
  
  
  public Type getCollatedData(String s){
 return  collatedData.getCollatedData(s);
  }  
        public void setBeWrapList(List<String> beWrapList) {
            this.beWrapList = beWrapList;
        }

        public Map<String, String> getWrapMapBE() {
            return wrapMapBE;
        }

        public void setWrapMapBE(Map<String, String> wrapMapBE) {
            this.wrapMapBE = wrapMapBE;
        }

        public Map<String, Map<String, String>> getWrapperMapBE() {
            return wrapperMapBE;
        }

        public void setWrapperMapBE(Map<String, Map<String, String>> wrapperMapBE) {
            this.wrapperMapBE = wrapperMapBE;
        }

        public Set<date> getAttHolSet() {
            return attHolSet;
        }

        public void setAttHolSet(Set<date> attHolSet) {
            this.attHolSet = attHolSet;
        }
        
         public Date getMinMaxDate() {
        return minMaxDate;
    }

    public void setMinMaxDate(Date minMaxDate) {
        this.minMaxDate = minMaxDate;
    }
    
     public WrapperUIRenderComponent getWrapperUIRenderComponent () {
        return wrc;
    }

    public void setWrapperUIRenderComponent (WrapperUIRenderComponent wrc) {
        this.wrc= wrc;
    }


        
    public WrapperBE(){
    collatedData= new   Collater();
    }
}