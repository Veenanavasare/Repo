<?xml version="1.0" encoding="iso-8859-1"?>
<module type="Object">
	<head type="Object">
		<links type="Array">
           <link type="String">/resource/1393136351000/newsroomplayer2/amp/amp.css</link>     
        </links>
	</head>
	<config type="Object">
		<controls type="Object">
            <enabled type="Boolean">true</enabled>
        </controls>
	   	<fullscreen type="Object">
	   		<native type="Boolean">true</native>
	   		<enabled type="Boolean">true</enabled>
	   	</fullscreen>
	   	<playoverlay type="Object">
            <enabled type="Boolean">true</enabled>
        </playoverlay>
         
	   	<captioning type="Object"></captioning>
	   	<flash type="Object">
	   		<swf type="String">/resource/1393136351000/newsroomplayer2/amp/AkamaiStandardPlayer.swf</swf>
	   		<debug type="String">/resource/1393136351000/newsroomplayer2/amp/AkamaiStandardPlayer-debug.swf</debug>
			<vars type="Object">
				<next_video_timer type="Number">0</next_video_timer>
			</vars>
	   		<xml type="String"><![CDATA[
    	   		<application>
    				<player
    					volume = ".75"
    					dvr_enabled = "1"
    					rewind_interval = "15"
    					font_size="18"
    					media_analytics_logging_enabled="false"
    					enable_alternate_server_mapping="true"
    					enable_end_user_mapping="true"
					set_resume_dvr_at_live="true"
    					is_token_required="false"
    					locale_setting = "en"
    					auto_play_list = "false"
    					auto_replay = "false"
    					start_bitrate_index = "-1"
    					controls = "true"
					caption_language= "en-us"
    					>
    				</player>
    				<view>
    					<element id="infoOverlay" style="top: 0px; text-align: left;" />
    					<element id="captionDisplay" initState="cookie|off" position="relative" style="bottom: 0px; windowColor:0x000000; windowOpacity:0; font:Arial; fontColor:0xffffff; fontOpacity:1; fontBGColor:0x000000; fontBGOpacity:0; edgeType:none; edgeColor:0x000000; edgeOpacity:1; scroll:None; fontSize:12;" settingsEnabled="true" />
    					<element id="controls" visible="true" height="5">
						<element id="replay" />
    						<element id="playPause" />
    						<element id="rewind" />
    						<element id="progress" color="#FF0000" />
    						<element id="loaded" color="#00FF00" />
    						<element id="scrubber" />
    						<element id="cc" />
    						<element id="stats" />
    						<element id="hdclient" />
    						<element id="volume" color="#0000FF" />
    						<element id="fullscreen" />
    						<element id="logo" style="width: 205px; height: 60px; right: 15px; top: 15px; opacity: 1.0; " />
    					</element>
    				</view>
    				<plugins>
    					<!-- CONSULT AKAMAI REGARDING PLUG-IN MODIFICATIONS. DO NOT MODIFY WITHOUT SUPPORT FROM AKAMAI -->
    					<plugin host="osmf" type="dynamic" absolute="true" id="AkamaiAdvancedStreamingPlugin">http://players.edgesuite.net/flash/plugins/osmf/advanced-streaming-plugin/v3.1/osmf2.0/AkamaiAdvancedStreamingPlugin.swf</plugin>
    					<plugin host="osmf" type="dynamic" id="CaptioningPlugin">/resource/1393136351000/newsroomplayer2/resources/plugins/CaptioningPlugin.swf</plugin>
					<plugin host="osmf" type="dynamic" id="onCaptionInfoPlugin">/resource/1393136351000/newsroomplayer2/resources/plugins/onCaptionInfoPlugin.swf</plugin>
    					<plugin host="osmf" type="static" id="OSMFCSMALoader">com.akamai.playeranalytics.osmf.OSMFCSMALoaderInfo</plugin>
    				</plugins>
    				<recommendations>	
    					<vendor id="mrss"> 
    						<property key="RECOMMENDATIONS_MRSS_URL">?http://www.foxnews.com/feeds/rss/chartbeat/most-popular-video</property> 
    					</vendor> 
    					<vendor id="outbrain"> 
    						<property key="OUTBRAIN_BASE_URL">http://odb.outbrain.com/utils/get</property> 
    						<property key="OUTBRAIN_API_KEY">AKAMAI2011</property> 
    						<property key="OUTBRAIN_WIDGET_JS_ID">AR_2</property> 
    					</vendor> 
    				</recommendations>
    				<locales />
    			    <metrics />
    			    <eventmanagementstates />
    			</application>
			]]></xml>
	   	</flash>
		<mediaanalytics type="Object">
			<plugin type="Object">
				<js type="String">http://79423.analytics.edgesuite.net/html5/akamaihtml5-min.js</js>
				<swf type="String">http://79423.analytics.edgesuite.net/csma/plugin/csma.swf</swf>
			</plugin>
			<config type="String">http://ma188-r.analytics.edgesuite.net/config/beacon-2114.xml?setVideoObject=1</config>
			<dimensions type="Object">
                <eventName type="String">AMP Sample Event</eventName>
                <title type="String">AMP Sample Title</title>
                <playerId type="String">#{player.mode} Player</playerId>
            </dimensions>
		</mediaanalytics>
		<locales type="Object">  
			<en type="Object">
				<MSG_EMAIL_TO>To</MSG_EMAIL_TO>
				<MSG_EMAIL_FROM>From</MSG_EMAIL_FROM>
				<MSG_EMAIL_VIDEO>Email this video</MSG_EMAIL_VIDEO>
				<MSG_EMAIL_MESSAGE_DEFAULT>Check out this video from xxx</MSG_EMAIL_MESSAGE_DEFAULT>
				<MSG_EMAIL_MESSAGE>Message</MSG_EMAIL_MESSAGE>
				<MSG_EMAIL_ADDRESS_INVALID>Invalid Email Address</MSG_EMAIL_ADDRESS_INVALID>
				<MSG_EMAIL_MESSAGE_INVALID>Please limit your message to 500 characters or less.</MSG_EMAIL_MESSAGE_INVALID>
				<MSG_EMAIL_CHARACTERS_REMAINING_TEXT> characters left</MSG_EMAIL_CHARACTERS_REMAINING_TEXT>
				<MSG_EMAIL_SEND_FAILURE>Message could not be sent.</MSG_EMAIL_SEND_FAILURE>
				<MSG_EMAIL_SEND_SUCCESS_MESSAGE>Your email has been sent!</MSG_EMAIL_SEND_SUCCESS_MESSAGE>
				<MSG_SHARE_VIDEO_TEXT>Share this video...</MSG_SHARE_VIDEO_TEXT>
				<MSG_POST_TEXT>Post</MSG_POST_TEXT>
				<MSG_EMBED_TEXT>Embed</MSG_EMBED_TEXT>
				<MSG_LINK_TEXT>Link</MSG_LINK_TEXT>
				<MSG_SHARE_CONNECT_FAILURE>Unable to connect. Please try again.</MSG_SHARE_CONNECT_FAILURE>
				<MSG_SHARE_CONTENT_DISABLED>Share and embed are disabled.</MSG_SHARE_CONTENT_DISABLED>
				<MSG_VERSION_TEXT>Version</MSG_VERSION_TEXT>
				<MSG_BUFFERING_TEXT>buffering</MSG_BUFFERING_TEXT>
				<MSG_CUSTOMIZE_CLIP_POINTS>Customize the start and end point of the video.</MSG_CUSTOMIZE_CLIP_POINTS>
				<MSG_PAUSE>Pause</MSG_PAUSE>
				<MSG_PREVIEW>Preview</MSG_PREVIEW>
				<MSG_CURRENT>Currrent</MSG_CURRENT>
				<MSG_SEEK_TO>Seek to</MSG_SEEK_TO>
				<MSG_LIVE>LIVE</MSG_LIVE>
				<MSG_DEFAULT_ERROR_MESSAGE>Sorry, we were unable to play the media you selected. Please try again, or select alternate media.</MSG_DEFAULT_ERROR_MESSAGE>
				<MSG_ERROR_PREFIX>Error encountered:</MSG_ERROR_PREFIX>
				<MSG_STREAM_NOT_FOUND>Stream not found</MSG_STREAM_NOT_FOUND>
				<MSG_CURRENT_WORKING_BANDWIDTH>Current working bandwidth</MSG_CURRENT_WORKING_BANDWIDTH>
				<MSG_CURRENT_BITRATE_PLAYING>Current bitrate playing</MSG_CURRENT_BITRATE_PLAYING>
				<MSG_MAX_BITRATE_AVAILABLE>Max bitrate available</MSG_MAX_BITRATE_AVAILABLE>
				<MSG_NOT_AVAILABLE>Not Available</MSG_NOT_AVAILABLE>
				<MSG_GO_LIVE>GO LIVE</MSG_GO_LIVE>
				<MSG_REPLAY>Replay</MSG_REPLAY>
				<MSG_NEXT_VIDEO>Next video starts in: </MSG_NEXT_VIDEO>
				<MSG_RECOMMENDED>Recommended</MSG_RECOMMENDED>
				<MSG_VIEW_ALL>View all </MSG_VIEW_ALL>
				<MSG_VIDEO> videos</MSG_VIDEO>
				<MSG_CC>CC</MSG_CC>
				<MSG_CC_TITLE>Caption Settings</MSG_CC_TITLE>
				<MSG_CC_LANGUAGE>Language :</MSG_CC_LANGUAGE>
				<MSG_CC_PRESETS>Presets :</MSG_CC_PRESETS>
				<MSG_CC_FONT>Font :</MSG_CC_FONT>
				<MSG_CC_EDGE>Edge :</MSG_CC_EDGE>
				<MSG_CC_SIZE>Size :</MSG_CC_SIZE>
				<MSG_CC_SCROLL>Scroll :</MSG_CC_SCROLL>
				<MSG_CC_COLOR>Color :</MSG_CC_COLOR>
				<MSG_CC_BACKGROUND>Background :</MSG_CC_BACKGROUND>
				<MSG_CC_EDGE>Edge :</MSG_CC_EDGE>
				<MSG_CC_WINDOW>Window :</MSG_CC_WINDOW>
				<MSG_CC_OPACITY>Opacity :</MSG_CC_OPACITY>
				<MSG_CC_SHOW_ADVANCED>Show Advanced Settings</MSG_CC_SHOW_ADVANCED>
				<MSG_CC_HIDE_ADVANCED>Hide Advanced Settings</MSG_CC_HIDE_ADVANCED>
				<MSG_CC_RESET>Reset</MSG_CC_RESET>
				<MSG_CC_CANCEL>Cancel</MSG_CC_CANCEL>
				<MSG_CC_APPLY>Apply</MSG_CC_APPLY>
				<MSG_EN>English</MSG_EN>
				<MSG_ES>Spanish</MSG_ES>
				<MSG_DE>German</MSG_DE>
				<MSG_FR>French</MSG_FR>
				<MSG_IT>Italian</MSG_IT>
				<MSG_RU>Russian</MSG_RU>
		  	</en>
			<es type="Object">
				<MSG_EMAIL_TO>a</MSG_EMAIL_TO>
			  	<MSG_EMAIL_FROM>de</MSG_EMAIL_FROM>
				<MSG_EMAIL_VIDEO>Enviar este vÌdeo</MSG_EMAIL_VIDEO>
				<MSG_EMAIL_MESSAGE_DEFAULT>Echa un vistazo a este video de xxx</MSG_EMAIL_MESSAGE_DEFAULT>
				<MSG_EMAIL_MESSAGE>mensaje</MSG_EMAIL_MESSAGE>
				<MSG_EMAIL_ADDRESS_INVALID>DirecciÛn de correo electrÛnico no v·lida</MSG_EMAIL_ADDRESS_INVALID>
				<MSG_EMAIL_MESSAGE_INVALID>Por favor limite su mensaje a 500 caracteres o menos.</MSG_EMAIL_MESSAGE_INVALID>
				<MSG_EMAIL_CHARACTERS_REMAINING_TEXT>personajes de la izquierda</MSG_EMAIL_CHARACTERS_REMAINING_TEXT>
				<MSG_EMAIL_SEND_FAILURE>El mensaje no pudo ser enviado.</MSG_EMAIL_SEND_FAILURE>
				<MSG_EMAIL_SEND_SUCCESS_MESSAGE>Tu email ha sido enviado!</MSG_EMAIL_SEND_SUCCESS_MESSAGE>
				<MSG_SHARE_VIDEO_TEXT>Comparte este vÌdeo...</MSG_SHARE_VIDEO_TEXT>
				<MSG_POST_TEXT>enviar</MSG_POST_TEXT>
				<MSG_EMBED_TEXT>incrustar</MSG_EMBED_TEXT>
				<MSG_LINK_TEXT>enlace</MSG_LINK_TEXT>
				<MSG_SHARE_CONNECT_FAILURE>No se puede conectar. Por favor, intÈntelo de nuevo.</MSG_SHARE_CONNECT_FAILURE>
				<MSG_SHARE_CONTENT_DISABLED>Compartir e incrustar est·n desactivados.</MSG_SHARE_CONTENT_DISABLED>
				<MSG_VERSION_TEXT>versiÛn</MSG_VERSION_TEXT>
				<MSG_BUFFERING_TEXT>el almacenamiento en b˙fer</MSG_BUFFERING_TEXT>
				<MSG_CUSTOMIZE_CLIP_POINTS>Personalizar el inicio y el punto final del video.</MSG_CUSTOMIZE_CLIP_POINTS>
				<MSG_PAUSE>romper</MSG_PAUSE>
				<MSG_PREVIEW>vista previa</MSG_PREVIEW>
				<MSG_CURRENT>corriente</MSG_CURRENT>
				<MSG_SEEK_TO>Tratar de</MSG_SEEK_TO>
				<MSG_LIVE>EN VIVO</MSG_LIVE>
				<MSG_DEFAULT_ERROR_MESSAGE>Lo sentimos, no hemos podido jugar los medios de comunicaciÛn seleccionados. Por favor, intÈntelo de nuevo, o seleccionar los medios de comunicaciÛn alternativos.</MSG_DEFAULT_ERROR_MESSAGE>
				<MSG_ERROR_PREFIX>Se produjo un error:</MSG_ERROR_PREFIX>
				<MSG_STREAM_NOT_FOUND>Stream que no se encuentra</MSG_STREAM_NOT_FOUND>
				<MSG_CURRENT_WORKING_BANDWIDTH>Ancho de banda actual de trabajo</MSG_CURRENT_WORKING_BANDWIDTH>
				<MSG_CURRENT_BITRATE_PLAYING>Tasa de bits de reproducciÛn actual</MSG_CURRENT_BITRATE_PLAYING>
				<MSG_MAX_BITRATE_AVAILABLE>Tasa de bits m·xima disponible</MSG_MAX_BITRATE_AVAILABLE>
				<MSG_NOT_AVAILABLE>No est· disponible</MSG_NOT_AVAILABLE>
				<MSG_GO_LIVE>IR A VIVIR</MSG_GO_LIVE>
				<MSG_REPLAY>Repetir</MSG_REPLAY>
				<MSG_NEXT_VIDEO>El prÛximo video comienza en: </MSG_NEXT_VIDEO>
				<MSG_RECOMMENDED>Recomendado</MSG_RECOMMENDED>
				<MSG_VIEW_ALL>Ver todos </MSG_VIEW_ALL>
				<MSG_VIDEO> vÌdeos</MSG_VIDEO>
				<MSG_CC>CC</MSG_CC>
			</es>
		</locales>
   	</config>
</module>