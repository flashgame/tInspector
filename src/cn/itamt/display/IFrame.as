package cn.itamt.display 
{
	import cn.itamt.utils.Debug;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * iframe, 用于在Flash当"嵌入"网页
	 * @author tamt
	 */
	public class IFrame extends tSprite 
	{
		private var _w:uint, _h:uint;
		private var _scrollPosition:Point;
		private var _globalPosition:Point;
		private var _builded:Boolean;
		
		private var _src:String;
		private var _id:String = "FlashIFrame";
		private var _scrolling:String = "";
		
		public function IFrame(id:String, w:uint, h:uint)
		{
			_id = id;
			_w = w;
			_h = h;
			
			super();
		}
		
		override public function set x(val:Number):void {
			super.x = val;
			this.relayout();
		}
		
		override public function set y(val:Number):void {
			super.y = val;
			this.relayout();
		}
		
		override public function set width(val:Number):void {
			_w = val;
			this.relayout();
		}
		override public function get width():Number {
			return _w;
		}
		
		override public function set height(val:Number):void {
			_h = val;
			this.relayout();
		}
		override public function get height():Number {
			return _h;
		}
		
		public function set scrollPosition(pos:Point):void {
			_scrollPosition = pos;
			if (_builded) {
				if (ExternalInterface.available) {
					ExternalInterface.call(JSScripts.setScrollPosition, _id, pos.x*100, pos.y*100);
				}
			}
		}
		
		public function get scrollPosition():Point {
			return _scrollPosition;
		}
		
		override protected function onRemoved():void 
		{
			removeIFrame();
		}
		
		override protected function onAdded():void 
		{
			this.buildBg();
			if (_src) buildIFrame();
			
			this.relayout();
		}
		
		private function relayout():void {
			this.buildBg();
			
			_globalPosition = localToGlobal(new Point);
			
			if (_builded) {
				if (ExternalInterface.available) {
					ExternalInterface.call(JSScripts.setPosition, _id, _globalPosition.x, _globalPosition.y);
					ExternalInterface.call(JSScripts.setSize, _id, _w, _h);
				}
			}
		}
		
		private function buildBg():void {
			this.graphics.clear();
			this.graphics.beginFill(0x0, .8);
			this.graphics.drawRect(0, 0, _w, _h);
			this.graphics.endFill();
		}
		
		/**
		 * 设置iframe的src
		 */
		public function get src():String 
		{
			return _src;
		}
		public function set src(value:String):void 
		{
			_src = value;
			if (_inited) {
				if (!_builded) buildIFrame();
				if (ExternalInterface.available) {
					ExternalInterface.call(JSScripts.setSrc, _id, _src);
				}
			}
		}
		
		public function get id():String 
		{
			return _id;
		}
		
		public function set id(value:String):void 
		{
			_id = value;
		}
		
		public function get scrolling():String 
		{
			return _scrolling;
		}
		
		public function set scrolling(value:String):void 
		{
			_scrolling = value;
			if (_builded) {
				if (ExternalInterface.available) {
					ExternalInterface.call(JSScripts.setScrolling, _id, _scrolling);
				}
			}
		}
		
		private function buildIFrame():void {
			if (_builded) return;
			_builded = true;
			
			_globalPosition = localToGlobal(new Point);
			
			if (ExternalInterface.available) {
				ExternalInterface.call(JSScripts.buildIFrame, _id);
				ExternalInterface.call(JSScripts.setPosition, _id, _globalPosition.x, _globalPosition.y);
				ExternalInterface.call(JSScripts.setSize, _id, _w, _h);
				ExternalInterface.call(JSScripts.setScrolling, _id, _scrolling);
			}
		}
		
		private function removeIFrame():void 
		{
			_builded = false;
		}
	}

}

internal class JSScripts
{
	public static var buildIFrame:XML = new XML(
		<script>
				<![CDATA[
				function(id, w, h) {
					var iframe = document.createElement("iframe");
					iframe.style.position = "absolute";
					iframe.style.zIndex = 2;
					iframe.id = id;
					document.body.appendChild(iframe);
				}
				]]>
		</script>
	);
	
	public static var setSrc:XML = new XML(
		<script>
				<![CDATA[
				function(id, src) {
					var iframe = document.getElementById(id);
					iframe.src = src;
				}
				]]>
		</script>
	);
	
	public static var setPosition:XML = new XML(
		<script>
				<![CDATA[
				function(id, x, y) {
					var iframe = document.getElementById(id);
					iframe.style.left = x;
					iframe.style.top = y;
				}
				]]>
		</script>
	);
	
	public static var setSize:XML = new XML(
		<script>
				<![CDATA[
				function(id, w, h) {
					var iframe = document.getElementById(id);
					iframe.width = w;
					iframe.height = h;
				}
				]]>
		</script>
	);
	
	public static var setScrolling:XML = new XML(
		<script>
				<![CDATA[
				function(id, scrolling) {
					var iframe = document.getElementById(id);
					iframe.scrolling = scrolling;
				}
				]]>
		</script>
	);
	
	public static var setScrollPosition:XML = new XML(
		<script>
				<![CDATA[
				function(id, x, y) {
					var iframe = getFrameDocument(document.getElementById(id));
					iframe.body.scrollLeft = x * 100;
					iframe.body.scrollTop = y * 100;

					function getFrameDocument(iframe_object){
						if(iframe_object.contentDocument){
							return iframe_object.contentDocument;
						}else if(iframe_object.contentWindow){
							return iframe_object.contentWindow.document;
						}else{
							return iframe_object.document;
						}
					}
				}
				
				
				]]>
		</script>
	);
	
}