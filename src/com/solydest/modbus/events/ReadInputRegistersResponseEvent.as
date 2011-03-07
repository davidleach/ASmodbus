package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array of register values.  The first entry in the array is the 
	 * register at the starting address of the request.
	 *   
	 * @author leachd
	 * 
	 */
	public class ReadInputRegistersResponseEvent extends ModbusResponseEvent
	{
		public function ReadInputRegistersResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.READ_INPUT_REGISTERS, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ReadInputRegistersResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}