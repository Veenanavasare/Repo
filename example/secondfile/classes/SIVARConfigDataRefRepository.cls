/* 
 Name:  SIVARConfigDataRefRepository
 Type: Class 
 
 Description: 
 */ 
public class SIVARConfigDataRefRepository {
private static Map<String, SIVARConfiguration>dataRefRepository= new Map<String, SIVARConfiguration>();

private static SIVARConfigDataRefRepository perfsuiteCntx = new SIVARConfigDataRefRepository();

/* 
 Name: getInstance
 Description: 
 */ 
public static SIVARConfigDataRefRepository getInstance() {
    return perfsuiteCntx;
}
//
/* 
 Name: getDataRefRepository
 Description: 
 */ 
//public static HashMap<String, CummulativeDataRef> getDataRefRepository() {
//  return dataRefRepository;
//}
//
//public static void setDataRefRepository(
   
//      HashMap<String, CummulativeDataRef> dataRefRepository) {
//  DataRefRepository.dataRefRepository = dataRefRepository;
//}
/* 
 Name: addSIVARConfiguration
 Description: 
 */ 
public  void  addSIVARConfiguration(String id,SIVARConfiguration cdref){
    try{
    dataRefRepository.put(id,cdref);
    // WigtLogger.logFine(CLASS_NAME, METHOD_NAME ,UtilityConstant.SETTINGDATA_REPOSITORY_TO_1ST_x+dataRefRepository);
    }
    catch(Exception e){ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));}

}
/*addSIVARConfiguration*/
public void addSIVARConfiguration(String id,SIVARConfigData value){
   try{
    if(dataRefRepository.get(id)==null){
        dataRefRepository.put(id, new SIVARConfiguration());
    }
    dataRefRepository.get(id).addConfigData( value);
    // WigtLogger.logFine(CLASS_NAME, METHOD_NAME ,UtilityConstant.SETTINGDATA_REPOSITORY_TO_2ND_x+dataRefRepository);
    }
    catch(Exception e){ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e)); }
}
  /*getSIVARConfiguration*/
 public SIVARConfiguration getSIVARConfiguration(String id){
   try{
    SIVARConfiguration dataRef = dataRefRepository.get(id);
    if(dataRef==null){
        dataRef=new SIVARConfiguration();
    }
    return dataRef;
    }
    catch(Exception e){ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));return null;}
    }

  /*getSIVARConfigurationData*/
 public SIVARElementList getSIVARConfigurationData(String id){
  try{
    return dataRefRepository.get(id).getConfigData();
    }
    catch(Exception e){ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));return null;}
}

/* 
 Name: toString
 Description: 
 */ 
public override  String toString(){
  try
  {
     String[] sb=new String [0];
    
    sb.add('<DataRefRepository>');
    sb.add('<dataRefRepository>');
    sb.add(dataRefRepository+SpecialCharacterConstant.CONCAT);
    sb.add('</dataRefRepository>');
    sb.add('</DataRefRepository>');
    String returnValueStr= String.join(sb, SpecialCharacterConstant.BLANK);
        return returnValueStr;
    }
    catch(Exception e){ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));return null;}
}
}