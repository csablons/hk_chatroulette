package
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.media.H264VideoStreamSettings;

import flashx.textLayout.formats.TextAlign;


[SWF( width="1180", height="360" )]
public class Main extends Sprite {
    private var metaText:TextField = new TextField();
    private var vid_outDescription:TextField = new TextField();
    private var vid_inDescription_1:TextField = new TextField();
    private var vid_inDescription_2:TextField = new TextField();
    private var metaTextTitle:TextField = new TextField();

    private var nc_1:NetConnection;
    private var nc_2:NetConnection;
    private var ns_in_1   :NetStream;
    private var ns_in_2   :NetStream;
    private var ns_out  :NetStream;
    private var cam:Camera = Camera.getCamera();

    private var vid_out:Video;
    private var vid_in_1:Video;
    private var vid_in_2:Video;

    private const _MARGE              :uint = 10;
    private const _CAM_WIDTH          :uint = 320;
    private const _CAM_HEIGHT         :uint = _CAM_WIDTH*(3/4);
    private const _INFO_ENCODING_WIDTH:uint = 200;
    private const _INFO_VIDEO_HEIGHT  :uint = 100;


    //Class constructor
    public function Main() {
        var textField:TextField = new TextField();
        initConnection();
    }

    //Called from class constructor, this function establishes a new NetConnection and listens for its status
    private function initConnection():void {
        nc_1 = new NetConnection();
        nc_1.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus_1);
        nc_1.connect("rtmp://ec2-54-76-151-124.eu-west-1.compute.amazonaws.com/livepkgr/livestream?adbe-live-event=liveevent&adbe-record-mode=record");
        //nc.connect("rtmp://example.com/application/mp4:myVideo.mp4");
        nc_1.client = this;   // TODO Gare !

        nc_2 = new NetConnection();
        nc_2.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus_2);
        nc_2.connect("rtmp://ec2-54-154-78-193.eu-west-1.compute.amazonaws.com/livepkgr/livestreamMat?adbe-live-event=liveevent&adbe-record-mode=record");
        nc_2.client = this;   // TODO Gare !

        cam.setQuality(90000, 90);
        cam.setMode(_CAM_WIDTH, _CAM_HEIGHT, 30, true);
        cam.setKeyFrameInterval(15);

        vid_out = new Video();
        vid_out.x = _INFO_ENCODING_WIDTH + _MARGE;
        vid_out.y = _MARGE;
        vid_out.width = _CAM_WIDTH;
        vid_out.height = _CAM_HEIGHT;
        addChild( vid_out );

        displayPublishingVideo();

        vid_in_1 = new Video();
        vid_in_1.x = vid_out.x + vid_out.width;
        vid_in_1.y = vid_out.y;
        addChild( vid_in_1 );

        vid_in_2 = new Video();
        vid_in_2.x = vid_in_1.x + vid_in_1.width;
        vid_in_2.y = vid_in_1.y;
        addChild( vid_in_2 );

    }

    //It's a best practice to always check for a successful NetConnection
    protected function onNetStatus_1(event:NetStatusEvent):void
    {
        trace(event.info.code);

        if( event.info.code == "NetConnection.Connect.Success" ) {
            publishCamera();
            displayPlaybackVideo_1();
        }
    }

    //It's a best practice to always check for a successful NetConnection
    protected function onNetStatus_2(event:NetStatusEvent):void
    {
        trace(event.info.code);

        if( event.info.code == "NetConnection.Connect.Success" ) {
            displayPlaybackVideo_2();
        }
    }

    //The encoding settings are set on the publishing stream
    protected function publishCamera():void
    {
        ns_out = new NetStream( nc_1 );
        ns_out.attachCamera( cam );

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

    //Display the incoming video stream in the UI
    protected function displayPlaybackVideo_1():void {
        ns_in_1 = new NetStream(nc_1);
        ns_in_1.client = this;
        ns_in_1.play("mp4:webCam.f4v");
        vid_in_1.attachNetStream(ns_in_1);
    }

    //Display the incoming video stream in the UI
    protected function displayPlaybackVideo_2():void {
        ns_in_2 = new NetStream(nc_2);
        ns_in_2.client = this;
        ns_in_2.play("mp4:webCam.f4v");
        vid_in_2.attachNetStream(ns_in_2);
    }

    //Step 11: Un-comment this necessary callback function that checks bandwith (remains empty in this case)
    public function onBWDone():void {}

    //Display stream metadata and lays out visual components in the UI
    public function onMetaData(o:Object):void {
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
        vid_outDescription.y = vid_out.y + cam.height;
        vid_outDescription.width = cam.width;
        vid_outDescription.height = _INFO_VIDEO_HEIGHT;
        vid_outDescription.border = true;
        vid_outDescription.borderColor = 0xDD7500;
        addChild( vid_outDescription );

        vid_inDescription_1.text = "\n\n                  H.264-encoded video \n\n" +
                "                  Streaming from Server 1";
        vid_inDescription_1.background = true;
        vid_inDescription_1.backgroundColor =0x1F1F1F;
        vid_inDescription_1.textColor = 0xD9D9D9;
        vid_inDescription_1.x = vid_in_1.x;
        vid_inDescription_1.y = vid_in_1.y + cam.height;
        vid_inDescription_1.width = cam.width;
        vid_inDescription_1.height = _INFO_VIDEO_HEIGHT;
        vid_inDescription_1.border = true;
        vid_inDescription_1.borderColor = 0xDD7500;
        addChild( vid_inDescription_1 );

        vid_inDescription_2.text = "\n\n                  H.264-encoded video \n\n" +
                "                  Streaming from Server 2";
        vid_inDescription_2.background = true;
        vid_inDescription_2.backgroundColor =0x1F1F1F;
        vid_inDescription_2.textColor = 0xD9D9D9;
        vid_inDescription_2.x = vid_in_2.x;
        vid_inDescription_2.y = vid_in_2.y + cam.height;
        vid_inDescription_2.width = cam.width;
        vid_inDescription_2.height = _INFO_VIDEO_HEIGHT;
        vid_inDescription_2.border = true;
        vid_inDescription_2.borderColor = 0xDD7500;
        addChild( vid_inDescription_2 );

        for ( var settings:String in o ) {
            trace( settings + " = " + o[settings] );
            metaText.appendText( "\n" + "  " + settings.toUpperCase() + " = " + o[settings] + "\n" );
        }
    }
}
}