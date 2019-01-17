$(document).ready( function () {
    //////////////////// FORM VALIDATION ///////////////
    $(window).keydown(function(event){
        if(event.keyCode == 13) {
          event.preventDefault();
          return false;
        }
    });
    // Intrusive Test Quick Val
    $(document).delegate(".intrusive-test","click", function () { 
        setTimeout(function () {
            ValidateFormElements(); 
        }, 700);
    });
    // -- Custom Validation for radio elements
    $(document).delegate("[type='radio'].required", "click", function () {      // Click event for radio elements
        var myName = $(this).attr("name");
        $("[name='"+myName+"']").each( function (){
            $(this).attr("blank-field","false");
        });
    });
    $(document).delegate(".required", "keyup", function () {                    // Keyup event on input fields
        ValidateFormElements($(this)) 
    });
    $(document).delegate("select.required", "change", function () {             // Change event on select elements
        ValidateFormElements($(this)) 
    });
    $(document).delegate(".wireline-or-mobility input","click", function (){
        setTimeout(function(){
            ValidateFormElements($(this));
        }, 400);
    });
/***************************************Form Logic Written in this area for all the Service Assurance forms******************************************/
    //Logic for showing default values for all the SC forms
    var originCont = $(".origin-cont").val();
    $(".origin").val(originCont);
    $("select").each( function () {
        $(this).val("none");
    });
    function defFormVals(){
        $(".country-felement").val("USA");
        $(".DisconnectItems").hide();
        $(".reason").attr("disabled","disabled");
        $(".showOrder").hide();
        $(".showCktId").hide();
        $("select.access-speed").prop("disabled","disabled");
        $(".Ethernet-Speed").hide();
        $(".form-container input:not([type='radio']), .form-container select, .form-container textarea").each( function (index, value) {
            $(this).attr("data-felement", $(this).siblings("label").text());
        });
        //Over write data-felement values in here
        $("input[type='radio'].required").attr("data-felement", "Product Type");
        $("input[type='radio']:not('.required')").attr("data-felement", "Authorized Intrusive Testing");
    }

    //Logic specific to SD for disabling smart button (validations)
    $(document).delegate("select.issue-type", "change", function(){
        var myIssue = $(this).val();
        if( myIssue != "Missed Order Number") {
            $(".order-num-container").show(300, function () {
                QuickValidate();
            });
        } else {
            $(".order-num-container").hide(300, function () {
                QuickValidate();
            });
        }
    });

    function QuickValidate() {
        // If no blank fields activate 'Confirm' button, else deactivate button
        if($("[blank-field='true']:visible").length > 0){
            $(".submitToConfirm-button")
                .attr("disabled","disabled")                        // Add disabled attribute
                .removeClass("submitToConfirm-button")              // Removes click event handle
                .addClass("submitToConfirm-button-disabled");       // Add styles for disabled button
        } else {
            $(".submitToConfirm-button-disabled")
                .removeAttr("disabled")                             // Removes disabled attribute
                .removeClass("submitToConfirm-button-disabled")     // Removes styles for disabled button
                .addClass("submitToConfirm-button");                // Add click event handle
        }
    };


    //Logic to show invoice field inputs
    $(document).delegate(".invoice-num-wireline", "change", function() {
        var myVal = $(this).val();
        var i;
        $(".gen-invoice-wireline").remove();
        for(i = myVal ; i > 0; i--) {
            $(".invoice-num-wireline").after("<div class='gen-invoice-wireline'><label>Invoice "+i+" Date </label><input class='date required' type='text' data-felement='Invoice Date "+i+"' placeholder='mm/dd/yyyy'/></div>");
        }
    });

    $(document).delegate(".invoice-num-mobility", "change", function() {
        var myVal = $(this).val();
        var i;
        $(".gen-invoice-mobility").remove();
        for(i = myVal ; i > 0; i--) {
            $(".invoice-num-mobility").after("<div class='gen-invoice-mobility'><label>Invoice "+i+" Number </label><input class='required' type='text' data-felement='Invoice "+i+" Number'/></div>");
        }
    });

    //Logic to show Issue related field regarding cancellation and disconnects
    $(document).delegate("select.issue-type", "change", function() {
        var issueChange = $(this).val();
        if (issueChange == "Cancellation") {
            $(".showOrder").show();
            $(".showCktId").hide();
        } else if (issueChange == "Disconnect") {
            $(".showCktId").show();
            $(".showOrder").hide();
        } else {
            $(".showCktId").hide();
            $(".showOrder").hide();
        }
    });

    //Logic to show wireline or mobility product forms related to SD
    $(document).delegate("select.product-felement", "change", function(){
        var myProduct = $(this).val();
        if(myProduct == "Select a Product") {
            $(".submitToConfirm-button").attr("disabled","disabled").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled"); //Added from previous version to disable confirm button in the initial load
            $(".mobility-selected, .mobility-takeout").hide(300);
            defFormVals();
        } else if(myProduct != "Mobility") {
            $(".submitToConfirm-button").attr("disabled","disabled").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled"); //Added from previous version to disable confirm button in the initial load
            $(".opportunity-id-container, .mobility-takeout").show(300);
            $(".mobility-selected").hide(300);
            defFormVals();
        } else if( myProduct == "Mobility" ) {
            $(".submitToConfirm-button").attr("disabled","disabled").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled"); //Added from previous version to disable confirm button in the initial load
            $(".opportunity-id-container, .mobility-takeout").hide(300);
            $(".mobility-selected").show(300);
            defFormVals();
        }
    });

    //Logic to trigger defFormVal function for adding data-felement
    $(document).delegate("select.mobility-felement", "change", function() {
        defFormVals();
    });

    //Logic to trigger defFormVal function when radio button is clicked to select the form
    $(document).delegate(".wireline-or-mobility", "click", function () {
        defFormVals();
    });


    //Logic to show/hide order number field based on Issue Type
    $(document).delegate("select.issue-type", "change", function(){
        var myIssue = $(this).val();
        if (myIssue == "none") {
            $(".reason").attr("disabled","disabled");
        } else {
            $(".reason").removeAttr("disabled");
            ValidateFormElements();
        }
        if (myIssue == "Cancellation") {
            $(".CancellationItems").val("none");
            $(".DisconnectItems").hide(300);
            $(".CancellationItems").show(300);
        } else if(myIssue == "Disconnect") {
            $(".DisconnectItems").val("none");
            $(".CancellationItems").hide(300);
            $(".DisconnectItems").show(300);
        }
    });

    //Logic to hide some fields on the form on Order number
    $(document).delegate(".order-num-container", "keyup", function(){
        var findOrdVal = $(".ordVal")[0];
            if (findOrdVal != undefined) {
            var textValCt = $(".ordVal").val().length;
            if (textValCt == 1 || textValCt > 1) {
                $(".orderToHide").hide(300);
                $(".ordVal").addClass("required");
                $(".ordVal").attr("data-felement", "Order Number");
                $(".ordVal").attr("blank-field", "false");
                ValidateFormElements();
            } else {
                $(".orderToHide").show(300);
                $(".ordVal").removeClass("required");
                ValidateFormElements();
            }   
        }
    });

    //Logic to enable Confirm button on form when there is no order number in the presence of oppt ID
    $(document).delegate(".ordVal", "keyup", function() {
        var findValOrdVal = $(".ordVal").val().length;
        if (findValOrdVal == 0) {
            var findValTxtVal = $(".txtVal").val().length;
            if (findValTxtVal > 0) {
                $(".submitToConfirm-button-disabled").removeAttr("disabled").addClass("submitToConfirm-button");
            }
        } else if (findValOrdVal > 5) {
            $(".submitToConfirm-button-disabled").removeAttr("disabled").addClass("submitToConfirm-button");
        } else if (findValOrdVal < 5) {
            $(".submitToConfirm-button").attr("disabled","disabled").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled");
        }
    });
    //Logic to all MACD fields
    $(document).delegate(".req-type", "change", function() {
        var findReqVal = $(".req-type").val();
        if (findReqVal != "none") {
            $(".req-type").attr("data-felement","Request Type");
        }
    });
    $(document).delegate(".attCktID", "keyup", function() {
        var attCktVal = $(".attCktID").val().length;
        if (attCktVal > 1) {
            $(".attCktID").attr("data-felement", "AT&amp;T Circuit ID");
        }
    });
    $(document).delegate(".live-traffic", "change", function() {
        var findLiveTraffic = $(".live-traffic").val();
        if (findLiveTraffic != "none") {
            $(".live-traffic").attr("data-felement", "Is there live traffic on this circuit?")
        }
    });
    $(document).delegate(".macd-desc", "keyup", function() {
        var checkDescr = $(".macd-desc").val().length;
        if (checkDescr > 1) {
            $(".macd-desc").attr("data-felement", "Description");
        }
    });
    //End of Logic to MACD fields
    //Logic to currency field
    $(document).delegate(".currency", "keyup", function () {
        var valNum = $(".currency").val();
        var check = /^[0-9]+\.?[0-9]*$/;
        if (check.test(valNum) == false) {
            valNum = valNum.substring(0, valNum.length -1);
            $(".currency").val(valNum);
        }
    });
    $(document).delegate(".currencyVal", "keyup", function () {
        var valNumM = $(".currencyVal").val();
        var check = /^[0-9]+\.?[0-9]*$/;
        if (check.test(valNumM) == false) {
            valNumM = valNumM.substring(0, valNumM.length -1);
            $(".currencyVal").val(valNumM);
        }
    });
    //Logic to Billing Forms
    //Initial form conditions
    //logic to identify first four digits to be 8002 or 8003
    $(document).delegate(".eBillAccNum","keyup",function(){
        var fieldVal = $(".eBillAccNum").val();
        var fieldValValid = fieldVal.substring(0,4);
        var findCurrentProd = $(".currentProd").val();
        if (fieldValValid == "") {
            $(".hiddenFields").hide(300);
            $(".hideForSpecialCondition").hide(300);
            $(".eBillButtonHide").show(300);
        } else if (fieldVal.length < 4) {
            $(".submitToConfirm-button").attr('disabled','disabled');
            return false;
        } else if ((fieldValValid == "8002" || fieldValValid == "8003") && fieldVal.length > 4 && findCurrentProd != "none") {
            $(".hiddenFields").show(300);
            $(".hideForSpecialCondition").hide(300);
            $(".eBillButtonHide").show(300);
            ValidateFormElements();
        } else if (((fieldValValid != "8002" || fieldValValid != "8003") && fieldVal.length > 4) && findCurrentProd == "ASE") {
            $(".hiddenFields").show(300);
            $(".hideForSpecialCondition").hide(300);
            ValidateFormElements();
            $(".eBillButtonHide").show(300);
        } else if (((fieldValValid != "8002" || fieldValValid != "8003") && fieldVal.length > 4) && findCurrentProd != "ASE" && findCurrentProd != "none") {
            $(".hiddenFields").hide(300);
            $(".hideForSpecialCondition").show(300);
            $(".eBillButtonHide").hide(300);
        } else {
            $(".hiddenFields").hide(300);
            $(".hideForSpecialCondition").hide(300);
            $(".eBillButtonHide").show(300);
        }
    });
    $(document).delegate("select.currentProd", "change", function() {
        var findCurrentProd = $(".currentProd").val();
        var fieldVal = $(".eBillAccNum").val();
        var fieldValValid = fieldVal.substring(0,4);
        if (findCurrentProd != "none" && ((fieldValValid == "8002" || fieldValValid == "8003") && fieldVal.length > 4)) {
            $(".showProductsEBill").show(300);
            $(".hiddenFields").show(300);
            $(".hideForSpecialCondition").hide(300);
            $(".eBillButtonHide").show(300);
        } else if (findCurrentProd == "ASE" && ((fieldValValid != "8002" || fieldValValid != "8003") && fieldVal.length > 4)) {
            $(".showProductsEBill").show(300);
            $(".hiddenFields").show(300);
            $(".hideForSpecialCondition").hide(300);
            $(".eBillButtonHide").show(300);
            ValidateFormElements();
        } else if (findCurrentProd != "ASE" && findCurrentProd != "none" && ((fieldValValid != "8002" || fieldValValid != "8003") && fieldVal.length > 4)){
            $(".showProductsEBill").show(300);
            $(".hiddenFields").hide(300);
            $(".hideForSpecialCondition").show(300);
            $(".eBillButtonHide").hide(300);
            ValidateFormElements();
        }  else {
            $(".hiddenFields").hide(300);
            $(".hideForSpecialCondition").hide(300);
            $(".eBillButtonHide").show(300);
        }
    });

    $(document).delegate(".showProductsEBill", "mouseover", function() {
        ValidateFormElements();
    });

    $(document).delegate(".wireline-or-mobility", "click", function () {
        if ($(".currentProd")) {
            $(".currentProd").val("none");
            $(".hideForSpecialCondition").hide();
        }
        if ($(".eBillButtonHide")) {
            $(".eBillButtonHide").show();
        }
        if ($(".hideGenSubmitButton")) {
            $(".hideGenSubmitButton").show();
        }
        if ($(".issue-type-gen")) {
            $(".issue-type-gen").hide(300);
            $(".currentProdGen").val("none");
            $(".issue-Type-Val").val("none");
            $(".desc-EGen").hide(300);
            $(".eGenLongText").hide(300);
        }
    });
    //EOL E Billing

    $(document).delegate(".orderToHide", "keyup", function(){
        var textValFields = $(".txtVal").val().length;
        if(textValFields ==1 || textValFields > 1) {
            $(".ordVal").removeClass("required");
            $(".ordVal").removeAttr("blank-field");
        } else {
            $(".ordVal").addClass("required");
            $(".ordVal").attr("data-felement", "Order Number");
        }
    });

    //Logic for Billing General
    $(document).delegate(".eGenAccNum", "keyup", function() {
        var eGenAccNum = $(".eGenAccNum").val();
        var eGenAccValidate = eGenAccNum.substring(0,4);
        var currentProdGen = $("select.currentProdGen").val();
        var currentIssueType = $(".issue-Type-Val").val();
        if (eGenAccNum.length < 4) {
            $(".submitToConfirm-button").attr('disabled','disabled');
            $(".showProductsEGen").hide(300);
            $(".issue-type-gen").hide(300);
            $(".desc-EGen").hide(300);
            $(".eGenLongText").hide(300);
        } else if (eGenAccNum.length > 4 && (eGenAccValidate == "8002" || eGenAccValidate == "8003")) {
            $(".desc-EGen").show(300);
            if (($(".Desc-Val-Gen").val().length > 1) && (eGenAccNum.length > 3)) {
                $(".submitToConfirm-button").removeAttr("disabled").removeClass("submitToConfirm-button-disabled");
            } else {
                $(".submitToConfirm-button").attr("disabled","disabled").addClass("submitToConfirm-button-disabled");
            }
            $(".showProductsEGen").hide(300);
            $(".issue-type-gen").hide(300);
            $(".eGenLongText").hide(300);
            $(".hideGenSubmitButton").show(300);

        } else if (eGenAccNum.length > 4 && (eGenAccValidate != "8002" || eGenAccValidate != "8003")) {
            $(".showProductsEGen").show(300);
            if (currentIssueType != "none" && currentProdGen != "ASE") {
                $("select.currentProdGen").val("none");
                $(".issue-Type-Val").val("none");
                $(".issue-type-gen").show(300);
                $(".desc-EGen").show(300);
                ValidateFormElements();
            } else {
                $(".issue-type-gen").hide(300);
                $(".desc-EGen").hide(300);
            }
            ValidateFormElements();
        } else {
            $(".showProductsEGen").hide(300);
            $(".issue-type-gen").hide(300);
            $(".desc-EGen").hide(300);
            $(".eGenLongText").hide(300);
        }
    });
    //Mandate check for general questions form to check the account number with length
    $(document).delegate(".desc-EGen", "keyup", function() {
        var eGenAccNumWithDesc = $(".eGenAccNum").val();
        if (eGenAccNumWithDesc.length < 5) {
            $(".submitToConfirm-button").attr('disabled','disabled');
        } else {
            ValidateFormElements();
        }
    });
    $(document).delegate("select.currentProdGen", "change", function() {
        var eGenAccNum = $(".eGenAccNum").val();
        var currentIssueType = $(".issue-Type-Val").val();
        var eGenAccValidate = eGenAccNum.substring(0,4);
        var currentProdGen = $(".currentProdGen").val();
        if (currentProdGen == "ASE" && (eGenAccValidate != "8002" || eGenAccValidate != "8003")) {
            $(".desc-EGen").show(300);
            $(".eGenLongText").hide(300);
            $(".issue-type-gen").hide(300);
            $(".hideGenSubmitButton").show(300);
            ValidateFormElements();
        } else if (currentProdGen != "ASE" && currentIssueType == "Other") {
            $(".issue-type-gen").show(300);
            $(".eGenLongText").show(300);
            $(".desc-EGen").hide(300);
            $(".hideGenSubmitButton").hide(300);
            ValidateFormElements();
        } else if (currentProdGen != "ASE" && currentIssueType != "Other" && currentIssueType != "none") {
            $(".issue-type-gen").show(300);
            $(".desc-EGen").show(300);
            $(".hideGenSubmitButton").show(300);
            $(".eGenLongText").hide(300);
            ValidateFormElements();
        } else{
            $(".desc-EGen").hide(300);
            $(".issue-type-gen").show(300);
            $(".hideGenSubmitButton").show(300);
        }
    });
    $(document).delegate(".issue-Type-Val", "change", function() {
        var currentIssueType = $(".issue-Type-Val").val();
        var currentProdGen = $(".currentProdGen").val();
        if (currentIssueType == "Other") {
            $(".desc-EGen").hide(300);
            $(".eGenLongText").show(300);
            $(".hideGenSubmitButton").hide(300);
        } else if (currentIssueType == "Other" && currentProdGen != "none"){
            $(".desc-EGen").hide(300);
            $(".eGenLongText").show(300);
            $(".hideGenSubmitButton").hide(300);
        } else if (currentIssueType == "none") {
            $(".desc-EGen").hide(300);
            $(".eGenLongText").hide(300);
            $(".hideGenSubmitButton").show(300);
            ValidateFormElements();
        } else{
            $(".desc-EGen").show(300);
            $(".eGenLongText").hide(300);
            $(".hideGenSubmitButton").show(300);
            ValidateFormElements();
        }
    });
    //EOL for General Billing Questions

    //Logic to show ethernet speed based on access type selection
    $(document).delegate("select.access-type", "change", function(){
        var myType = $(this).val()
        if ( myType == "T1") { 
            $("select.access-speed").removeAttr("disabled");
            $(".access-speed").val("none");
            $(".access-speed").show(300);
            $(".Ethernet-Speed").hide(300);
        }
        else if ( myType == "Ethernet") {
            $("select.Ethernet-Speed").removeAttr("disabled");
            $(".Ethernet-Speed").val("none");
            $(".access-speed").hide(300);
            $(".Ethernet-Speed").show(300); 
        }
        else if (myType == "none") {
            $(".access-speed").val("none");
            $(".access-speed").show(300);
            $(".Ethernet-Speed").hide(300);
            $("select.access-speed").prop("disabled","disabled");
        }
    });

    //Logic related to Billing forms for description container
    $(document).delegate(".what-problem", "change", function() {
        var myVal = $(this).val();
        if(myVal == "other") {
            $(".description-container").show(300);
        } else {
            $(".description-container").hide(300);
        }
    });

    //Logic to show up wireline forms
    $(document).delegate(".created-ticket","click",function(){
        if( $(this).is(":checked") ){
            $(".wireline-form-elements").show(300);
        } else{
            $(".wireline-form-elements").hide(300);
        }
    });

    //Intrusive Window Logic
    $(document).delegate(".intrusive-test input", "click", function(){
        var myVal = $(this).val();
        if( myVal == "Not Authorized" || myVal == "No"){
            $(".intrusive-test-container").show(300);
        } else{
            $(".intrusive-test-container").hide(300);
        }
    });

    //Radio Button Logic for Form to expand
    $(document).delegate(".wireline-or-mobility input", "click", function() {
        var myValue = $(this).val();
        if( myValue == "Wireline"){
            $(".wireline-container").show(300);
            $("#valSubmit").attr('disabled','disabled');
            $(".mobility-container").hide(300);
        } else if( myValue == "Mobility") {
            $(".wireline-container").hide(300);
            $(".mobility-container").show(300);
        }
    });

    //Logic to show up mobility drop down form content
    $(document).delegate(".mobility-trouble", "change", function(){
        var myTrouble = $(this).val();
        $(".mob-trbl").hide(300);
        $("."+myTrouble+"-container").show(300);
        $("#valSubmit").attr('disabled','disabled');
    });

    //Logic to show For drop down fields for Country when user selects "Other"
    $(document).delegate(".country-felement", "change", function(){
        var myVal = $(this).val();
        if(myVal == "other") {
            $(".country-other").show(300);
        } else {
            $(".country-other").hide(300);
            $(".country-other-felement").val("N/A");
        }
    });

    //Logic to disable smart button
    $(document).delegate(".wireline-or-mobility", "click", function(){
        $(".submitToConfirm-button").attr('disabled','disabled');
        setTimeout(function(){ disableEscSmartBtn() }, 800);
    });
    function disableEscSmartBtn() {
        $("#valSubmit").attr("disabled","disabled");
    };

    // Edit Button Click event - return to form
    $(document).delegate(".edit-button", "click", function() {
        $(".form-confirm-container .confirm").empty();
        $(".issue-type").removeAttr("multiple");
        $(".form-confirm-container").fadeOut(200, function () {
            $(".form-confirm-container .confirm").empty();
        });
        $(".form-container").delay(100).slideDown(300);
        $(".bcrumb.confirmation").removeClass("active-status");
        $(".bcrumb.complete-form").removeClass("completed").addClass("active-status");
        $(".confirm-button").removeAttr("disabled").text("Confirm and Submit");
    });

    //Logic for system access issues
    $(document).delegate(".portalForm", "change", function() {
        var currentPortalVal = $(this).val();
        if (currentPortalVal == "Training/Certification") {
            $(".issueList").show(300);
            $(".Training").show(300);
            $(".Quoting").hide(300);
            $(".GeneralSiteNavigation").hide(300);
            $(".MDFSysAccessIssue").hide(300);
            $(".showOnIssue").hide(300);
        } else if (currentPortalVal == "Quoting/Ordering") {
            $(".issueList").show(300);
            $(".Training").hide(300);
            $(".Quoting").show(300);
            $(".GeneralSiteNavigation").hide(300);
            $(".MDFSysAccessIssue").hide(300);
            $(".showOnIssue").hide(300);
        } else if (currentPortalVal == "General Site Navigation") {
            $(".issueList").show(300);
            $(".Training").hide(300);
            $(".Quoting").hide(300);
            $(".GeneralSiteNavigation").show(300);
            $(".MDFSysAccessIssue").hide(300);
            $(".showOnIssue").hide(300);
        } else if (currentPortalVal == "Development Funds (MDF/IDF)") {
            $(".issueList").show(300);
            $(".Training").hide(300);
            $(".Quoting").hide(300);
            $(".GeneralSiteNavigation").hide(300);
            $(".MDFSysAccessIssue").show(300);
            $(".showOnIssue").hide(300);
        } else if (currentPortalVal == "Other") {
            $(".issueList").hide(300);
            $(".Training").hide(300);
            $(".Quoting").hide(300);
            $(".GeneralSiteNavigation").hide(300);
            $(".MDFSysAccessIssue").hide(300);
            $(".showOnIssue").show(300);
            ValidateFormElements();
        } else {
            $(".issueList").hide(300);
            $(".Training").hide(300);
            $(".Quoting").hide(300);
            $(".GeneralSiteNavigation").hide(300);
            $(".MDFSysAccessIssue").hide(300);
            $(".showOnIssue").hide(300);
        }
    });
    $(document).delegate(".Training", "change", function() {
        var trainingVal = $(this).val();
        if (trainingVal != "none") {
            $(".showOnIssue").show(300);
            ValidateFormElements();
        } else {
            $(".showOnIssue").hide(300);
        }
    });
    $(document).delegate(".Quoting", "change", function() {
        var trainingVal = $(this).val();
        if (trainingVal != "none") {
            $(".showOnIssue").show(300);
            ValidateFormElements();
        } else {
            $(".showOnIssue").hide(300);
        }
    });
    $(document).delegate(".GeneralSiteNavigation", "change", function() {
        var trainingVal = $(this).val();
        if (trainingVal != "none") {
            $(".showOnIssue").show(300);
            ValidateFormElements();
        } else {
            $(".showOnIssue").hide(300);
        }
    });
    $(document).delegate(".MDFSysAccessIssue", "change", function() {
        var trainingVal = $(this).val();
        if (trainingVal != "none") {
            $(".showOnIssue").show(300);
            ValidateFormElements();
        } else {
            $(".showOnIssue").hide(300);
        }
    });
    $(document).delegate(".MDFSysAccessIssue", "change", function() {
        var trainingVal = $(this).val();
        if (trainingVal != "none") {
            $(".showOnIssue").show(300);
            ValidateFormElements();
        } else {
            $(".showOnIssue").hide(300);
        }
    });
    $(document).delegate(".systemAccessIssueBusinessDirect", "change", function() {
        var currentAppVal = $(this).val();
        if (currentAppVal == "Order Status Manager") {
            $(".issueSysAccess").show(300);
            $(".eBillSystemAccessIssue").hide(300);
            $(".eMaintenanceSystemAccessIssue").hide(300);
            $(".OrderStatusManager").show(300);
            $(".otherEbillSystemAccess").hide(300);
            $(".otherEbillSystemAccessCheck").hide(300);
            $(".eMaintenanceOther").hide(300);
            $(".eMaintenanceOtherPassword").hide(300);
            ValidateFormElements();
            $(".form-buttons").show(300);
        } else if (currentAppVal == "eBill") {
            $(".issueSysAccess").show(300);
            $(".eBillSystemAccessIssue").show(300);
            $(".eMaintenanceSystemAccessIssue").hide(300);
            $(".OrderStatusManager").hide(300);
            $(".otherEbillSystemAccess").hide(300);
            $(".otherEbillSystemAccessCheck").hide(300);
            $(".eMaintenanceOther").hide(300);
            $(".eMaintenanceOtherPassword").hide(300);
            ValidateFormElements();
            $(".form-buttons").show(300);
        } else if (currentAppVal == "eMaintenance") {
            $(".issueSysAccess").show(300);
            $(".eBillSystemAccessIssue").hide(300);
            $(".eMaintenanceSystemAccessIssue").show(300);
            $(".OrderStatusManager").hide(300);
            $(".otherEbillSystemAccess").hide(300);
            $(".otherEbillSystemAccessCheck").hide(300);
            $(".eMaintenanceOther").hide(300);
            $(".eMaintenanceOtherPassword").hide(300);
        }
    });
    $(document).delegate(".OrderStatusManager", "change", function() {
        var currentOrderStatVal = $(this).val();
        if (currentOrderStatVal != "none") {
            $(".otherEbillSystemAccessCheck").show(300);
            ValidateFormElements();
        } else {
            $(".otherEbillSystemAccessCheck").hide(300);
            ValidateFormElements();
        }
    });
    $(document).delegate(".eBillSystemAccessIssue", "change", function() {
        var currentEBillVal = $(this).val();
        if (currentEBillVal == "Other") {
            $(".otherEbillSystemAccessCheck").hide(300);
            $(".submitToConfirm-button").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled");
            $(".submitToConfirm-button-disabled").attr("disabled", "disabled");
            $(".otherEbillSystemAccess").show(300);
            if ($('input.checkbox_Ebill_check').is(':checked')) {
                $("input.checkbox_Ebill_check").prop("checked", false);
            }
        } else if (currentEBillVal != "Other") {
            $(".otherEbillSystemAccess").hide(300);
            $(".otherEbillSystemAccessCheck").show(300);
            ValidateFormElements();
        }
    });
    $(document).delegate("input.checkbox_Ebill_check", "click", function() {
         if ($('input.checkbox_Ebill_check').is(':checked')) {
            $(".otherEbillSystemAccessCheck").show(300);
            ValidateFormElements();
        } else {
            $(".userNameEbill").val("");
            ValidateFormElements();
            $(".otherEbillSystemAccessCheck").hide(300);
            $(".submitToConfirm-button").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled");
            $(".submitToConfirm-button-disabled").attr("disabled", "disabled");
        }  
    });
    $(document).delegate(".eMaintenanceSystemAccessIssue", "change", function() {
        var currentEMaintenanceVal = $(this).val();
        if (currentEMaintenanceVal == "Forgot username") {
            $(".otherEbillSystemAccessCheck").hide(300);
            $(".eMaintenanceOther").show(300);
            $(".form-buttons").hide(300);
        } else {
            $(".eMaintenanceOther").hide(300);
            $(".form-buttons").show(300);
            $(".otherEbillSystemAccessCheck").hide(300);
        }
        if (currentEMaintenanceVal == "Forgot password") {
            $(".eMaintenanceOtherPassword").show(300);
            $(".eMaintenanceOther").hide(300);
            $(".form-buttons").hide(300);
            $(".otherEbillSystemAccessCheck").hide(300);
        } else {
            $(".eMaintenanceOtherPassword").hide(300);
            $(".otherEbillSystemAccessCheck").hide(300);
        }
        if (currentEMaintenanceVal == "Other" || currentEMaintenanceVal == "Request access") {
            $(".otherEbillSystemAccessCheck").show(300);
            ValidateFormElements();
            $(".form-buttons").show(300);
            $(".submitToConfirm-button").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled");
            $(".submitToConfirm-button-disabled").attr("disabled", "disabled");
        } else {
            $(".otherEbillSystemAccessCheck").hide(300);
            ValidateFormElements();
        }
    });
    $(document).delegate(".appSysAccessMP", "change", function() {
        var sysMP = $(this).val();
        if (sysMP == "Premier") {
            $(".premierSysAccess").show(300);
            $(".phoenixSysAccess").hide(300);
            $(".hidePerIssue").hide(300);
        } else if (sysMP == "Phoenix") {
            $(".phoenixSysAccess").show(300);
            $(".premierSysAccess").hide(300);
            $(".hidePerIssue").hide(300);
        } else {
            $(".premierSysAccess").hide(300);
            $(".phoenixSysAccess").hide(300);
            $(".hidePerIssue").hide(300);
        }
    });
    $(document).delegate(".checkForCheckBoxCheck", "click", function() {
        ValidateFormElements();
    });
    $(document).delegate(".phoenixSysAccess", "change", function() {
        var myPhoenixSysVal = $(this).val();
        if (myPhoenixSysVal != "none") {
            $(".hidePerIssue").show(300);
        } else {
            $(".hidePerIssue").hide(300);
        }
    });
    $(document).delegate(".premierSysAccess", "change", function() {
        var myPremierSysVal = $(this).val();
        if (myPremierSysVal != "none") {
            $(".hidePerIssue").show(300);
        } else {
            $(".hidePerIssue").hide(300);
        }
    });
/*************************************End of form logic****************************************/


    // Number format validation
    $(document).delegate(".number", "keyup", function () {
        var myNumValCheck = $(this).val();
        if( isNaN(myNumValCheck) ) {
            $(".error").remove();
            $(this).after("<div class='error'>only numeric values can be entered</div>");
        } 
        else { $(".error").remove(); }
    });


    // Date Validation
    $(document).delegate(".date", "blur", function () {
        var myVal = $(this).val();
        var first = myVal.substring(0, myVal.indexOf('/'));
        var second = myVal.substring(3, myVal.indexOf('/1'));   
        var alphaCheck = $(".date").val().match(/[a-z]/g);
        $(this).val(myVal.replace(/\s/g, ''));
        if(first > 12 || second >31 || alphaCheck) {
            $(".date-error").remove();
            $(this).after("<div class='error date-error'>Invalid Date</div>");
        } 
        else { $(".date-error").remove(); }
        QuickVal();
    });
    
    // Currency Formatting on confirmation request
    $(document).delegate(".submitToConfirm-button", "mousedown", function () {
        $(".currency").each( function () {
            var val = parseFloat($(this).val().replace("$","").replace(",",""));
            $(this).val(val.toFixed(2));
        });
    });

    $(document).delegate(".email-addr-inputSp", "keyup", function(){
        var speValue = $(this).val();
        var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
        var patternVal = pattern.test(speValue);
        if (!patternVal){
            $("#EmailError").remove();
            $(".email-addr-inputSp").after("<p id='EmailError' class='errorText'></p>" ); //Please enter a valid email
            ValidateFormElements($(this));
        } else {
            $('#EmailError').remove();
            ValidateFormElements($(this));
        }
    });

    $(document).delegate(".email-addr-minputSp", "keyup", function(){
        var speValue = $(this).val();
        var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
        var patternVal = pattern.test(speValue);
        if (!patternVal){
            $("#EmailError").remove();
            $(".email-addr-inputSp").after("<p id='EmailError' class='errorText'></p>" ); //Please enter a valid email
            ValidateFormElements($(this));
        } else {
            $('#EmailError').remove();
            ValidateFormElements($(this));
        }
    });

    $(document).delegate(".email-addr-inputASP", "keyup", function(){
        var speValue = $(this).val();
        var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
        var patternVal = pattern.test(speValue);
        if (!patternVal){
            $("#EmailError").remove();
            $(".email-addr-inputSp").after("<p id='EmailError' class='errorText'></p>" ); //Please enter a valid email
            ValidateFormElements($(this));
        } else {
            $('#EmailError').remove();
            ValidateFormElements($(this));
        }
    });

    $(document).delegate(".email-addr-minputASP", "keyup", function(){
        var speValue = $(this).val();
        var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
        var patternVal = pattern.test(speValue);
        if (!patternVal){
            $("#EmailError").remove();
            $(".email-addr-inputSp").after("<p id='EmailError' class='errorText'></p>" ); //Please enter a valid email
            ValidateFormElements($(this));
        } else {
            $('#EmailError').remove();
            ValidateFormElements($(this));
        }
    });

    function ValidateFormElements($my) {
        // -- Blank Fields either true or false
        $(".required:visible:not('.intrusive-check')").each( function(){
            var myVal           = $(this).val();
            var intrusiveElem1  = $(".intrusive-test input:eq(0)").is(":checked");
            var intrusiveElem2  = $(".intrusive-test input:eq(1)").is(":checked");
            if($(".intrusive-check").length > 0){
                //Validates Intrusive test 
                if(!intrusiveElem1 && !intrusiveElem2){
                    $(".intrusive-check").attr("blank-field","true");
                }else {
                    $(".intrusive-check").attr("blank-field","false");
                }
            }
            if(myVal == "" || myVal == "none") {
                $(this).attr("blank-field", "true");
            } else {
                $(this).attr("blank-field", "false");
            }
        });

        // If no blank fields activate 'Confirm' button, else deactivate button
        var blank = $("[blank-field='true']:visible").length;
        var err = $(".errorText").length;
        if($("[blank-field='true']:visible").length > 0  || $(".errorText").length > 0){
            $(".submitToConfirm-button")
                .attr("disabled","disabled")                        // Add disabled attribute
                .removeClass("submitToConfirm-button")              // Removes click event handle
                .addClass("submitToConfirm-button-disabled");       // Add styles for disabled button
        } else {
            $(".submitToConfirm-button-disabled")
                .removeAttr("disabled")                             // Removes disabled attribute
                .removeClass("submitToConfirm-button-disabled")     // Removes styles for disabled button
                .addClass("submitToConfirm-button");                // Add click event handle
        }
    }
    //////////////////// END FORM VALIDATION ///////////////

    // SUBMIT BUTTON CLICK EVENT - Transition to "Confirmation" page
    $(document).delegate(".submitToConfirm-button", "click", function (){
        $("html, body").animate({
            scrollTop: "0px"
        }, 200);
        $(".complete-form .bcrumb-text").text("Form Completed");
        $(".complete-form").addClass("completed");
        $(".active-status").removeClass("active-status");
        $(".confirmation").addClass("active-status");
        //Generate information to review
        $(".form-container input[type='text']:visible:not('.internal, .submit-button'), .form-container input[type='radio']:checked:visible:not('.internal, .submit-button'), .form-container textarea:visible:not('.internal'), .form-container select:visible:not('.internal') ").each( function (index, value) {
            $(".form-confirm-container .confirm").append('<div class="content"><label>'+$(this).attr("data-felement")+'</label>: <span>'+$(this).val()+'</span> '); //<span class="change">change</span></div>
        });

        //Clear all hidden fields
        $(".form-container input:hidden:not('.internal, [type=hidden]'), .form-container textarea:hidden:not('.internal'), .form-container select:hidden:not('.internal') ").each( function (index, value) {
            if($(this).is("select")){
                $(this).val("none");
            } else {
                $(this).val("");
            }
        });
        $(".form-container").fadeOut(200);
        $(".form-confirm-container").slideDown(300);
    });

    // TOPIC CLICK EVENT - Transition to categories
    $(".topic").click(function () {
        var myName = $(this).find(".subject-title").text();
        var myCategories = $(this).attr("data-categories") 
        topic = $(this).attr("data-map");
        $(".topic-field").val(topic);
        $(".topic-bcrumb .bcrumb-text").text(myName);
        $(".topic-bcrumb").addClass("completed");
        $(".active-status").removeClass("active-status");
        $(".category-bcrumb").addClass("active-status");
        $(".subject-container").fadeOut(200);
        $(".subject-sub-container").slideDown(300, function (){
        $(".categories-container").empty();
            var ua = window.navigator.userAgent;
            var findMyBrowser = ua.indexOf("IE");
            if (findMyBrowser > 0) {
            var dataFrom = "/apex/"+myCategories+"";
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                var dataReceived = xhttp.responseText;
                var htmlToParse = $.parseHTML(dataReceived);
                $(".categories-container").append(htmlToParse);
            };
            xhttp.open("GET", myCategories, true);
            xhttp.send();
            } else {
                $(".categories-container").load("/apex/"+myCategories+"");
            }
        });
    })

    $(document).delegate(".form-buttons .btn:contains('Cancel')", "click", function () {
        $(".category-bcrumb .bcrumb-text").text("Choose a Category");
        $(".subject-container").delay(200).fadeIn(400);
        $(".form-container, .form-confirm-container").slideUp(300);
        $(".form-confirm-container .confirm, .form-container").empty();
        $(".bcrumb.category-bcrumb, .bcrumb.complete-form, .bcrumb.topic-bcrumb").removeClass("completed");
        $(".bcrumb.topic-bcrumb").addClass("active-status");
        $(".bcrumb.topic-bcrumb .bcrumb-text").text("Choose a Topic");
        $(".bcrumb.complete-form .bcrumb-text").text("Complete the Form");
        $(".bcrumb.complete-form, .bcrumb.confirmation").removeClass("active-status");
    });

    // Show Additional Info - mouseover event
    $(".topic").mouseover( function () {
        $(this).find(".slide-desc").addClass("desc-active");
    })

    // Hide Additional Info - mouseover event
    .mouseout( function () {
        $(this).find(".slide-desc").removeClass("desc-active"); 
    });

    // CATEGORY CLICK EVENT - Transition to Form
    $(document).delegate(".category", "click", function () {
        var myName = $(this).find(".subject-title").text();
        var myPage = $(this).attr("data-page");
        category = $(this).attr("data-map");
        subject = topic + "-" + category;
        $(".form-container").empty();

        /******************Logic for Forms to support IE****************************/
        //var formFrom = "/apex/"+myPage+"";
        var ua = window.navigator.userAgent;
        var findMyBrowser = ua.indexOf("IE");
            if (findMyBrowser > 0) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function() {
                var formReceived = xhttp.responseText;
                var formToParse = $.parseHTML(formReceived);
                $(".form-container").append(formToParse);
                //$('[data-toggle="tooltip"]').tooltip();  // Activate help-text
                //Logic to add product dynamically to the backend
                $(".topic-field").val(topic);
                $(".category-field").val(category);
                $(".subject-field").val(subject);
                $(".product-field").val("Mobility");
                if($("form .required").length > 0){
                    $(".submitToConfirm-button").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled");
                    $(".submitToConfirm-button-disabled").attr("disabled", "disabled");
                }
                setTimeout(function(){
                    $("table.required").find("input").addClass("required").attr("blank-field","true");
                    $("table.required").removeClass("required");
                }, 500);
            };
            xhttp.open("GET", myPage, true);
            xhttp.send();
            } else {
                $(".form-container").load("/apex/"+myPage+"", function () {
                //$('[data-toggle="tooltip"]').tooltip();  // Activate help-text
                $(".topic-field").val(topic);
                $(".category-field").val(category);
                $(".subject-field").val(subject);
                $(".product-field").val("Mobility");
                if($("form .required").length > 0){
                    $(".submitToConfirm-button").removeClass("submitToConfirm-button").addClass("submitToConfirm-button-disabled");
                    $(".submitToConfirm-button-disabled").attr("disabled", "disabled");
                }
                setTimeout(function(){
                    $("table.required").find("input").addClass("required").attr("blank-field","true");
                    $("table.required").removeClass("required");
                }, 500);
                });
            }
        $(".category-field").val(category);
        $(".related-topic, .quick-answers").each( function () {
            $(this).text(myName);
        });
        // $(".topic-form-title").html($(".bcrumb.topic-bcrumb").text()  + " <i class='form-title-icon ionicons ion-ios-arrow-forward'></i> " + myName + " form");
        $(".bcrumb.category-bcrumb").addClass("completed");
        $(".bcrumb.category-bcrumb .bcrumb-text").text(myName);
        $(".active-status").removeClass("active-status");
        $(".bcrumb.complete-form").addClass("active-status");
        $(".subject-sub-container").fadeOut(200);
        $(".form-container, .escalations-form").slideDown(300);
    });

    // SUB LEVEL CLICK EVENT - Transition to Order Status Form
    $(".order-status-sub").click(function () {
        var myName = $(this).find(".subject-title").text();
        $(".related-topic, .quick-answers").each( function () {
            $(this).text(myName);
        });
        // $(".topic-form-title").html($(".bcrumb.topic-bcrumb").text()  + " <i class='form-title-icon ionicons ion-ios-arrow-forward'></i> " + myName + " form");
        $(".bcrumb.category-bcrumb").addClass("completed");
        $(".bcrumb.category-bcrumb .bcrumb-text").text(myName);
        $(".active-status").removeClass("active-status");
        $(".bcrumb.complete-form").addClass("active-status");
        $(".subject-sub-container").fadeOut(200);
        $(".form-container, .order-status-form").slideDown(300);
    });

    // Back Link from sub level content - Return to top level selection list
    $(".back-link").click(function () {
        $(".topic-bcrumb .bcrumb-text").text("Choose a Topic");
        $(".categories-container").empty();
        $(".subject-container").delay(200).fadeIn(400);
        $(".subject-sub-container").slideUp(300);
        $(".bcrumb").removeClass("completed").removeClass("active-status");
        $(".bcrumb.topic-bcrumb").addClass("active-status");
    });

    // Back Link from form - Return to sub level selection list
    $(document).delegate(".form-back-link", "click", function () {
        $(".category-bcrumb .bcrumb-text").text("Choose a Category");
        $(".subject-sub-container").delay(200).fadeIn(400);
        $(".form-container").slideUp(300);
        $(".bcrumb.category-bcrumb").removeClass("completed").addClass("active-status");
        $(".bcrumb.complete-form, .bcrumb.confirmation").removeClass("active-status");
        $(".bcrumb.complete-form").removeClass("completed");
    });

    $(document).delegate(".edit-button", "click", function () {
        $(".complete-form .bcrumb-text").text("Complete the Form");
    });

    $(document).delegate(".country-felement", "change", function () {
        var myVal = $(this).val();
        if (myVal == "USA") {
            $("[data-felement='State']").siblings("label").show(300);
            $("[data-felement='State']").show(300, function () {
                QuickVal();
            });
        } else {
            $("[data-felement='State']").siblings("label").hide(300);
            $("[data-felement='State']").hide(300, function () {
                QuickVal();
            });
        }
    });

    function QuickVal() {
        // If no blank fields activate 'Confirm' button, else deactivate button
        if($("[blank-field='true']:visible").length > 0  || $(".error").length > 0){
            $(".submitToConfirm-button")
                .attr("disabled","disabled")                        // Add disabled attribute
                .removeClass("submitToConfirm-button")              // Removes click event handle
                .addClass("submitToConfirm-button-disabled");       // Add styles for disabled button
        } else {
            $(".submitToConfirm-button-disabled")
                .removeAttr("disabled")                             // Removes disabled attribute
                .removeClass("submitToConfirm-button-disabled")     // Removes styles for disabled button
                .addClass("submitToConfirm-button");                // Add click event handle
        }
    }

    //final submit button, added from form to make submit button work on IE.
    $(".hideMe").hide();
    $(document).delegate(".confirm-button", "click", function() {
        var currentBrowser = window.navigator.userAgent;
        var findMyBrowser = currentBrowser.indexOf("IE");
        if (findMyBrowser > 1) {
            $(".user_badge").remove();
            $(".submit-button").click();
            $(".confirm-button").attr("disabled","disabled");
            window.location('/apex/Support_Center_TY?caseId='+caseNumber);
        } else {
            $(".user_badge").remove();
            $(".submit-button").click();
            $(".confirm-button").attr("disabled","disabled").text("Please wait...");
        }
    });
});