public virtual class WrapperUIGridElemnt extends Wrapper_UI_Element {
integer colID{get;set;}
integer rowID{get;set;}
   
Map <String,SIVARElementList> firstchildElements;
Map <String,SIVARElementMap> firstchildElementsMap;



public SIVARElementMap  getChildElementsMap(String key){
SIVARElementMap elemnts=firstchildElementsMap.get(key);
    if(elemnts==null){
        firstchildElementsMap.put(key, new SIVARElementMap());
        
    }
return firstchildElementsMap.get(key);
}

public void setChildElementsMap(String key,Map<String, WrapperUIGridElemnt> childeles){
if(firstchildElementsMap.get(key)==null){
SIVARElementMap svMap= new SIVARElementMap ();
firstchildElementsMap.put(key,svMap);
}
SIVARElementMap  svList=firstchildElementsMap.get(key);
svList.add(childeles);

}


public void setChildElementsMap(String key,String k2, WrapperUIGridElemnt childeles){
if(firstchildElementsMap.get(key)==null){
SIVARElementMap svMap= new SIVARElementMap ();
firstchildElementsMap.put(key,svMap);
}
SIVARElementMap  sMap=firstchildElementsMap.get(key);
sMap.add(k2,childeles);

}


public SIVARElementList  getChildElements(String key){
SIVARElementList elemnts=firstchildElements.get(key);
    if(elemnts==null){
        firstchildElements.put(key, new SIVARElementList());
        
    }
return firstchildElements.get(key);
}


public void setChildElements(String key,List<WrapperUIGridElemnt> childeles){
if(firstchildElements.get(key)==null){
SIVARElementList svList= new SIVARElementList ();
firstchildElements.put(key,svList);
}
SIVARElementList  svList=firstchildElements.get(key);
svList.add(childeles);

}



 public integer  getElementListSize(String s){
    return this.getChildElements(s).size();
    }
public void setChildElements(String key,WrapperUIGridElemnt childeles){
if(firstchildElements.get(key)==null){
SIVARElementList svList= new SIVARElementList ();
firstchildElements.put(key,svList);
}
SIVARElementList  svList=firstchildElements.get(key);
svList.add(childeles);

}


String styleDetails ;
 public WrapperUIGridElemnt (){
 
    firstchildElements= new Map <String,SIVARElementList> ();
   firstchildElementsMap= new Map<String,SIVARElementMap> ();
    this.setType('WrapperUIGridElemnt');
     this.gversion=0;
     this.sversion=0;
  //   uiStyleMap= new Map<String,String>() ;
    }
    
   public void applyStyle(String s){
        styleDetails=s;
    }
    public String getStyle(){
        return styleDetails;
    }
   

   
  
     
  

     
      public Map<String,String> getuiStyleMap(){
       Map<String,String>uiStyleMap= new   Map<String,String>();
   String[] splitStrings= getStyle().split('\\^',100);
  
   for( integer i=0;i<splitStrings.size();i++){
String[]   stylemapdata=splitStrings[i].split('\\~',2);
  if(stylemapdata.size()==2){
   uiStyleMap.put(stylemapdata[0],stylemapdata[1]);
  } }
     // uiStyle.addall(splitStrings);
   return  uiStyleMap;
     }

public void setRowID(integer rowID_p){
 rowID=rowID_p;
}

public void setColID(integer colID_p){
 colID=colID_p;
}

public integer getRowID(){
return rowID;
}
public integer getColID(){
return colID;
}


public override virtual String toString()
    {
        String[] returnValue =new String [0];
        
        
        returnValue.add('<WrapperUIGridElemnt >');
          returnValue.add('<getversion>' + gversion);
        returnValue.add('</getversion>');
          returnValue.add('<setversion>' + sversion);
        returnValue.add('</setversion>');
        
        returnValue.add('<name>' + name);
        returnValue.add('</name>');  returnValue.add('<label>' + label);
        returnValue.add('</label>');
          returnValue.add('<value>' + value);
        returnValue.add('</value>');
          returnValue.add('<type>' + type);
        returnValue.add('</type>');  
           returnValue.add('<style>' + this.getStyle());
        returnValue.add('</style>'); 
        returnValue.add('<colID>' + colID);
        returnValue.add('</colID>');  
        returnValue.add('<rowID>' + rowID);
        returnValue.add('</rowID>');  
          returnValue.add('<stylingConfigurationList>' + stylingConfigurationList);
        returnValue.add('</stylingConfigurationList>'); 
        
          returnValue.add('</WrapperUIGridElemnt >');
        String returnValueStr= String.join(returnValue, ' ');
        return returnValueStr;
    }
    
    SIVARElementList stylingConfigurationList=null;
public void setStylingConfigurationList(SIVARElementList stylingConfigurationList_p){
 stylingConfigurationList=stylingConfigurationList_p;
 }
 
 
public SIVARElementList getStylingConfigurationList(){
return  stylingConfigurationList;
 }
}