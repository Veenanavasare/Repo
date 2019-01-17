public  virtual class SIVARConfiguration implements SIVARConfigurationElement {
 SIVARElementList cofigDataList=null;
    
    public  SIVARConfiguration(){
        cofigDataList=new SIVARElementList();
        }
        
    public void addConfigData(SIVARConfigData configData){
        cofigDataList.add(configData);
        }

    public SIVARElementList getConfigData(){
        return cofigDataList;
    }

}