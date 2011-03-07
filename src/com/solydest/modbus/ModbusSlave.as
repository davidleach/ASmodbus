package com.solydest.modbus
{
	import com.solydest.modbus.events.ReadCoilsResponseEvent;
	import com.solydest.modbus.events.ReadInputDiscretesResponseEvent;
	import com.solydest.modbus.events.ReadInputRegistersResponseEvent;
	import com.solydest.modbus.events.ReadMultipleRegistersResponseEvent;
	import com.solydest.modbus.events.ReadStringResponseEvent;
	import com.solydest.modbus.events.WriteCoilResponseEvent;
	import com.solydest.modbus.events.WriteMultipleRegistersResponseEvent;
	import com.solydest.modbus.events.WriteStringResponseEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * Represents a single Modbus Slave device.  This class contains methods which implement
	 * all of the Class 0 and Class 1 Modbus function codes.  Responses from the slave
	 * device will be dispatched as one of the events defined in com.solydest.modbus.events.ModbusResponseEvent.
	 * 
	 * When making a read or write request to a slave device you can optionally include a
	 * transaction ID.  If provided, the response event will also contain that transaction Id
	 * to assist the user of this class in managing multiple requests.
	 *  
	 * @author leachd
	 * 
	 */	
	public class ModbusSlave extends EventDispatcher implements IModbusSlave
	{
		// private properties
		private var regExIp:RegExp = /^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$/;
		private var socket:Socket;
		private var slaveIp:String;
		private var slavePort:int;
		private var slaveId:int;
		private var sendBuffer:Array; // a FIFO buffer of requests waiting to be sent
		
		private var requestTimer:Timer;
		
		// protected properties
		
		
		// public properties
		
		
		/**
		 * Class Constructor
		 *  
		 * @param ip  IP address of the slave device.
		 * @param port  If supplied, must be between 1 - 65535.
		 * @param deviceId  If supplied, must be between 0 - 255.  Represents Modbus Slave Device ID.
		 * 
		 */			
		public function ModbusSlave(ip:String, port:int = 502, deviceId:int = 0)
		{
			super();
			
			this.requestTimer = new Timer(50);
			this.requestTimer.addEventListener(TimerEvent.TIMER, processSendBuffer, false, 0, true);
			this.requestTimer.start();
			
			this.sendBuffer = new Array();
			
			if(!regExIp.test(ip))
				throw new Error("Invalid IP address specified.  Check format.");
			else
				this.slaveIp = ip;
			if(port < 0 || port > 65535)
				throw new Error("Invalid port specified.  Provide a port between 1 - 65535.");
			else
				this.slavePort = port;
			if(deviceId < 0 || deviceId > 255)
				throw new Error("Invalid device ID specified.  Provide a device ID between 0 - 255.");
			else
				this.slaveId = deviceId;
			
			if(this.slaveIp != null && this.slavePort > 0)
			{
				this.socket = new Socket(this.slaveIp, this.slavePort);
				this.socket.addEventListener(Event.CONNECT, handler_SocketConnect, false, 0, true);
				this.socket.addEventListener(IOErrorEvent.IO_ERROR, handler_SocketIoError, false, 0, true);
				this.socket.addEventListener(ProgressEvent.SOCKET_DATA, handler_SocketData, false, 0, true);
				this.socket.addEventListener(Event.CLOSE, handler_SocketClose, false, 0, true);
				this.socket.connect(this.slaveIp, this.slavePort);
			}		
		}
		
		
		//////////////////////////////////////////////////////
		//
		//	Class Public Interface Methods
		//
		/////////////////////////////////////////////////////
		
		/**
		 * Provides functionality for Modbus function code 3,
		 * Read Holding Registers
		 *  
		 * @param startingAddress	An address starting range of 400000 is assumed so a startingAddress of 1 is equivalent to 400001
		 * @param quantity
		 * @return 
		 * 
		 */		
		public function readMultipleRegisters(startingAddress:int, quantity:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 6, 3);
			reqData.push((startingAddress - 1) >> 8);	// starting address upper
			reqData.push((startingAddress - 1) & 255);	// starting address lower
			reqData.push(quantity >> 8);				// quantity upper
			reqData.push(quantity & 255);				// quantity lower
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Modbus function code 16,
		 * Write Multiple Regisers
		 * 
		 * @param startingAddress
		 * @param values
		 * @param transactionId
		 * @return void
		 */		
		public function writeMultipleRegisters(startingAddress:int, values:Array, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 7 + (2 * values.length), 16);
			reqData.push(startingAddress >> 8);			// starting address upper
			reqData.push(startingAddress & 255);		// starting address lower
			reqData.push(values.length >> 8);			// Quantity of registers upper
			reqData.push(values.length & 255);			// Quantity of registers lower
			reqData.push(values.length * 2);			// Byte Count (2 bytes per register)
			for(var i:int = 0; i < values.length; i++)
			{
				reqData.push(values[i] >> 8);			// Register value upper byte
				reqData.push(values[i] & 255);			// Register value lower byte
			}
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Modbus function code 1,
		 * Read Coils
		 *  
		 * @param startingAddress
		 * @param quantity
		 * @param transactionId
		 * @return void
		 * 
		 */		
		public function readCoils(startingAddress:int, quantity:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 6, 1);
			reqData.push(startingAddress >> 8); 		// starting address upper
			reqData.push(startingAddress & 255); 		// starting address lower
			reqData.push(quantity >> 8); 				// quantity upper
			reqData.push(quantity & 255); 				// quantity lower
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Modbus function code 2, 
		 * Read Discrete Inputs
		 * 
		 * @param startingAddress
		 * @param quantity
		 * @param transactionId
		 * @return void
		 * 
		 */		
		public function readInputDiscretes(startingAddress:int, quantity:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 6, 2);
			reqData.push(startingAddress >> 8);			// starting address upper
			reqData.push(startingAddress & 255);		// starting address lower
			reqData.push(quantity >> 8);				// quantity upper
			reqData.push(quantity & 255);				// quantity lower
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Modbus function code 4, 
		 * Read Input Registers
		 * 
		 * @param startingAddress
		 * @param quantity
		 * @param transactionId
		 * @return void 
		 * 
		 */		
		public function readInputRegisters(startingAddress:int, quantity:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 6, 4);
			reqData.push(startingAddress >> 8);			// starting address upper
			reqData.push(startingAddress & 255);		// starting address lower
			reqData.push(quantity >> 8);				// quantity upper
			reqData.push(quantity & 255);				// quantity lower
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Modbus function code 5, 
		 * Write Single Coil
		 * 
		 * @param address
		 * @param value
		 * @param transactionId
		 * @return void
		 * 
		 */		
		public function writeCoil(address:int, value:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 6, 5);
			reqData.push(address >> 8);					// address upper
			reqData.push(address & 255);				// address lower
			reqData.push(value >> 8);					// value upper
			reqData.push(value & 255);					// value lower
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides funcitonality for Modbus function code 6, 
		 * Write Single Register
		 * 
		 * @param address
		 * @param value
		 * @param transactionId
		 * @return void
		 * 
		 */		
		public function writeRegister(address:int, value:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 6, 6);
			reqData.push(address >> 8);					// address upper
			reqData.push(address & 255);				// address lower
			reqData.push(value >> 8);					// value upper
			reqData.push(value & 255);					// value lower
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Custom Modbus function code 114 (0x72), 
		 * String Read.
		 * 
		 * Custom command frame is formatted as:
		 * [Bytes]	[Function]
		 *   2		Transaction ID
		 *   2		Protocol ID
		 *   2		Frame Size
		 *   1		Device ID
		 *   1		Function Code (0x72)
		 *   2		String Index
		 * 
		 * Reply frame is formatted as:
		 * [Bytes]	[Function]
		 *   2		Transaction ID
		 *   2 		Protocol ID
		 *   2		Frame Size
		 *   1		Device ID
		 *   1		Function Code (0x72)
		 *   2		String Index
		 *   ~		String Data (limited by frame size)
		 *  
		 * @param index
		 * @param transactionId
		 * 
		 */		
		public function readString(index:int, transactionId:int = 0):void
		{
			var reqData:Array = buildHeader(transactionId, 4, 114);
			reqData.push(index >> 8);					// string index upper byte
			reqData.push(index & 255);					// string index lower byte
			this.sendBuffer.push(reqData);
		}
		
		/**
		 * Provides functionality for Custom Modbus function code 115 (0x73),
		 * String Write.
		 * 
		 * Custom command frame is formatted as:
		 * [Bytes]	[Function]
		 *   2		Transaction ID
		 *   2		Protocol ID
		 *   2		Frame Size
		 *   1		Device ID
		 *   1		Function Code (0x73)
		 *   2		String Index
		 *   ~		STring Data (limited by frame size)
		 * 
		 * Reply frame is formatted as:
		 * [Bytes]	[Function]
		 *   2		Transaction ID
		 *   2 		Protocol ID
		 *   2		Frame Size
		 *   1		Device ID
		 *   1		Function Code (0x73)
		 *  
		 * @param index
		 * @param value
		 * @param transactionId
		 * 
		 */		
		public function writeString(index:int, value:String, transactionId:int = 0):void
		{
			var newValue:String = value;
			var reqData:Array = buildHeader(transactionId, 5 + value.length, 115);	// the length includes the null terminator for the string
			reqData.push(index >> 8);												// string index upper byte
			reqData.push(index & 255);												// string index lower byte
			for (var i:int = 0; i < value.length; i++)
			{
				reqData.push(value.charCodeAt(i));									// convert string to array of ascii bytes
			}
			reqData.push(0x00);														// null terminator
			this.sendBuffer.push(reqData);
		}
		
		//////////////////////////////////////////////////////
		//
		//	Private Class Methods
		//
		/////////////////////////////////////////////////////
		
		/**
		 * @private
		 * 
		 * Builds the common part of the Modbus header for each of the Modbus function
		 * codes.
		 *  
		 * @param transactionId
		 * @param length
		 * @param functionCode
		 * @return 
		 * 
		 */		
		private function buildHeader(transactionId:int, length:int, functionCode:int):Array
		{
			var headerData:Array = new Array();
			headerData.push(transactionId >> 8);		// transaction ID upper
			headerData.push(transactionId & 255); 		// transaction ID lower
			headerData.push(0); 						// protocol upper
			headerData.push(0); 						// protocol lower
			headerData.push(0); 						// length upper	
			headerData.push(length);					// length lower
			headerData.push(this.slaveId);				// device ID
			headerData.push(functionCode);				// function code
			return headerData;
		}
		
		/**
		 * @private
		 * 
		 * Checks to see if there is data to send.  If so, it makes a socket
		 * connection using the ip/port provided in the Class constructor. 
		 * 
		 */		
		private function processSendBuffer(event:TimerEvent):void
		{
			if(thereIsDataToSend)
			{
				if(!this.socket.connected)
				{
					this.socket.connect(this.slaveIp, this.slavePort);
				}
				var data:Array = this.sendBuffer.shift(); // grab next request from the FIFO buffer
				for(var i:int = 0; i < data.length; i++)
				{
					socket.writeByte(data[i]);
				}
				socket.flush();
			}
		}
		
		
		//////////////////////////////////////////////////////
		//
		//	Socket Event Handlers
		//
		/////////////////////////////////////////////////////
		
		/**
		 * @private
		 * 
		 * Handles the event dispatched when the socket first connects to the server.
		 *  
		 * @param event
		 * 
		 */		
		private function handler_SocketConnect(event:Event):void
		{
			// do nothing
		}
		
		/**
		 * @private
		 * 
		 * Handles the event dispatched from an IO error with the socket.
		 *  
		 * @param event
		 * 
		 */		
		private function handler_SocketIoError(event:IOErrorEvent):void
		{
			dispatchEvent(event);	// bubble the event up the chain
		}
		
		/**
		 * @private
		 * 
		 * Handles the event dispatched when the socket receives data from the server.
		 * This function unpacks the bytes returned from a modbus call into
		 * the standard Modbus items such as transaction ID, device ID, length, etc.
		 * and then formats the returned data according to the fuction code.
		 *  
		 * @param event
		 * 
		 */		
		private function handler_SocketData(event:ProgressEvent):void
		{
			var rcvData:ByteArray = new ByteArray();
			event.target.readBytes(rcvData, 0, event.target.bytesAvailable);
			var transactionId:int = (rcvData[0] * 256) + rcvData[1];
			var protocol:int = (rcvData[2] * 256) + rcvData[3];
			var length:int = (rcvData[4] * 256) + rcvData[5];
			var deviceId:int = rcvData[6];
			var functionCode:int = rcvData[7];
			var retData:Array = new Array();
			var results:Array = new Array();  	// holds the results to be sent back to calling class
			var i:int; 							// counter variable
			for(i = 0; i < length - 2; i++)
				retData.push(rcvData[i + 8]);
			var byteCount:int;
			
			/* from this point forward the data returned will depend on the function code */
			switch(functionCode)
			{
				case 1: // read coils
					byteCount = retData.shift();
					/*	turn the returned bytes into an array of bit results
						where the first element in the array is the first coil 
						requested.  The length of the array will be equal to the
						number of requested coils padded with 0's to add up to a 
						value divisible by 8  */
					for(i = 0; i < byteCount; i++)
					{
						results.push(retData[i] & 1);			// LSB of the byte is lowest numbered coil of the byte
						results.push((retData[i] >> 1) & 1);	// value of bit 2 
						results.push((retData[i] >> 2) & 1);	// value of bit 3 
						results.push((retData[i] >> 3) & 1);	// etc. 
						results.push((retData[i] >> 4) & 1);
						results.push((retData[i] >> 5) & 1);
						results.push((retData[i] >> 6) & 1);
						results.push((retData[i] >> 7) & 1);
					}	
					dispatchEvent(new ReadCoilsResponseEvent(transactionId, results));
					break;
				case 2: // read input discretes
					byteCount = retData.shift();
					for(i = 0; i < byteCount; i++)
					{
						results.push(retData[i] & 1);			// LSB of the byte is lowest numbered coil of the byte
						results.push((retData[i] >> 1) & 1);	// value of bit 2 
						results.push((retData[i] >> 2) & 1);	// value of bit 3 
						results.push((retData[i] >> 3) & 1);	// etc. 
						results.push((retData[i] >> 4) & 1);
						results.push((retData[i] >> 5) & 1);
						results.push((retData[i] >> 6) & 1);
						results.push((retData[i] >> 7) & 1);
					}
					dispatchEvent(new ReadInputDiscretesResponseEvent(transactionId, results));
					break;
				case 3: // read multiple registers
					byteCount = retData.shift();				// Quantity of registers * 2 (each register is 2 bytes)
					
					/*	combine the high and low bytes of each register into a
						single value and push it into the results array so that
						results will contain a single entry for each register */
					for(i = 0; i < byteCount; i += 2)
					{
						results.push((retData[i] * 256) + retData[i + 1]);
					}
					dispatchEvent(new ReadMultipleRegistersResponseEvent(transactionId, results));
					break;
				case 4: // read input registers
					byteCount = retData.shift();				// Quantity of regisers * 2 (each register is 2 bytes)
					
					/* processing is same as for case 3 above */
					for(i = 0; i < byteCount; i += 2)
					{
						results.push((retData[i] * 256) + retData[i + 1]);
					}
					dispatchEvent(new ReadInputRegistersResponseEvent(transactionId, results));
					break;
				case 5: // write coil
					results.push((retData.shift() * 256) + retData.shift());	// the output address
					results.push((retData.shift() * 256) + retData.shift());	// the value written
					dispatchEvent(new WriteCoilResponseEvent(transactionId, results));
					break;
				case 6: // write register
					results.push((retData.shift() * 256) + retData.shift());	// the register address
					results.push((retData.shift() * 256) + retData.shift());	// the value written
					break;
				case 16: // write mulitple registers
					results.push((retData.shift() * 256) + retData.shift());	// the starting address
					results.push((retData.shift() * 256) + retData.shift());	// quantity of registers
					dispatchEvent(new WriteMultipleRegistersResponseEvent(transactionId, results));
					break;
				case 114: // read string
					var stringIndex:int;
					stringIndex = ((retData.shift() * 256) + retData.shift());
					if (stringIndex == 4)		// the returned data format is raw bytes
					{
						for (i = 0; i < retData.length; i++)
						{
							results.push(retData[i]);
						}
							
					}
					else if (stringIndex == 5)	// the returned data is a number
					{
						results.push(retData.shift());	// this assumes that the number returned is one byte in length
					}
					else						// the returned data is a string
					{
						for (i = 0; i < retData.length; i++)
						{
							results.push(String.fromCharCode(retData[i]));			// convert the ascii codes into characters
						}
					}
					
					dispatchEvent(new ReadStringResponseEvent(transactionId, results, stringIndex));
					break;
				case 115: // write string
					results.push(functionCode);
					dispatchEvent(new WriteStringResponseEvent(transactionId, results));
					break;
				case 129: // read coils error
					
					break;
				case 130: // read discrete inputs error
					
					break;
				case 131: // read multiple registers error
					
					break;
				case 132: // read input registers error
					
					break;
				case 133: // write coil error
					
					break;
				case 134: // write register error
					
					break;
				case 144: // write multiple registers error
					
					break;
				case 242: // read string error
					
					break;
				case 243: // write string error
					
					break;
				default:
					break;
			}
			
		}
		
		/**
		 * @private
		 * 
		 * Handles the event dispatched when the socket disconnects from the server.
		 *  
		 * @param event
		 * 
		 */		
		private function handler_SocketClose(event:Event):void
		{
			// do nothing
		}
	
		
		//////////////////////////////////////////////////////
		//
		//	Property Getters and Setters
		//
		/////////////////////////////////////////////////////
		
		private function get thereIsDataToSend():Boolean
		{
			if(this.sendBuffer.length > 0)
				return true;
			else
				return false;
		}
		
		
	}
}