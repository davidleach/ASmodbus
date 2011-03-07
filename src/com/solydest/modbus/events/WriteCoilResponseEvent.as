package com.solydest.modbus.events
{
	import flash.events.Event;

	/**
	 * Results is an array where the first element is the output address of the 
	 * write request and the second element is the value written.
	 *   
	 * @author leachd
	 * 
	 */
	public class WriteCoilResponseEvent extends ModbusResponseEvent
	{
		public function WriteCoilResponseEvent(transactionId:int, results:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(transactionId, results, ModbusResponseEvent.WRITE_COIL, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new WriteCoilResponseEvent(transactionId, results, bubbles, cancelable);
		}
	}
}