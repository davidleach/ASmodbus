package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array of bytes that make up the string from the requested index.
	 * StringResult is a string made by concatenating the bytes in the Results array.
	 *   
	 * @author leachd
	 * 
	 */	
	public class ReadStringResponseEvent extends ModbusResponseEvent
	{
		public var stringIndex:int;
		
		public function ReadStringResponseEvent(transactionId:int, results:Array, stringIndex:int = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.READ_STRING, bubbles, cancelable);
			this.stringIndex = stringIndex;
		}
		
		override public function clone():Event
		{
			return new ReadStringResponseEvent(transactionId, results, this.stringIndex, bubbles, cancelable);
		}
		
		public function get stringResult():String
		{
			return results.join("");
		}
	}
}