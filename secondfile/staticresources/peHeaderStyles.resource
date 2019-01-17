        a {text-decoration: none;}

        .accessError {
            color:#333;
            padding-left:25px;
            padding-bottom:20px;
            padding-top:25px;
            font-size: 2.3em;
        }
        
        .access-training {
            border-top:1px #333 solid;
        }

        .accessModalContainer {
            margin-top:10%;
            height:350px;
            width:600px;
        }

		.aMustacheIconA {
			margin-top:-17px; 
			margin-left:-15px; 
			position:absolute;
		}
		
		.aMustacheIconB {
			margin-top:-20px; 
			margin-left:-15px; 
			position:absolute; 
			width:112px;
		}
    
        .begin_quote_btn {
            background: none repeat scroll 0% 0% #056FAB;
            border: 0px none;
            color: #FFF;
            font-family: clearviewattlight;
            font-size: 0.875em;
            left: 5px;
            line-height: 40px;
            margin-top: 6px !important;
            padding: 1px 12px 0px;
            position: relative;
            transition: #000 0.2s ease-in-out 0s;
            -webkit-transition:background 0.2s ease-in-out;
            -ms-transition:background 0.2s ease-in-out;
            -o-transition:background 0.2s ease-in-out;
            transition:background 0.2s ease-in-out;
            -webkit-border-radius:3px;
            border-radius: 3px;
			font-weight: normal;
        }

        .begin_quote_btn:after {
            content:"";
            display:table;
            clear:both
        }

        .begin_quote_btn:hover {
            background:#3bc1f4;
        }

        .begin_quote_btnID {background-color: #eee;}

        .begin_quote_icon {
            background-position: -10px -80px;
            float: left;
            height: 34px !important;
            margin: 0;
            padding: 0; 
            width: 30px !important;
        }
        
        .disabledP {
        	color:#74A4C5;
        	cursor:default;
        }

        .link-section {margin-right: 0 !important;}

        /*for transfer to another css or styles that needed a parent div class*/
        .modal.modal-wide .modal-dialog {width:90%;}
        .modal-header{border-bottom : none !important;}
        .modal-footer{border-top : none !important;}

        .navbar-header {margin-bottom: 17px;}
        .navbar {border: none;}

        .notification_badge {
            position: absolute;
            top: -2px;
            left: 10px;
            font-size: 0.6875em;
            text-align: center;
            line-height: 16px;
            color: #fff;
            background: #ef6f00;
            border-radius: 50%;
            width: 16px;
            height: 16px;
        }

		.permissionDiv {
			font-size:12px;
			text-align:center;
			color:#333333;
			line-height:17px;
		}

        .profile-dropdown-container {
            display: none;
            position: absolute;
            top: 59px;
            right: -6px;
            width: 103px;
            min-height: 70px;
            padding: 10px 10px;
            background-color: #fff;
            border-radius: 2px;
            -webkit-box-shadow: 0px 2px 2px 2px rgba(50, 50, 50, 0.1);
            -moz-box-shadow:    0px 2px 2px 2px rgba(50, 50, 50, 0.1);
            box-shadow:         0px 2px 2px 2px rgba(50, 50, 50, 0.1);
        }

        .profile-dropdown-container-beginQuote {
            display: none;
            position: absolute;
            top: 55px;
            right: 5px;
            width: 135px;
            min-height: 60px;
            padding: 10px 10px;
            background-color: #fff;
            border-radius: 2px;
            -webkit-box-shadow: 0px 2px 2px 2px rgba(50, 50, 50, 0.1);
            -moz-box-shadow:    0px 2px 2px 2px rgba(50, 50, 50, 0.1);
            box-shadow:         0px 2px 2px 2px rgba(50, 50, 50, 0.1);
        }

        ol, ul {list-style: none;}
        .sub_links_container {
            margin:0 auto;
            padding:0;
            max-width:80%
        }

        #thelink {
            cursor:pointer;
            float:right;
            color:#e3e3e3;
            font-size:25px;
            padding-right:10px;
        }
        
        #thelink2 {
            margin-top:-5em;
            width:175px !important;
            margin-right:35px;
            float:right;
        }

        .up-arrow {
            position: absolute;
            top: -12px;
            left: 50px;
            color: #fff;
            font-size: 120%;
        }

        .user_badge {
            float: left;
            margin-top: 6px;
            position: relative;
			margin-left:10px;
        }

        .myProfileLink {
        	margin-top:8px; 
        	margin-left:10px;
        	color:#3BC1F4;
        }
        
        .myLogoutLink {
        	margin-top:6px; 
        	margin-left:10px; 
        	color:#3BC1F4;
        }

		.premierModalClass {
			height:670px !important; 
			margin-left: -550px; 
			margin-top: -15px;
		}
		
		.premierModalClassContent {
			height:635px; 
			width:1100px;
		}
		
		#continueToPremierModalTitle {
			margin: 16px 30px 0px; 
			font-size: 32px;
		}
		
		.continueToPremierModalContent {
			font-size: 22px; 
			margin-left: 30px;
		}

		/* Styles start for new Premier Error Overlay */
		#errorPremierModal .modal-dialog{
			margin-top:350px;
		}
		#errorPremierModalContent{
			width: 470px;
			margin-left: 70px;
		}
		#errorPremierModalContent .modal-body{
			text-align:center;
		}
		#errorPremierModalContent .modal-footer{
			margin-left:37%;
		}		
		/* Styles end for new Premier Error Overlay */
		
		/*Styles added for Notification Window*/		
		.bellIcon{
			margin-top: 15px !important;
			margin-right: 10px !important;
		}
		#unSeenNotificationCount{
			min-width: 25px;
			min-height: 25px;
			padding: 2px;
			border-radius: 50%;
			display: inline-block;
			position: absolute;
			left: 10px;
			top: -10px;
			background: #ea7400;
			text-align: center;
			color: #fff;
			font-size: 14px;
		}
		
		#notificationWindow {
			display:none;
			width:790px;
            position: absolute;
			z-index: 9999;
            background: #ffffff;
            border: 1px solid #ddd;
            border-radius: 5px;
            margin-top: 27px;
			float:right;
			margin-right:130px;
			font-family: Omnes_att_iimedium;
			font-size: 1em;
			font-style:normal;
        }
        #notificationWindow:after, #notificationWindow:before {
            bottom: 100%;
            left: 2%;
            border: solid transparent;
            content: " ";
            height: 0;
            width: 0;
            position: absolute;
            pointer-events: none;
        }
        
        #notificationWindow:after {
            border-color: rgba(136, 183, 213, 0);
            border-bottom-color: #ffffff;
            border-width: 12px;
            margin-left: 0px;
        }
        #notificationWindow:before {
            border-color: rgba(194, 225, 245, 0);
			border-bottom-color: #ddd;
			border-width: 14px;
			margin-left: -1.5px;
        } 		
		#notificationWindow .notificationWindowHeader{
			height: 35px;
			padding: 5px 10px;
			border-bottom: 1px solid #939393;
		}
		#notificationWindow .notificationWindowHeader .notificationHeader{
			color: #000000;
			font-weight: bold;
		}
		#notificationWindow .notificationWindowHeader .closeWindowIcon{
			float: right;
			color: #939393;
			font-weight: bold;
			cursor:pointer;
		}
		#notificationWindow .notificationWindowBody .eachNotification{
			height: 32px;
			padding: 5px 10px;
			cursor:pointer;
		}
		#notificationWindow .notificationWindowBody .eachNotification:nth-child(even){
			background: #f2f2f2;
		}
		#notificationWindow .notificationWindowBody .notificationText{			
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
			max-width: 650px;	
			display:inline-block;			
		}
		#notificationWindow .notificationWindowBody .notificationColorText{
			float:right;
		}
		#notificationWindow .notificationWindowBody .unReadIndicationColor{
			width: 10px;
			height: 10px;
			border-radius: 50%;
			display: inline-block;
			margin-right: 10px;
			background: #ea7400;			
		}
		#notificationWindow .notificationWindowFooter{
			height: 35px;
			padding: 5px 10px;
			border-top: 1px solid #939393;
		}
		#notificationWindow .notificationWindowFooter .navigateLink{
			float:right;
			text-decoration: underline !important;
		}	
		/*Styles ended for Notification Window*/
		
		/* put this style below all other class */
        .dropdown-link-container {
            ul {
            	list-style: none;
            	list-style-type: none;
            	padding: 0px 5px;
        	}
        }        
		.dropdown-link-container li{
			margin-left:0 !important;
        }
		