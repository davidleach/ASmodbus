package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array of bits.  The first coil in the request is the first element in the
	 * array.  If the requested number of coils % 8 is greater than zero, the result will 
	 * be padded with 0's until the length of the array % 8 is 0;
	 * 
	 * 
	 */	
	public class ReadCoilsResponseEvent extends ModbusResponseEvent
	{
		public function ReadCoilsResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.READ_COILS, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ReadCoilsResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}