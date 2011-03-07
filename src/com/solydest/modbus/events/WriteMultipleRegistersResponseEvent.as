package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array where the first element is the starting address of the 
	 * write request and the second element is the quantity of registers written.
	 *   
	 * 
	 */	
	public class WriteMultipleRegistersResponseEvent extends ModbusResponseEvent
	{
		public function WriteMultipleRegistersResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.WRITE_MULTIPLE_REGISTERS, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new WriteMultipleRegistersResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}