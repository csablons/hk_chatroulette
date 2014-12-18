package
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.media.H264VideoStreamSettings;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import flashx.textLayout.formats.TextAlign;


[SWF( width="1500", height="600" )]
public class Main extends Sprite {
    private var metaText:TextField = new TextField();
    private var vid_outDescription:TextField = new TextField();
    private var vid_inDescription:TextField = new TextField();
    private var metaTextTitle:TextField = new TextField();

    private var nc_mySelf:NetConnection;
    private var nc_2:NetConnection;
    private var ns_out  :NetStream;
    private var cam:Camera = Camera.getCamera();
    private var mic:Microphone = Microphone.getMicrophone();

    private var vid_out:Video;
    private var vid_in:Video;

    private const _MARGE              :uint = 10;
    private const _CAM_WIDTH          :uint = 640;
    private const _CAM_HEIGHT         :uint = _CAM_WIDTH*(3/4);
    private const _INFO_ENCODING_WIDTH:uint = 200;
    private const _INFO_VIDEO_HEIGHT  :uint = 100;
    private const _TIMER              :uint = 10000;

    private const _PROTOCOL           :String = "rtmp://";
    private const _SERVER             :String = "ec2-54-154-129-243.eu-west-1.compute.amazonaws.com";
//    private const _SERVICE            :String = "livepkgr";
//    private const _STREAM_1           :String = "livestream";
//    private const _STREAM_2           :String = "livestreamMat";
//    private const _PARAMS             :String = "?adbe-live-event=liveevent&adbe-record-mode=record";

//    private const _PROTOCOL           :String = "rtmfp://";
//    private const _SERVER             :String = "ec2-54-154-108-11.eu-west-1.compute.amazonaws.com";
    private const _SERVICE            :String = "livepkgr";
    private const _STREAM_1           :String = "livestream";
    private const _STREAM_2           :String = "livestreamMat";
    private const _PARAMS             :String = "?adbe-live-event=liveevent&adbe-record-mode=record";

    private var _idInterval :uint;
    private var _idCurrent  :uint = uint.MAX_VALUE;
    private var _list  :Vector.<NetStream> = new Vector.<NetStream>();


    //Class constructor
    public function Main() {
        var textField:TextField = new TextField();
        initConnection();
        _drawInterface();
    }

    //Called from class constructor, this function establishes a new NetConnection and listens for its status
    private function initConnection():void {
        nc_mySelf = new NetConnection();
        nc_mySelf.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus_mySelf);
        nc_mySelf.connect(_PROTOCOL+_SERVER);
        nc_mySelf.client = this;

        /*nc_mySelf = new NetConnection();
        nc_mySelf.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus_mySelf);
        nc_mySelf.connect(_PROTOCOL+_SERVER+"/"+_SERVICE+"/"+_STREAM_1+_PARAMS);
        nc_mySelf.client = this;

        nc_2 = new NetConnection();
        nc_2.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus_others);
        nc_2.connect(_PROTOCOL+_SERVER+"/"+_SERVICE+"/"+_STREAM_2+_PARAMS);
        nc_2.client = this;*/

        cam.setQuality(0, 100);
        cam.setMode(_CAM_WIDTH, _CAM_HEIGHT, 15, true);
        cam.setKeyFrameInterval(15);

        vid_out = new Video();
        vid_out.x = _INFO_ENCODING_WIDTH + _MARGE;
        vid_out.y = _MARGE;
        vid_out.width = _CAM_WIDTH;
        vid_out.height = _CAM_HEIGHT;
        addChild( vid_out );

        displayPublishingVideo();

        vid_in = new Video();
        vid_in.x = vid_out.x + vid_out.width;
        vid_in.y = vid_out.y;
        vid_in.width = _CAM_WIDTH;
        vid_in.height = _CAM_HEIGHT;
        addChild( vid_in );
    }

    /**
     * Pour passer d'une vidéo à une autre régulièrement.
     */
    protected function _swapStream():void {
        trace("\n\n_swapStream()");
        var nb   :uint = _list.length;
        if (nb > 0) {
            if (_idCurrent == uint.MAX_VALUE) {
                _idCurrent = 0;
            }
            else {
                trace("On était sur le flux "+_idCurrent);
                _idCurrent++;
                if (_idCurrent >= nb) {
                    _idCurrent = 0;
                }
            }
            var ns  :NetStream;
            var u   :uint = 0;
            ns = _list[_idCurrent];
            trace("On passe sur le flux "+_idCurrent);
            //trace("ns.decodedFrames = "+ns.decodedFrames);
            /*trace("ns.info.byteCount = "+ns.info.byteCount);
            trace("ns.info.currentBytesPerSecond = "+ns.info.currentBytesPerSecond);
            trace("ns.info.dataByteCount = "+ns.info.dataByteCount);
            trace("ns.info.droppedFrames = "+ns.info.droppedFrames);
            trace("ns.info.maxBytesPerSecond = "+ns.info.maxBytesPerSecond);
            trace("ns.info.metaData = "+ns.info.metaData);
            trace("ns.info.playbackBytesPerSecond = "+ns.info.playbackBytesPerSecond);
            trace("ns.info.uri = "+ns.info.uri);
            trace("ns.info.videoBufferLength = "+ns.info.videoBufferLength);
            trace("ns.info.videoByteCount = "+ns.info.videoByteCount);
            trace("ns.info.videoBytesPerSecond = "+ns.info.videoBytesPerSecond);
            trace("ns.time = "+ns.time);*/
            //trace(ns.decodedFrames+" == 0 && "+(u+1)+" < "+nb+"\n");
            if (ns.decodedFrames == 0) {
                trace("-> Ce flux n'a rien a montrer. On regarde si on en a un autre.");
            }
            while (ns.decodedFrames == 0 && ++u < nb) {
                _idCurrent++;
                if (_idCurrent >= nb) {
                    _idCurrent = 0;
                }
                ns = _list[_idCurrent];
                trace("On essaye le flux "+_idCurrent);
                //trace("ns.decodedFrames = "+ns.decodedFrames);
                /*trace("ns.info.byteCount = "+ns.info.byteCount);
                trace("ns.info.currentBytesPerSecond = "+ns.info.currentBytesPerSecond);
                trace("ns.info.dataByteCount = "+ns.info.dataByteCount);
                trace("ns.info.droppedFrames = "+ns.info.droppedFrames);
                trace("ns.info.maxBytesPerSecond = "+ns.info.maxBytesPerSecond);
                trace("ns.info.metaData = "+ns.info.metaData);
                trace("ns.info.playbackBytesPerSecond = "+ns.info.playbackBytesPerSecond);
                trace("ns.info.uri = "+ns.info.uri);
                trace("ns.info.videoBufferLength = "+ns.info.videoBufferLength);
                trace("ns.info.videoByteCount = "+ns.info.videoByteCount);
                trace("ns.info.videoBytesPerSecond = "+ns.info.videoBytesPerSecond);
                trace("ns.time = "+ns.time);*/
                //trace(ns.decodedFrames+" == 0 && "+(u+1)+" < "+nb);
                if (ns.decodedFrames == 0) {
                    trace("-> Le flux "+_idCurrent+" ne marche pas mieux :( On continue de chercher !");
                    if (u+1 < nb) {
                        trace("-> Il reste "+(nb-(u+1))+" flux a tester, tout n'est pas perdu !");
                    }
                    else {
                        trace("-> En fait il n'y a pas d'autres flux à tester :(");
                    }
                }
                else {
                    trace("-> C'est bon le flux "+_idCurrent+" convient :)");
                }
            }

            vid_in.attachNetStream(ns);
        }
    }

    /**
     * Pour traiter la connection à notre flux.
     * Si c'est réussi on commence à publier notre vidéo.
     * On enregistre le retour de notre flux depuis le server pour le diffuser.
     * @param NetStatusEvent
     */
    protected function _onNetStatus_mySelf(event:NetStatusEvent):void {
        trace( event.info.code );

        if( event.info.code == "NetConnection.Connect.Success" ) {
            publishCamera();
            displayPlaybackVideo(event.currentTarget as NetConnection);

            clearInterval(_idInterval);
            _idInterval = setInterval(_swapStream, _TIMER);
            _swapStream();
        }
    }

    /**
     * On enregistre le retour du flux depuis le server pour le diffuser.
     * @param NetStatusEvent
     */
    protected function _onNetStatus_others(event:NetStatusEvent):void {
        trace( event.info.code );

        if( event.info.code == "NetConnection.Connect.Success" ) {
            displayPlaybackVideo(event.currentTarget as NetConnection);

            clearInterval(_idInterval);
            _idInterval = setInterval(_swapStream, _TIMER);
            _swapStream();
        }
    }

    /**
     * Pour publier la vidéo sur le serveur.
     */
    protected function publishCamera():void {
        //ns_out = new NetStream( nc_1, NetStream.DIRECT_CONNECTIONS);
        ns_out = new NetStream( nc_mySelf);
        ns_out.attachCamera( cam );
        ns_out.attachAudio( mic );

        var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
        h264Settings.setProfileLevel( H264Profile.BASELINE, H264Level.LEVEL_3_1 );

        ns_out.videoStreamSettings = h264Settings;
        ns_out.publish( "mp4:webCam.f4v", "live" );

        var metaData:Object = new Object();
        metaData.codec = ns_out.videoStreamSettings.codec;
        metaData.profile =  h264Settings.profile;
        metaData.level = h264Settings.level;
        metaData.fps = cam.fps;
        metaData.width = cam.width;
        metaData.height = cam.height;
        metaData.keyFrameInterval = cam.keyFrameInterval;

        ns_out.send( "@setDataFrame", "onMetaData", metaData );
    }

    //Display the outgoing video stream in the UI
    protected function displayPublishingVideo():void {
        vid_out.attachCamera(cam);
    }

    /**
     * Ajoute le flux reçu à la liste des flux.
     */
    protected function displayPlaybackVideo(nc:NetConnection):void {
        var ns  :NetStream = new NetStream(nc);
        ns.client = this;
        ns.play("mp4:webCam.f4v");
        _list.push(ns);
    }

    //Step 11: Un-comment this necessary callback function that checks bandwith (remains empty in this case)
    public function onBWDone():void {}

    //Display stream metadata and lays out visual components in the UI
    public function onMetaData(o:Object):void {
        for ( var settings:String in o ) {
            //trace( settings + " = " + o[settings] );
            metaText.appendText("  " + settings.toUpperCase() + " = " + o[settings]+"\n");
        }
    }

    //Display stream metadata and lays out visual components in the UI
    public function _drawInterface():void {
        metaTextTitle.text = "- Encoding Settings -";
        var stylr:TextFormat = new TextFormat();
        stylr.size = 18;
        stylr.align = TextAlign.CENTER;
        metaTextTitle.setTextFormat( stylr );
        metaTextTitle.textColor = 0xDD7500;
        metaTextTitle.x = _MARGE;
        metaTextTitle.y = _MARGE;
        metaTextTitle.width = _INFO_ENCODING_WIDTH;
        metaTextTitle.height = 50;
        metaTextTitle.background = true;
        metaTextTitle.backgroundColor = 0x1F1F1F;
        metaTextTitle.border = true;
        metaTextTitle.borderColor = 0xDD7500;
        addChild( metaTextTitle );

        metaText.x = metaTextTitle.x;
        metaText.y = metaTextTitle.y + metaTextTitle.height;
        metaText.width = metaTextTitle.width;
        metaText.height = cam.height + _INFO_VIDEO_HEIGHT - metaTextTitle.height;
        metaText.background = true;
        metaText.backgroundColor = 0x1F1F1F;
        metaText.textColor = 0xD9D9D9;
        metaText.border = true;
        metaText.borderColor = 0xDD7500;
        addChild( metaText );

        vid_outDescription.text = "\n\n                 Live video from webcam \n\n" +
                "	              Encoded to H.264 in Flash Player";
        vid_outDescription.background = true;
        vid_outDescription.backgroundColor = 0x1F1F1F;
        vid_outDescription.textColor = 0xD9D9D9;
        vid_outDescription.x = vid_out.x;
        vid_outDescription.y = vid_out.y + vid_out.height;
        vid_outDescription.width = vid_out.width;
        vid_outDescription.height = _INFO_VIDEO_HEIGHT;
        vid_outDescription.border = true;
        vid_outDescription.borderColor = 0xDD7500;
        addChild( vid_outDescription );

        vid_inDescription.text = "\n\n                  H.264-encoded video \n\n" +
                "                  Streaming from Server";
        vid_inDescription.background = true;
        vid_inDescription.backgroundColor =0x1F1F1F;
        vid_inDescription.textColor = 0xD9D9D9;
        vid_inDescription.x = vid_in.x;
        vid_inDescription.y = vid_in.y + vid_in.height;
        vid_inDescription.width = vid_in.width;
        vid_inDescription.height = _INFO_VIDEO_HEIGHT;
        vid_inDescription.border = true;
        vid_inDescription.borderColor = 0xDD7500;
        addChild( vid_inDescription );
    }
}
}