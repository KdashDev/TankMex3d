/*

AWD file loading example in Away3d

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

This code is distributed under the MIT License

Copyright (c) The Away Foundation http://www.theawayfoundation.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 */
package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.Vector3D;
    import flash.net.URLRequest;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.engine.BreakOpportunity;
    import flash.ui.Keyboard;
    
    import Audio.AudioSpectrum2d;
    
    import away3d.cameras.lenses.PerspectiveLens;
    import away3d.containers.ObjectContainer3D;
    import away3d.containers.View3D;
    import away3d.controllers.HoverController;
    import away3d.core.base.Object3D;
    import away3d.debug.AwayStats;
    import away3d.entities.Mesh;
    import away3d.events.AssetEvent;
    import away3d.events.LoaderEvent;
    import away3d.events.MouseEvent3D;
    import away3d.library.AssetLibrary;
    import away3d.library.assets.AssetType;
    import away3d.lights.PointLight;
    import away3d.loaders.Loader3D;
    import away3d.loaders.parsers.AWD2Parser;
    import away3d.loaders.parsers.Parsers;
    import away3d.materials.ColorMaterial;
    import away3d.materials.TextureMaterial;
    import away3d.materials.lightpickers.StaticLightPicker;
    import away3d.materials.methods.FresnelSpecularMethod;
    import away3d.materials.methods.NearShadowMapMethod;
    import away3d.materials.methods.TerrainDiffuseMethod;
    import away3d.primitives.ConeGeometry;
    import away3d.primitives.CubeGeometry;
    import away3d.primitives.CylinderGeometry;
    import away3d.primitives.PlaneGeometry;
    import away3d.textures.BitmapTexture;
    
    import awayphysics.collision.dispatch.AWPCollisionObject;
    import awayphysics.collision.shapes.AWPBoxShape;
    import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
    import awayphysics.collision.shapes.AWPCompoundShape;
    import awayphysics.collision.shapes.AWPConeShape;
    import awayphysics.collision.shapes.AWPCylinderShape;
    import awayphysics.collision.shapes.AWPHeightfieldTerrainShape;
    import awayphysics.collision.shapes.AWPStaticPlaneShape;
    import awayphysics.debug.AWPDebugDraw;
    import awayphysics.dynamics.AWPDynamicsWorld;
    import awayphysics.dynamics.AWPRigidBody;
    import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
    import awayphysics.dynamics.vehicle.AWPVehicleTuning;
    import awayphysics.dynamics.vehicle.AWPWheelInfo;
    import awayphysics.extend.AWPTerrain;
    
    import caurina.transitions.Tweener;
    

    
 
	
	
    [SWF(backgroundColor="#333338", frameRate="60", quality="LOW")]
    public class Intermediate_AWDViewer extends Sprite 
	{
    	
		
        //engine variables
        private var _view:View3D;
		private var _signature:Sprite;
        private var _stats:AwayStats;
        private var _cameraController:HoverController;
		private var carBody : AWPRigidBody ;
        
        //navigation
        private var _prevMouseX:Number;
        private var _prevMouseY:Number;
        private var _mouseMove:Boolean;
        private var _cameraHeight:Number = 0;
        
        private var _eyePosition:Vector3D;
        private var cloneActif:Boolean = false;
        private var _text:TextField;
		
        private var _specularMethod:FresnelSpecularMethod;
        private var _shadowMethod:NearShadowMapMethod;
		private var tanque:ObjectContainer3D;
		
		private var _light : PointLight;
		private var lightPicker:StaticLightPicker;
		private var physicsWorld : AWPDynamicsWorld;
		private var car : AWPRaycastVehicle;
		private var _engineForce : Number = 0;
		private var _breakingForce : Number = 0;
		private var _vehicleSteering : Number = 0;
		private var timeStep : Number = 1.0 / 60;
		private var keyRight : Boolean = false;
		private var keyLeft : Boolean = false;
		private var debugDraw:AWPDebugDraw;
		private var _rotacion:Number=0;
		private var _detectarotacion:Number;
		private var _detectagrado:Number=0;
		private var _detectagrado2:Number=0;
		private var _derechaBool:Boolean;
		private var _izquierdaBool:Boolean;
		private var _adelanteBool:Boolean;
		private var _atrasBool:Boolean;
		private var _spectrum2d:AudioSpectrum2d;

		private var text:TextField;
		
		private var cuboaux:Mesh;
		
		[Embed(source="../embeds/fskin.jpg")]
		private var CarSkin : Class;
		[Embed(source="../embeds/Heightmap.jpg")]
		private var HeightMap : Class;
		[Embed(source="../embeds/terrain_tex.jpg")]
		private var Albedo : Class;
		[Embed(source="../embeds/terrain_norms.jpg")]
		private var Normals : Class;
		[Embed(source="../embeds/grass.jpg")]
		private var Grass : Class;
		[Embed(source="../embeds/rock.jpg")]
		private var Rock : Class;
		[Embed(source="../embeds/beach.jpg")]
		private var Beach : Class;
		[Embed(source="../embeds/terrainBeachBlend.jpg")]
		private var Blend:Class;
		[Embed(source="assets/inicio.jpg")]
		private var inicioImage:Class;
		[Embed(source="assets/inicio2048.jpg")]
		private var SeleccionaImage:Class;
        private var tankFont:FontMvc;
		private var startFont:FontMvc;
		
		private var Iniciobitmap:Bitmap = new inicioImage() ;
		private var auxIntro:Sprite;
		private var _plane:Mesh;
		private var _contenedorVehiculosArray:Array=new Array();
		private var Main_Body_2:Mesh;
		private var Main_Body:Mesh;
		private var Turret:Mesh;
		private var	gun:Mesh;
		private var auxContinerT90:ObjectContainer3D;
		private var auxContinerT29:ObjectContainer3D;
		private var EscojerM:Boolean;
		private var loader2:Loader3D;
		
		private var t29rotacion:Number=0;
		
	
		

		
	
		
        /**
         * Constructor
         */
        public function Intermediate_AWDViewer()
		{
            init();
		
        }
        
        /**
         * Global initialise function
         */
		
		
		private function init():void
		{
			
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.nativeWindow.maximize(); 
			
			stage.addEventListener(Event.ADDED_TO_STAGE,onAddstage);
			stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, windowResizeEventHandler);
			
			Addintro();
			
			

		}
		
		
		private function Addintro():void{
			
			auxIntro= new Sprite();
			
			tankFont=new FontMvc("TankMex",0xFCAA30,120,false);
			startFont=new FontMvc("Jugar",0x0066FF,120,true);
			startFont.Mainstage=this;
			
			_spectrum2d= new AudioSpectrum2d();
			_spectrum2d.InitAudioSpectrum2d();
			_spectrum2d.Play();
			
			auxIntro.addChild(Iniciobitmap);
			auxIntro.addChild(tankFont);
			auxIntro.addChild(startFont);
			auxIntro.addChild(_spectrum2d);
			addChild(auxIntro);
			
		}
		
	
		public  function DestruyeIntro():void{
			_spectrum2d.Stop();
			for(var i:int=0;i<auxIntro.numChildren;i++){
				auxIntro.removeChildAt(i);
			}
			removeChild(auxIntro);
			
			init3d();
			
		}
		
		
		
		
		
		
		private function windowResizeEventHandler(evt:NativeWindowBoundsEvent):void
		{
			
			Iniciobitmap.width  = stage.stageWidth;
			Iniciobitmap.height = stage.stageHeight;
			Iniciobitmap.x=0;
			Iniciobitmap.y=0;
			tankFont.y=(stage.stageHeight/2)-200;
			startFont.y=(stage.stageHeight/2)-100;
			startFont.x=(stage.stageWidth/2)-200;
			_spectrum2d.y =(stage.stageHeight/2);
			_spectrum2d.x=50;
			
		}
		
		
        private function init3d():void
		{
            initEngine();
           initText();
			initListeners();
			
			
			
			//kickoff asset loading
			var loader:Loader3D = new Loader3D(false);
		    loader.load(new URLRequest("assets/t90.awd"));
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
			loader.id="t90";
			loader2=new Loader3D();
			loader2.id="t29";
			loader2.load(new URLRequest("assets/tank.awd"));
			
			loader2.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onCarResourceComplete);
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onCarResourceComplete);
			

        }
		
		private function clickn(event:MouseEvent):void{
		
		trace(event.target.id);
		
		}
		
		private function onCarResourceComplete(event : LoaderEvent) : void {
			
			EscojerM=true;		

		
			
			auxContinerT90= new ObjectContainer3D();
			auxContinerT29= new ObjectContainer3D();
			
			switch(event.target.id){
			case  "t90":
				
				Main_Body_2.mouseEnabled=true;
				Main_Body_2.mouseChildren= true;
				Main_Body.mouseEnabled=true;
				Main_Body.mouseChildren= true;
				Turret.mouseEnabled=true;
				Turret.mouseChildren= true;
				gun.mouseEnabled=true;
				gun.mouseChildren= true;
				auxContinerT90.id="t90";
				auxContinerT90.addChild(Main_Body_2);
				auxContinerT90.addChild(Main_Body);
				auxContinerT90.addChild(Turret);
				auxContinerT90.addChild(gun);
				
				
				
				auxContinerT90.mouseEnabled=true;
				auxContinerT90.mouseChildren= true;
				auxContinerT90.addEventListener(MouseEvent3D.MOUSE_UP,onObjectMouseOver);
				_view.scene.addChild(auxContinerT90);
				
				break;
			case "t29":
				
				
				loader2.addEventListener(MouseEvent3D.MOUSE_UP,onObjectMouseOver);
				cuboaux= new Mesh(new CubeGeometry(600,300),new ColorMaterial(0x111199,0));
				cuboaux.mouseEnabled=true;
				cuboaux.mouseChildren= true;
				cuboaux.addEventListener(MouseEvent3D.MOUSE_UP,onObjectMouseOver);
				_view.scene.addChild(cuboaux);
				loader2.y=-325;
				cuboaux.y=-225;
				_view.scene.addChild(loader2);
			 break;
			
			}
			
			
			
			
		}
		
		private function onObjectMouseOver(event:MouseEvent3D):void {
		trace("id"+event.target.id);
		if(event.target.id=="t90"){
		_view.background=null;
		initKeyBoard();
		
		_light = new PointLight();
		_light.y = 5000;
		_view.scene.addChild(_light);
		
		lightPicker = new StaticLightPicker([_light]);
		
		_view.camera.lens.far = 100000;
		
		_view.camera.y = 2000;
		_view.camera.z = -2000;
		_view.camera.rotationX =40;
		
		auxContinerT90.removeEventListener(MouseEvent3D.MOUSE_UP,onObjectMouseOver);
		agregarTerreno();
		removeChild(text);
		crearHuesos(auxContinerT90);
		}else{
		
			_view.background=null;
			initKeyBoard();
			
			_light = new PointLight();
			_light.y = 5000;
			_view.scene.addChild(_light);
			
			lightPicker = new StaticLightPicker([_light]);
			
			_view.camera.lens.far = 100000;
			
			_view.camera.y = 2000;
			_view.camera.z = -2000;
			_view.camera.rotationX =40;
			
			loader2.removeEventListener(MouseEvent3D.MOUSE_UP,onObjectMouseOver);
			agregarTerreno();
			removeChild(text);
			_view.scene.removeChild(cuboaux);
			crearHuesos(loader2);
		
		}
		}
		
		
		
		private function crearHuesos(container : ObjectContainer3D):void{
		
		
			// create the chassis body
			var carShape : AWPCompoundShape = createCarShape();
			carBody =new AWPRigidBody(carShape, container, 1200);
			carBody.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			carBody.friction = 0.9;
			carBody.linearDamping = 0.1;
			carBody.angularDamping = 0.1;
			carBody.position = new Vector3D(0, 1500, 0);
			
			physicsWorld.addRigidBody(carBody);

			
		
		}
		
		
		
			
		
		// create car chassis shape
		private function createCarShape() : AWPCompoundShape {
			var boxShape1 : AWPBoxShape = new AWPBoxShape(260, 170, 570);
			var boxShape2 : AWPBoxShape = new AWPBoxShape(240, 100, 300);
			
			var carShape : AWPCompoundShape = new AWPCompoundShape();
			carShape.addChildShape(boxShape1, new Vector3D(0, 100, 0), new Vector3D());
			carShape.addChildShape(boxShape2, new Vector3D(0, 200, -30), new Vector3D());

			
			return carShape;
		}
		
        
		private function keyDownHandler(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					_adelanteBool=true;
					//carBody.applyCentralImpulse(new Vector3D(300,0,0));
					break;
				case Keyboard.DOWN:
					_atrasBool=true;
					break;
				case Keyboard.LEFT:
					
					_izquierdaBool=true;
					
					break;
				case Keyboard.RIGHT:
					_derechaBool=true;
					break;
					
				case 65:
					gun.rotationY=Turret.rotationY ++;
					
					break;
				case 83:
					gun.rotationY=Turret.rotationY --;
					break;
			}
			
			//trace(event.keyCode);
		}
		
		private function keyUpHandler(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					_adelanteBool=false;
					break;
				case Keyboard.DOWN:
					_atrasBool=false;
					break;
				case Keyboard.LEFT:
					_izquierdaBool = false;
					break;
				case Keyboard.RIGHT:
					_derechaBool = false;
					break;
				case Keyboard.SPACE:
					_breakingForce = 0;
			}
		}
		
		
        /**
         * Initialise the engine
         */
        private function initEngine():void
		{
           
            
			//create the view
            _view = new View3D();
			_view.backgroundColor = 0x333338;
			_view.mouseEnabled=true;
             _view.mouseChildren=true;
			_view.doubleClickEnabled=true;
			_view.forceMouseMove = true;
            addChild(_view);
            
		
            
			// init the physics world
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			
			debugDraw = new AWPDebugDraw(_view, physicsWorld); 
			debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
			
			Parsers.enableAllBundled();
			
		
			var bmd:BitmapData = new SeleccionaImage().bitmapData;
			_view.background=new BitmapTexture(bmd);
			
			
		
            //add stats
            addChild(_stats = new AwayStats(_view, true, true));
        }
		
		private function agregarTerreno():void{
		
		
			
			var terrainMethod : TerrainDiffuseMethod = new TerrainDiffuseMethod([new BitmapTexture(new Beach().bitmapData),new BitmapTexture(new Grass().bitmapData), new BitmapTexture(new Rock().bitmapData)], new BitmapTexture(new Blend().bitmapData) , [1,150, 100, 50]);
			
			var bmaterial : TextureMaterial = new TextureMaterial(new BitmapTexture(new Albedo().bitmapData));
			bmaterial.diffuseMethod = terrainMethod;
			bmaterial.normalMap = new BitmapTexture(new Normals().bitmapData);
			bmaterial.ambientColor = 0x202030;
			bmaterial.specular = .2;
			
			// create the terrain mesh
			var terrainBMD : Bitmap = new HeightMap();
			var terrain : AWPTerrain = new AWPTerrain(bmaterial, terrainBMD.bitmapData, 50000, 1200, 50000, 60, 60, 1200, 0, false);
			_view.scene.addChild(terrain);
			
			// create the terrain shape and rigidbody
			var terrainShape : AWPHeightfieldTerrainShape = new AWPHeightfieldTerrainShape(terrain);
			var terrainBody : AWPRigidBody = new AWPRigidBody(terrainShape, terrain, 0);
			physicsWorld.addRigidBody(terrainBody);
			
			

		
			_plane = new Mesh(new PlaneGeometry(1700,1700));
			
			var groundShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape, _plane, 0);
			physicsWorld.addRigidBody(groundRigidbody);
			
			//_view.scene.addChild(_plane);
			
			var material : ColorMaterial = new ColorMaterial(0xfc6a11);
			material.lightPicker = lightPicker;
			
			// create rigidbody shapes
			var boxShape : AWPBoxShape = new AWPBoxShape(200, 200, 200);
			var cylinderShape : AWPCylinderShape = new AWPCylinderShape(100, 200);
			var coneShape : AWPConeShape = new AWPConeShape(100, 200);
			
			// create rigidbodies
			var mesh : Mesh;
			// var shape:AWPShape;
			var body : AWPRigidBody;
			for (var i : int = 0; i < 10; i++ ) {
				// create boxes
				mesh = new Mesh(new CubeGeometry(200, 200, 200), material);
				_view.scene.addChild(mesh);
				body = new AWPRigidBody(boxShape, mesh, 1);
				body.position = new Vector3D(-5000 + 10000 * Math.random(), 1000 + 1000 * Math.random(), -5000 + 10000 * Math.random());
				physicsWorld.addRigidBody(body);
				
				// create cylinders
				mesh = new Mesh(new CylinderGeometry(100, 100, 200), material);
				_view.scene.addChild(mesh);
				body = new AWPRigidBody(cylinderShape, mesh, 1);
				body.position = new Vector3D(-5000 + 10000 * Math.random(), 1000 + 1000 * Math.random(), -5000 + 10000 * Math.random());
				physicsWorld.addRigidBody(body);
				
				// create the Cones
				mesh = new Mesh(new ConeGeometry(100, 200), material);
				_view.scene.addChild(mesh);
				body = new AWPRigidBody(coneShape, mesh, 1);
				body.position = new Vector3D(-5000 + 10000 * Math.random(), 1000 + 1000 * Math.random(), -5000 + 10000 * Math.random());
				physicsWorld.addRigidBody(body);
			}
			
			
		
		
		
		
		
		
		}
		
		private function initKeyBoard():void{
		
		
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		
		
		
		
		}
		
		
		/**
         * Create an instructions overlay
         */
      
		
		
		private function initText():void
		{
			text = new TextField();
			text.defaultTextFormat = new TextFormat("Verdana", 55, 0xFFFFFF);
			text.width = 1000;
			text.height = 200;
			text.x = 5;
			text.y = 100;
			text.selectable = false;
			text.mouseEnabled = false;
			text.text = "Selecciona un tanque:";
			text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(text);
		
		}
        
        /**
         * Initialise the listeners
         */
        private function initListeners():void
		{
            //add render loop
			
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
            //navigation
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
            //add resize event
           
        }
		
		private function onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.MESH){
			
				
				var mesh:Mesh = event.asset as Mesh;
				
				if (mesh) {
					if (mesh.name == "Main_Body_2") {
						Main_Body_2 = mesh;
						
					}
					if (mesh.name == "Main_Body") {
						Main_Body = mesh;
						
					}
					if (mesh.name == "Turret") {
						Turret = mesh;
						
					}
					if (mesh.name == "gun") {
						gun = mesh;
						
					}
			
					
				}
			
			
			
			
			
			}
			trace(event.asset.name);
		}
		
        /**
         * Render loop
         */
        private function onEnterFrame(event:Event):void
		{

				
			if( _atrasBool==true ) 
				carBody.position = carBody.position.subtract(carBody.worldTransform.rotationWithMatrix.transformVector(new Vector3D(0,0,10)));
			
			if( _adelanteBool==true ) 
				carBody.position = carBody.position.add(carBody.worldTransform.rotationWithMatrix.transformVector(new Vector3D(0,0,10)));
				
				
				

			if(_izquierdaBool==true){
				
					carBody.rotation=new Vector3D(5,_rotacion,5);
					
					_rotacion ++;

			}
			
			
			if(_derechaBool==true){
				carBody.rotation=new Vector3D(5,_rotacion,5);
				_rotacion --;
				
			}
			
			if(EscojerM==true){
				
				t29rotacion ++;
				auxContinerT90.rotationY ++;
				
			loader2.rotationY ++;
			}
			
			
			physicsWorld.step(timeStep);
			
            //update camera controler
          //  _cameraController.update();
		if(carBody){
			_view.camera.position =carBody.position.add(new Vector3D(0, 700, -1500));
			_view.camera.lookAt(carBody.position);
		}
			debugDraw.debugDrawWorld();
            //update view
            _view.render();
        }
    
		
		private function onAddstage(event:Event=null):void{
		
			
			
			
		
		}
		
		
        /**
         * stage listener and mouse control
         */
        private function onResize(event:Event=null):void
		{
            _view.width = stage.stageWidth;
            _view.height = stage.stageHeight;
            _stats.x = stage.stageWidth - _stats.width;
			
			
		
			
          
        }
        
   
      
        
      
    }
}
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.setInterval;

import caurina.transitions.Tweener;

class FontMvc extends Sprite
{
	[SWF(frameRate = "60", backgroundColor = "#000000")]
	
	private var textField:TextField;
	
	
	
	[Embed(source="assets/fonts/counter_strike.ttf",
        fontName = "myFont",
        mimeType = "application/x-font",
        advancedAntiAliasing="true",
        embedAsCFF="false")]
	private var myEmbeddedFont:Class;
	[Embed(source="assets/fonts/counter_strike.ttf", fontName = "strike", mimeType="application/x-font")]
	private var strike:Class;
	private var Main:*;
	
	
	public function FontMvc(texto:String,color:Number,tam:Number,btmod:Boolean)
	{
		
		
		
		textField = new TextField();
		textField.defaultTextFormat = new TextFormat("myFont", tam, color);
		textField.width=800;
		textField.embedFonts = true;
		textField.text = texto;
		
		if(btmod){
			textField.addEventListener(MouseEvent.MOUSE_OVER,encimaM);
			textField.addEventListener(MouseEvent.MOUSE_OUT,salidaM);
			textField.addEventListener(MouseEvent.CLICK,Click);
		}
		
		setInterval(timerListener,10000);
		Tweener.addTween(this, {alpha:1, time:3, transition:"linear"});
		addChild(textField);
		
	}
	
	private function encimaM(e:MouseEvent):void{
		
		
		textField.textColor=0x000000;
	}
	
	
	private function salidaM(e:MouseEvent):void{
		
		textField.textColor=0x0066FF;
		
	}
	
	private function Click(e:MouseEvent):void{
		Main.DestruyeIntro();
	}
	
	public function set Mainstage(Main:*):void
	{
		
		this.Main=Main;
	
	
	}
	
	private function timerListener ():void{
		
		Tweener.addTween(this, {x:300, time:3, delay:3, transition:"linear", onComplete:function() { Tweener.addTween(this, {x:0, time:3, delay:3, transition:"linear"}); }});
		
		
		
	}
}