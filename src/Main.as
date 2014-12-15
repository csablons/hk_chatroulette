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
import flash.text.TextFormat;
import flash.media.H264VideoStreamSettings;


[SWF( width="940", height="880" )]
public class Main extends Sprite {
    private var metaText:TextField = new TextField();
    private var vid_outDescription:TextField = new TextField();
    private var vid_inDescription:TextField = new TextField();
    private var metaTextTitle:TextField = new TextField();

    private var nc:NetConnection;
    private var ns_in   :NetStream;
    private var ns_out  :NetStream;
    private var cam:Camera = Camera.getCamera();

    private var vid_out:Video;
    private var vid_in:Video;


    //Class constructor
    public function Main() {
        var textField:TextField = new TextField();
        initConnection();
    }

    //Called from class constructor, this function establishes a new NetConnection and listens for its status
    private function initConnection():void {
        nc = new NetConnection();
        nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        nc.connect("rtmp://ec2-54-76-151-124.eu-west-1.compute.amazonaws.com/livepkgr/livestream?adbe-live-event=liveevent&adbe-record-mode=record");
        //nc.connect("rtmp://example.com/application/mp4:myVideo.mp4");
        nc.client = this;   // TODO Gare !

        cam.setQuality( 90000, 90 );
        cam.setMode( 640, 480, 30, true );
        cam.setKeyFrameInterval( 15 );

        vid_out = new Video();
        vid_out.x = 150;
        vid_out.y = 10;
        vid_out.width = 640;
        vid_out.height = 480;
        addChild( vid_out );

        displayPublishingVideo();

        vid_in = new Video();
        vid_in.x = vid_out.x + vid_out.width;
        vid_in.y = vid_out.y;
        addChild( vid_in );

    }

    //It's a best practice to always check for a successful NetConnection
    protected function onNetStatus(event:NetStatusEvent):void
    {
        trace(event.info.code);

        if( event.info.code == "NetConnection.Connect.Success" ) {
            publishCamera();
            displayPlaybackVideo();
        }
    }

    //The encoding settings are set on the publishing stream
    protected function publishCamera():void
    {
        ns_out = new NetStream( nc );
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
        metaData.height = cam.height;
        metaData.width = cam.width;
        metaData.keyFrameInterval = cam.keyFrameInterval;

        ns_out.send( "@setDataFrame", "onMetaData", metaData );

    }

    //Display the outgoing video stream in the UI
    protected function displayPublishingVideo():void
    {
        vid_out.attachCamera( cam );
    }

    //Display the incoming video stream in the UI
    protected function displayPlaybackVideo():void
    {
        ns_in = new NetStream( nc );

        ns_in.client = this;

        ns_in.play( "mp4:webCam.f4v" );

        vid_in.attachNetStream( ns_in );

    }

    //Step 11: Un-comment this necessary callback function that checks bandwith (remains empty in this case)
    public function onBWDone():void
    {
    }

    //Display stream metadata and lays out visual components in the UI
    public function onMetaData( o:Object ):void
    {
        metaText.x = 0;
        metaText.y = 55;
        metaText.width = 300;
        metaText.height = 385;
        metaText.background = true;
        metaText.backgroundColor = 0x1F1F1F;
        metaText.textColor = 0xD9D9D9;
        metaText.border = true;
        metaText.borderColor = 0xDD7500;
        addChild( metaText );

        metaTextTitle.text = "\n             - Encoding Settings -";
        var stylr:TextFormat = new TextFormat();
        stylr.size = 18;
        metaTextTitle.setTextFormat( stylr );
        metaTextTitle.textColor = 0xDD7500;
        metaTextTitle.width = 300;
        metaTextTitle.y = 10;
        metaTextTitle.height = 50;
        metaTextTitle.background = true;
        metaTextTitle.backgroundColor = 0x1F1F1F;
        metaTextTitle.border = true;
        metaTextTitle.borderColor = 0xDD7500;

        vid_outDescription.text = "\n\n\n\n                 Live video from webcam \n\n" +
                "	              Encoded to H.264 in Flash Player";
        vid_outDescription.background = true;
        vid_outDescription.backgroundColor = 0x1F1F1F;
        vid_outDescription.textColor = 0xD9D9D9;
        vid_outDescription.x = 300;
        vid_outDescription.y = cam.height;
        vid_outDescription.width = cam.width;
        vid_outDescription.height = 200;
        vid_outDescription.border = true;
        vid_outDescription.borderColor = 0xDD7500;
        addChild( vid_outDescription );
        addChild( metaTextTitle );

        vid_inDescription.text = "\n\n\n\n                  H.264-encoded video \n\n" +
                "                  Streaming from Server";
        vid_inDescription.background = true;
        vid_inDescription.backgroundColor =0x1F1F1F;
        vid_inDescription.textColor = 0xD9D9D9;
        vid_inDescription.x = vid_in.x;
        vid_inDescription.y = cam.height;
        vid_inDescription.width = cam.width;
        vid_inDescription.height = 200;
        vid_inDescription.border = true;
        vid_inDescription.borderColor = 0xDD7500;
        addChild( vid_inDescription );

        for ( var settings:String in o )
        {
            trace( settings + " = " + o[settings] );

            metaText.appendText( "\n" + "  " + settings.toUpperCase() + " = " + o[settings] + "\n" );
        }
    }
}
}