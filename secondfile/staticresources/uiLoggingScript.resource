if(window.performance){
    var processing = 0,pageLoadTime = 0,pageloadFromServer = 0;
    var sUsrAg = navigator.userAgent;
    var sBrowser = "";
    var pageAlreadyLoaded = '';
    
    if(sUsrAg.indexOf("Chrome") > -1) {
    	sBrowser = "Google Chrome";
    	} else if (sUsrAg.indexOf("Safari") > -1) {
    	sBrowser = "Apple Safari";
    	} else if (sUsrAg.indexOf("Opera") > -1) {
    	sBrowser = "Opera";
    	} else if (sUsrAg.indexOf("Firefox") > -1) {
    	sBrowser = "Mozilla Firefox";
    	} else if (sUsrAg.indexOf("MSIE") > -1) {
    	sBrowser = "Microsoft Internet Explorer";
    }

    function createLog(pageName){
//        console.log('********pageAlreadyLoaded***********',pageAlreadyLoaded);
//        console.log('*********pageName**********',pageName);
        if(pageAlreadyLoaded != pageName){
            pageAlreadyLoaded = pageName;
            var pageEntries = window.performance.timing;
            if(pageEntries){
                if(pageEntries.loadEventEnd > 0){ 
                    requestStartTime = pageEntries.requestStart - pageEntries.fetchStart;
                    latencyTime = pageEntries.responseEnd - pageEntries.requestStart;
                    processingTime = pageEntries.loadEventEnd - pageEntries.domLoading ;                
                    pageLoadTime = pageEntries.loadEventEnd - pageEntries.fetchStart;
                }      
                logCall(pageName);
            }            
        }
    }

    function logCall(pageName){
        uiLoggingController.savePerformanceMetrics(
            requestStartTime,latencyTime,processingTime,pageLoadTime,pageName,sBrowser,
            function(result, event) {
                if(event.type === 'exception') {
                    console.log('UI Logging Exception: event = ' + event);
                } else if(event.status) {
                    console.log('UI metrics Saved');
                } else {
                    console.log('UI Logging: event message = ' + event.message);
                }
            },
            {buffer: true, escape: true, timeout: 120000}
        );
    }    
}