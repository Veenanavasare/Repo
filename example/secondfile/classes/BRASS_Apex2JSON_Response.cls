/************************************************************************************** 
 Apex global global class Name     : BRASS_Apex2JSON_Response
 Version             : 1.0 
 Created Date        : 20 NOV 2014
 Function            : This global global class handles the state for BRASS Response Bean
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sunil Kumar       11/20/2014             Original Version
*************************************************************************************/
global with sharing  class BRASS_Apex2JSON_Response extends ATTServiceInfoBean{
    
    global String ConversationID;	//0.6740779602638927-null-1313 disneyland dr 16anaheimca92802
	global cls_PreQualify_Response PreQualify_Response;
	
	global class cls_PreQualify_Response {
		global cls_Return_Code Return_Code;
		global cls_CSI_Address_Info CSI_Address_Info;
		global cls_ProductQualificationResults[] ProductQualificationResults;
		global cls_GeoCode_Result GeoCode_Result;
		global String Dry_Loop_Ind;	//N
		global cls_Error_Info Error_Info;
	}
	global class cls_Return_Code {
		global String Return_Code;	//00
	}
	global class cls_CSI_Address_Info {
		global String StreetName;	//DISNEYLAND
		global String streetNumberPrefix;	//
		global String streetNumber;	//1313
		global String streetNumberSuffix;	//
		global String streetDirection;	//S
		global String streetType;	//DR
		global String City;	//ANH
		global String State;	//CA
		global String PostalCode;	//92802
		global String PostalCodePlus4;	//
		global String streetTrailingDirection;	//
		global String assignedStreetNumber;	//
		global String RateZoneBandCode;	//803
		global String AddressId;	//M5da10db1b
		global String LegalEntity;	//PC00
		global String BuildingType;	//N
		global String tarCode;	//047
		global String rateCenterCode;	//ANAHEIM
		global String exchangeCode;	//ANH
		global String primaryNpaNxx;	//714520
		global String Clli8;	//ANHMCA01
		global String videoHubOffice;	//IRV2CA
		global String lastDisconnectTransportType;	//
		global String smartMoves;	//N
	}
	global class cls_ProductQualificationResults {
		global String ProductName;	//HSIABASIC(.768)
		global String QualificationResultCode;	//Y
		global cls_NetworkTypeGroup NetworkTypeGroup;
	}
	global class cls_NetworkTypeGroup {
		global String NetworkType_Count;	//1
		global String NetworkType1;	//IP-CO
		global String Exhaust_Code1;	//
		global String Primary_RTID1;	//
		global String Secondary_RTID1;	//
		global String SubTransport_Frequency_17MHz_Indicator1;	//
		global String SubTransport_Vectoring_Indicator1;	//
		global String SubTransport_Bandwidth_Indicator1;	//
		global String NetworkType2;	//
		global String Exhaust_Code2;	//
		global String Primary_RTID2;	//
		global String Secondary_RTID2;	//
		global String SubTransport_Frequency_17MHz_Indicator2;	//
		global String SubTransport_Vectoring_Indicator2;	//
		global String SubTransport_Bandwidth_Indicator2;	//
	}
	global class cls_GeoCode_Result {
		global String Result;	//Altered_Address
		global cls_GeoCode_Details[] GeoCode_Details;
	}
	global class cls_GeoCode_Details {
		global String GeoCode;	//
		global cls_Address Address;
	}
	global class cls_Address {
		global String Street1;	//1313 S DISNEYLAND DR
		global String Street2;	//
		global String City;	//Anaheim
		global String State;	//CA
		global String Zip;	//92802
		global String Telephone;	//9085551234
	}
	global class cls_Error_Info {
		global String Error_Code;	//
		global String Error_Message;	//
	}

    
    
/*    
	global String ConversationID;	//0012
	global cls_PreQualify_Response PreQualify_Response;

 	global global class cls_PreQualify_Response{
		global cls_Return_Code Return_Code;
		global cls_GeoCode_Result GeoCode_Result;
		global String Dry_Loop_Ind;	//
		global cls_Error_Info Error_Info;
	}
	global global class cls_Return_Code {
		global String Return_Code;	//00
	}
	global global class cls_GeoCode_Result {
		global String Result;	//Alternate_Address
		global cls_GeoCode_Details[] GeoCode_Details;
	}
	global global class cls_GeoCode_Details {
		global String GeoCode;	//
		global cls_Address Address;
	}
	global global class cls_Address {
		global String Street1;	//1809 MC HENRY AV 
		global String Street2;	//SUIT D 
		global String City;	//MDSTO
		global String State;	//CA
		global String Zip;	//95350
		global String Telephone;	//9085551234
	}
	global global class cls_Error_Info {
		global String Error_Code;	//
		global String Error_Message;	//
	}

*/

/*
    global String ConversationID;
    global PreQualify_Response PreQualify_Response;
    global global global class PreQualify_Response {
        global Return_Code Return_Code;
        global CSI_Address_Info CSI_Address_Info;
        global ProductQualificationResults[] ProductQualificationResults;
        global GeoCode_Result GeoCode_Result;
        global String Dry_Loop_Ind; 
        global Error_Info Error_Info;
    }
    global global global class Return_Code {
        global String Return_Code;
    }
    global global global class CSI_Address_Info {
        global String StreetName;
        global String streetNumberPrefix;
        global String streetNumber;
        global String streetNumberSuffix;
        global String streetDirection;
        global String streetType;
        global String City;
        global String State;
        global String PostalCode;
        global String PostalCodePlus4;
        global String streetTrailingDirection;
        global String assignedStreetNumber;
        global String RateZoneBandCode;
        global String AddressId;
        global String LegalEntity;
        global String BuildingType;
        global String tarCode;
        global String rateCenterCode;
        global String exchangeCode;
        global String primaryNpaNxx;
        global String Clli8;
        global String videoHubOffice;
        global String lastDisconnectTransportType;
        global String smartMoves;
    }
    global global global class ProductQualificationResults {
        global String ProductName;
        global String QualificationResultCode;
        global NetworkTypeGroup NetworkTypeGroup;
    }
    global global global class NetworkTypeGroup {
        global String NetworkType_Count;
        global String NetworkType1;
        global String Exhaust_Code1;
        global String Primary_RTID1;
        global String Secondary_RTID1;
        global String SubTransport_Frequency_17MHz_Indicator1;
        global String SubTransport_Vectoring_Indicator1;
        global String SubTransport_Bandwidth_Indicator1;
        global String NetworkType2; 
        global String Exhaust_Code2;
        global String Primary_RTID2;
        global String Secondary_RTID2;
        global String SubTransport_Frequency_17MHz_Indicator2;
        global String SubTransport_Vectoring_Indicator2;
        global String SubTransport_Bandwidth_Indicator2;
    }
    global global global class GeoCode_Result {
        global String Result;
        global List<GeoCode_Details> GeoCode_Details;
    }
    global global global class GeoCode_Details {
        global String GeoCode;
        global Address Address;
    }
    global global global class Address {
        global String Street1;
        global String Street2;
        global String City;
        global String State;
        global String Zip;
        global String Telephone;
    }
    global global global class Error_Info {
        global String Error_Code;
        global String Error_Message;
    }
    */
}