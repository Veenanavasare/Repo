public class WrapperUIElementPositionFilter extends FilterExecutionModel 
{
    
private integer rowID=-1;
 
private integer colID=-1;

public WrapperUIElementPositionFilter (FilterableList sivarlist,integer rowID_p,integer colID_p) {
    super(sivarlist);
    if(rowID==-1){
    rowID=rowID_p;
    }if(colID==-1){
  colID=colID_p;
 }
    }
protected override boolean apply(SIVARElement item) {
    //
    WrapperUIGridElemnt wuisec=(WrapperUIGridElemnt) item;
   // system.debug('rowID='+rowID+' colID='+colID+'filter working on'+item);
    if(rowID!=-1 && colID!=-1 ){
    boolean b= (( rowID== wuisec.getRowID()) && (colID== wuisec.getColID()));
    //system.debug('satisfied filter returing boolean '+b+' for rowID:'+rowID+' col value:'+colID);
      return  b;
    }else if(rowID!=-1 && colID==-1 ) {
    return ( rowID== wuisec.getRowID());
    }else if(colID!=-1 && rowID==-1 ) {
    return ( colID== wuisec.getColID());
    }else {
    return false;
    }
}
}