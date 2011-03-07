package com.solydest.modbus.events
{
	import flash.events.Event;
	
	/**
	 * Base class for all Modbus response event types.  This event type should not be listened
	 * for directly.  Use one of the events derived from this one.  It does contain the 
	 * public static constants which define the available response event types.  Use these 
	 * constants when adding an event listener for a specific Modbus response event i.e. -
	 * [some object].addEventListener(ModbusResponseEvent.READ_COILS, readCoils_ResultHandler, false, 0, true);
	 *   
	 * @author leachd
	 * 
	 */	
	public class ModbusResponseEvent extends Event
	{
		public static const READ_COILS:String = "readCoilsResponseEvent";
		public static const READ_MULTIPLE_REGISTERS:String = "readMultipleRegistersResponseEvent";
		public static const WRITE_MULTIPLE_REGISTERS:String = "writeMultipleRegistersResponseEvent";
		public static const READ_INPUT_DISCRETES:String = "readInputDiscretesResponseEvent";
		public static const READ_INPUT_REGISTERS:String = "readInputRegistersResponseEvent";
		public static const WRITE_COIL:String = "writeCoilResponseEvent";
		public static const WRITE_REGISTER:String = "writeRegisterResponseEvent";
		public static const READ_STRING:String = "readStringResponseEvent";
		public static const WRITE_STRING:String = "writeStringResponseEvent";
		
		public var transactionId:int;
		public var results:Array;
		
		public function ModbusResponseEvent(transactionId:int, results:Array, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.transactionId = transactionId;
			this.results = results;
		}
		
		override public function clone():Event
		{
			return new ModbusResponseEvent(transactionId, results, type, bubbles, cancelable);
		}
	}
}