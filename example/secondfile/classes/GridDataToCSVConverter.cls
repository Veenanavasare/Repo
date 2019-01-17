public class GridDataToCSVConverter{

   public List<Attachment> AttList;
   public List<String> s=new  List<String>();
   public string excelName; 
   
   public Map<Integer,List<String>>dataMap=new Map<Integer, List<String>>();
public  String[] myList = new List<String>();

   public GridDataToCSVConverter(){
   if(AttList == NULL){
             AttList = new List<Attachment>();
         }
         }

public void generateCSVForGridData(WrapperUIGridElemnt wrc,string opptyId, string filename ){

try{

excelName = filename;
/**SIVARElementList wui_s_List =  wrc.getChildElements('WrapperUISection');**/
SIVARElementMap wui_s_List =  wrc.getChildElementsMap('WrapperUISection');
Map<String,SivarElement> seim= wui_s_List.getMap();

string sectionstr='';
SIVARElementIterator sei= wui_s_List .iterator();

Set<String> keys= seim.keyset();
//Iterator<String> sei=keys.iterator();

WrapperUISection headSec=(WrapperUISection)seim.get('1'+'_'+'0');
SIVARElementMap sEhead=headSec.getChildElementsMap('WrapperUIRenderSectionElement');
integer seLen=sEhead.getMap().size();

integer secLen=wui_s_List.getMap().size();
for(integer b=1;b<=secLen;b++){
    WrapperUISection wuiSec=(WrapperUISection)seim.get(b+'_'+'0');
//  WrapperUISection wuiSec=(WrapperUISection)sei.next();
SIVARElementMap wuirSE_s_List =  wuiSec.getChildElementsMap('WrapperUIRenderSectionElement');
for(integer z=1;z<=seLen;z++){
WrapperUIRenderSectionElement wuiSe=  (WrapperUIRenderSectionElement )  wuirSE_s_List.get(b+'_'+z);

if(wuiSe!=null && wuiSe.getValue()!=null && wuiSe.getValue()!='null'){
    sectionstr=sectionstr+ wuiSe.getvalue().escapeCSV()+',';
    }else{
        sectionstr=sectionstr+ ''.escapeCSV()+',';
    }
}

sectionstr=sectionstr+'\n';
}
/**
while(sei.hasNext()){
WrapperUISection wuiSec=(WrapperUISection)sei.next();

SIVARElementList wuirSE_s_List =  wuiSec.getChildElements('WrapperUIRenderSectionElement');
SIVARElementIterator seie= wuirSE_s_List.iterator();
while(seie.hasNext()){
WrapperUIRenderSectionElement wuiSe=(WrapperUIRenderSectionElement)seie.next();
sectionstr=sectionstr+ wuiSe.getvalue().escapecsv()+',';

//

} 
sectionstr=sectionstr+'\n';
//system.debug('sectionstr'+sectionstr);


//

}**/
/**
//loadStringS();
dataMap.put(0,loadStringS());
//List<String>() cellsData=;
 dataMap.put(1,loadCellsOnDataMap(wrc));

 dataMap.put(2,loadTrailerString());
    //system.debug('--SizeOfBlob--'+sectionstr.length());



String sectionstr2=buildFinalString();




system.debug('sectionstr2 added to file is:'+sectionstr2);

blob csvBlob = Blob.valueOf(sectionstr2);
**/blob csvBlob = Blob.valueOf(sectionstr); 
system.debug('sectionstr added to file is:'+sectionstr + 'OpptyId : '+opptyId);

id  OpptId = opptyId;
List <Attachment> delAttachmentList = [select Id from Attachment where parentId =: opptyId AND description = 'RDS Excel Generated' ];
   //    PageReference pageRef = new PageReference('/apex/RDSExcelExportContent');
        Blob body;
         //OppID = quoteObj.Apttus_Proposal__Opportunity__c;  
            Attachment attach = new Attachment(); 
            EncodingUtil eu;
           // String  stringToBlob = EncodingUtil.base64Encode(pageRef.getContent());
           // attach.Body = EncodingUtil.base64Decode(stringToBlob);
             attach.Body =csvBlob ;
            // add the user entered name
            attach.Name = filename ;
            attach.IsPrivate = false;
            attach.description = 'RDS Excel Generated';
            // attach the pdf to the account
            attach.ParentId = opptyId;
            if(AttList != NULL){
                AttList.add(attach); 
            } 
              
            insert  AttList;  
            if(delAttachmentList.size()>0){
                delete delAttachmentList;
            }        
            system.debug('GridDataToCSVConverter^generateCSVForGridData^after attaching the file');         
//return wuirSEListRW ;
}catch(Exception e){
system.debug('exception caught while generating xl'+e);
ApplicationException ae=new ApplicationException('043539','exception caught while generating xl'+e.getlinenumber(),e);
throw ae;

} 
}

public string buildFinalString(){
String  sectionstr2='';
    for(integer i=0;i<dataMap.size();i++){

        List<String> dataStringList=dataMap.get(i);
        Iterator<String> itr= dataStringList.iterator();
        while(itr.hasnext()){
        sectionstr2 =sectionstr2+itr.next();
        }       
    }
    return sectionstr2;
}




public List<String> loadCellsOnDataMap(WrapperUIGridElemnt wrc){

//RDSExcelController controller  = new RDSExcelController();
SIVARElementMap wui_s_List =  wrc.getChildElementsMap('WrapperUISection');
Map<String,SivarElement> seim= wui_s_List.getMap();

Set<String> keys= seim.keyset();
Iterator<String> sei=keys.iterator();

List<String> sectionList= new List<String>();
//string sectionstr='';
String name;
String cell;
String style='Default';
while(sei.hasNext()){
WrapperUISection wuiSec=(WrapperUISection)seim.get(sei.next());
name=wuiSec.getName();
sectionList.ADD(' <Row>');
system.debug('excelName.contains AVPN'+excelName.contains('AVPN'));
if(excelName.contains('AVPN')){
    if(name.equals('1')){
        style='s16';
    
    }else if (name.equals('7') || name.equals('19') || name.equals('54') || name.equals('70') || name.equals('157') || name.equals('228') || name.equals('299') || name.equals('370') || name.equals('441') || name.equals('512') || name.equals('583') || name.equals('654') || name.equals('725') || name.equals('796') || name.equals('867') || name.equals('938')){
        style='s20';
    }
    else if (name.equals('20') || name.equals('26') || name.equals('32') || name.equals('37') || name.equals('42') || name.equals('47')){
        style='s23';
    }
    else{
        style='s25';
    }
}
else{
    if(name.equals('1')){
        style='s16';
    
    }else if (name.equals('7') || name.equals('23') || name.equals('62') || name.equals('78') || name.equals('161')){
        style='s20';
    }
    else if (name.equals('24') || name.equals('30') || name.equals('36') || name.equals('45') || name.equals('50') || name.equals('55')){
        style='s23';
    }
    else{
        style='s25';
    }
}
SIVARElementMap wuirSE_s_Map =  wuiSec.getChildElementsMap('WrapperUIRenderSectionElement');
Map<String,SivarElement> seMap=wuirSE_s_Map.getMap();
Set<String> keysSe=seMap.keyset();


Iterator<String> seie= keysSe.iterator(); 

/**
S.ADD(' <Row>');
S.ADD('  <Cell ss:StyleID="s16"><Data ss:Type="String">AVPN</Data></Cell>');
S.ADD('  <Cell ss:StyleID="s26"><Data ss:Type="String">Field Attributes/ Derivations</Data></Cell>');
S.ADD('  <Cell ss:StyleID="s16"><Data ss:Type="String">Site 1 - &lt;City Name&gt;</Data></Cell>');
S.ADD(' </Row>');
***/

    while(seie.hasNext()){
        WrapperUIRenderSectionElement wuiSe=(WrapperUIRenderSectionElement)seMap.get(seie.next());
        sectionList.ADD('<Cell ss:StyleID="'+style+'"><Data ss:Type="String">'+wuiSe.getvalue()+'</Data></Cell>');
        cell=wuiSe.getName();
            if(excelName.contains('AVPN')){
                if(name.equals('54') && cell.equals('Site Address')){
                        style='s23';
                    } 
                    }
            else{
            if(name.equals('62') && wuiSe.getName().equals('Site Address') ){
                        style='s23';      
            }
            
            if(name.equals('62') && wuiSe.getName().equals('') ){
                        style='s23';      
            }
            }
    } 
//sectionstr=sectionstr+'\n';
//system.debug('sectionstr'+sectionstr);


//
style='Default';
sectionList.ADD(' </Row>');
}
return sectionList;
}


public List<String> loadCellsOnData(WrapperUIGridElemnt wrc){

//RDSExcelController controller  = new RDSExcelController();
SIVARElementList wui_s_List =  wrc.getChildElements('WrapperUISection');
SIVARElementIterator sei= wui_s_List .iterator();
List<String> sectionList= new List<String>();
//string sectionstr='';
String name;
String cell;
String style='Default';
while(sei.hasNext()){
WrapperUISection wuiSec=(WrapperUISection)sei.next();
name=wuiSec.getName();
sectionList.ADD(' <Row>');
system.debug('excelName.contains AVPN'+excelName.contains('AVPN'));
if(excelName.contains('AVPN')){
    if(name.equals('1')){
        style='s16';
    
    }else if (name.equals('7') || name.equals('19') || name.equals('54') || name.equals('70') || name.equals('157') || name.equals('228') || name.equals('299') || name.equals('370') || name.equals('441') || name.equals('512') || name.equals('583') || name.equals('654') || name.equals('725') || name.equals('796') || name.equals('867') || name.equals('938')){
        style='s20';
    }
    else if (name.equals('20') || name.equals('26') || name.equals('32') || name.equals('37') || name.equals('42') || name.equals('47')){
        style='s23';
    }
    else{
        style='s25';
    }
}
else{
    if(name.equals('1')){
        style='s16';
    
    }else if (name.equals('7') || name.equals('23') || name.equals('62') || name.equals('78') || name.equals('161')){
        style='s20';
    }
    else if (name.equals('24') || name.equals('30') || name.equals('36') || name.equals('45') || name.equals('50') || name.equals('55')){
        style='s23';
    }
    else{
        style='s25';
    }
}
SIVARElementList wuirSE_s_List =  wuiSec.getChildElements('WrapperUIRenderSectionElement');
SIVARElementIterator seie= wuirSE_s_List.iterator();

/**
S.ADD(' <Row>');
S.ADD('  <Cell ss:StyleID="s16"><Data ss:Type="String">AVPN</Data></Cell>');
S.ADD('  <Cell ss:StyleID="s26"><Data ss:Type="String">Field Attributes/ Derivations</Data></Cell>');
S.ADD('  <Cell ss:StyleID="s16"><Data ss:Type="String">Site 1 - &lt;City Name&gt;</Data></Cell>');
S.ADD(' </Row>');
***/

    while(seie.hasNext()){
        WrapperUIRenderSectionElement wuiSe=(WrapperUIRenderSectionElement)seie.next();
        sectionList.ADD('<Cell ss:StyleID="'+style+'"><Data ss:Type="String">'+wuiSe.getvalue()+'</Data></Cell>');
        cell=wuiSe.getName();
            if(excelName.contains('AVPN')){
                if(name.equals('54') && cell.equals('Site Address')){
                        style='s23';
                    } 
                    }
            else{
            if(name.equals('62') && wuiSe.getName().equals('Site Address') ){
                        style='s23';      
            }
            
            if(name.equals('62') && wuiSe.getName().equals('') ){
                        style='s23';      
            }
            }
    } 
//sectionstr=sectionstr+'\n';
//system.debug('sectionstr'+sectionstr);


//
style='Default';
sectionList.ADD(' </Row>');
}
return sectionList;
}

public List<String> loadStringS(){
S.ADD(' <?xml version="1.0"?>');
S.ADD(' <?mso-application progid="Excel.Sheet"?>');
S.ADD(' <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
S.ADD('  xmlns:o="urn:schemas-microsoft-com:office:office"');
S.ADD('  xmlns:x="urn:schemas-microsoft-com:office:excel"');
S.ADD('  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
S.ADD('  xmlns:html="http://www.w3.org/TR/REC-html40">');
S.ADD('  <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">');
S.ADD('<Author>KOLLA, GOPINADH</Author>');
S.ADD('<LastAuthor>Administrator</LastAuthor>');
S.ADD('<Created>2016-02-24T23:37:37Z</Created>');
S.ADD('<LastSaved>2016-03-22T10:09:49Z</LastSaved>');
S.ADD('<Version>15.00</Version>');
S.ADD('  </DocumentProperties>');
S.ADD('  <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">');
S.ADD('<AllowPNG/>');
S.ADD('  </OfficeDocumentSettings>');
S.ADD('  <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">');
S.ADD('<WindowHeight>7350</WindowHeight>');
S.ADD('<WindowWidth>20430</WindowWidth>');
S.ADD('<WindowTopX>0</WindowTopX>');
S.ADD('<WindowTopY>0</WindowTopY>');
S.ADD('<ProtectStructure>False</ProtectStructure>');
S.ADD('<ProtectWindows>False</ProtectWindows>');
S.ADD('  </ExcelWorkbook>');
S.ADD('  <Styles>');
S.ADD('<Style ss:ID="Default" ss:Name="Normal">');
S.ADD(' <Alignment ss:Vertical="Bottom"/>');
S.ADD(' <Borders/>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>');
S.ADD(' <Interior/>');
S.ADD(' <NumberFormat/>');
S.ADD(' <Protection/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s16">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"');
S.ADD('  ss:Bold="1"/>');
S.ADD(' <Interior ss:Color="#548235" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s17">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s18">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s20">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"');
S.ADD('  ss:Bold="1"/>');
S.ADD(' <Interior ss:Color="#00B0F0" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s21">');
S.ADD(' <Borders/>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s22">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>');
S.ADD(' <Interior ss:Color="#00B0F0" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s23">');
S.ADD(' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s25">');
S.ADD(' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s26">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"');
S.ADD('  ss:Bold="1"/>');
S.ADD(' <Interior ss:Color="#548235" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s27">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s28">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s29">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s30">');
S.ADD(' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s31">');
S.ADD(' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s32">');
S.ADD(' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior ss:Color="#FFD966" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s33">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior ss:Color="#FFD966" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s34">');
S.ADD(' <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior ss:Color="#C9C9C9" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s35">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>');
S.ADD(' <Interior ss:Color="#C9C9C9" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s36">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>');
S.ADD(' <Interior ss:Color="#00B0F0" ss:Pattern="Solid"/>');
S.ADD('</Style>');
S.ADD('<Style ss:ID="s37">');
S.ADD(' <Borders>');
S.ADD('  <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD('  <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
S.ADD(' </Borders>');
S.ADD(' <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"');
S.ADD('  ss:Bold="1"/>');
S.ADD('</Style>');
S.ADD('  </Styles>');
S.ADD('  <Worksheet ss:Name="AVPN Sites">');
S.ADD('<Table ss:ExpandedColumnCount="16375" ss:ExpandedRowCount="1006"');
S.ADD(' x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">');
S.ADD(' <Column ss:AutoFitWidth="0" ss:Width="231.75"/>');
S.ADD(' <Column ss:AutoFitWidth="0" ss:Width="204.75"/>');
S.ADD(' <Column ss:AutoFitWidth="0" ss:Width="110.25"/>');
 return s;
}

public List<String>  loadTrailerString(){
    List<String> ts= new List<String>();
    ts.ADD('</Table>');
ts.ADD('<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">');
ts.ADD(' <PageSetup>');
ts.ADD('  <Header x:Margin="0.3"/>');
ts.ADD('  <Footer x:Margin="0.3"/>');
ts.ADD('  <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>');
ts.ADD(' </PageSetup>');
ts.ADD(' <Print>');
ts.ADD('  <ValidPrinterInfo/>');
ts.ADD('  <HorizontalResolution>600</HorizontalResolution>');
ts.ADD('  <VerticalResolution>600</VerticalResolution>');
ts.ADD(' </Print>');
ts.ADD(' <Selected/>');
ts.ADD(' <TopRowVisible>97</TopRowVisible>');
ts.ADD(' <Panes>');
ts.ADD('  <Pane>');
ts.ADD('   <Number>3</Number>');
ts.ADD('   <ActiveRow>99</ActiveRow>');
ts.ADD('   <ActiveCol>1</ActiveCol>');
ts.ADD('  </Pane>');
ts.ADD(' </Panes>');
ts.ADD(' <ProtectObjects>False</ProtectObjects>');
ts.ADD(' <ProtectScenarios>False</ProtectScenarios>');
ts.ADD('</WorksheetOptions>');
ts.ADD('     </Worksheet>');
ts.ADD('    </Workbook>');
    return ts;
}

}