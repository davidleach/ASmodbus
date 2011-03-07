package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array where the first element is the output address of the 
	 * write request and the second element is the value written.
	 *   
	 * 
	 */
	public class WriteRegisterResponseEvent extends ModbusResponseEvent
	{
		public function WriteRegisterResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.WRITE_REGISTER, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new WriteRegisterResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}