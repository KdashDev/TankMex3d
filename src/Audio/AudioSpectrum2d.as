package Audio
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class AudioSpectrum2d extends Sprite
	{
		
		
		private var sound:Sound = new Sound();
		private var channel:SoundChannel;
		
		private var byteArr:ByteArray = new ByteArray();
		private var glow:GlowFilter = new GlowFilter();
		private var filterArr:Array;
		private var line:Sprite = new Sprite();
		
		
		
		public function InitAudioSpectrum2d(color:uint=0xFCAA30,alpha:Number=1,blurX:Number=10,blurY:int=10,song:String="assets/Eutanacia.mp3"):void{
			
			
			glow.color = color;
			glow.alpha = alpha;
			glow.blurX = blurX;
			glow.blurY = blurY;
			
			// load your MP3 in to the Sound object
			sound = new Sound(new URLRequest(song));         
			// apply the glow effect
			filterArr = new Array(glow);
			line.filters = filterArr;
			addChild(line);
		
			this.addEventListener(Event.ENTER_FRAME,spectrumHandler);	
		}
		
		public function Play():void{
			channel = sound.play(0,1000);
		}
		
		
		public function Stop():void{
			channel.stop();
			line.graphics.clear();
			removeEventListener(Event.ENTER_FRAME,spectrumHandler);	
		}
		
		
		
		private function spectrumHandler(event:Event):void{
			line.graphics.clear();
			line.graphics.lineStyle(1,(0x000000));
			
			line.graphics.moveTo(-1,150);
			// push the spectrum's bytes into the ByteArray
			SoundMixer.computeSpectrum(byteArr);
			
			for (var i:uint=0; i<256; i++){
				// read bytes and translate to a number between 0 and +300
				var num:Number = byteArr.readFloat() * 150 + 150;
				//use this number to draw a line
				line.graphics.lineTo(i*2,num);
			}
		}
		
		
	}
	
	
	
	
}