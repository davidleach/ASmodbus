package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array of bits.  The first input in the request is the first element in the
	 * array.  If the requested number of inputs % 8 is greater than zero, the result will 
	 * be padded with 0's until the length of the array % 8 is 0;
	 *   
	 * 
	 */	
	public class ReadInputDiscretesResponseEvent extends ModbusResponseEvent
	{
		public function ReadInputDiscretesResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.READ_INPUT_DISCRETES, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ReadInputDiscretesResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}