//Generated by wsdl2apex

public class edbAttComDppcoCustomerqueryV2 {
    public class CustomerReadResponse_element {
        public cioAttComCommonheaderV3.WSResponseHeader_element WSResponseHeader;
        public edbAttComDppcoCommonV2.CustomerDataType[] Customer;
        private String[] WSResponseHeader_type_info = new String[]{'WSResponseHeader','http://cio.att.com/commonheader/v3','WSResponseHeader_element','0','1','false'};
        private String[] Customer_type_info = new String[]{'Customer','http://edb.att.com/dppco/Common/v2','CustomerDataType','0','100','false'};
        private String[] apex_schema_type_info = new String[]{'http://edb.att.com/dppco/CustomerQuery/v2','true','false'};
        private String[] field_order_type_info = new String[]{'WSResponseHeader','Customer'};
    }
    public class CustomerReadRequest_element {
        public cioAttComCommonheaderV3.WSHeader_element WSHeader;
        public edbAttComDppcoCommonV2.CustomerDataType Customer;
        private String[] WSHeader_type_info = new String[]{'WSHeader','http://cio.att.com/commonheader/v3','WSHeader_element','1','1','false'};
        private String[] Customer_type_info = new String[]{'Customer','http://edb.att.com/dppco/Common/v2','CustomerDataType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://edb.att.com/dppco/CustomerQuery/v2','true','false'};
        private String[] field_order_type_info = new String[]{'WSHeader','Customer'};
    }
}