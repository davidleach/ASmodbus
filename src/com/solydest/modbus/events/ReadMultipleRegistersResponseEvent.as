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
	public class ReadMultipleRegistersResponseEvent extends ModbusResponseEvent
	{
		public function ReadMultipleRegistersResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.READ_MULTIPLE_REGISTERS, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ReadMultipleRegistersResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}