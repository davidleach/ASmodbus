package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results array should contain only one entry.  That entry will be the function code
	 * returned from the request.
	 * 
	 * Function code 0x73 = successful write
	 * Function code 0xF3 = failed write
	 *   
	 * @author leachd
	 * 
	 */	
	public class WriteStringResponseEvent extends ModbusResponseEvent
	{
		public function WriteStringResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.WRITE_STRING, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new WriteStringResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}