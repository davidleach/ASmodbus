package com.solydest.modbus
{

	internal interface IModbusSlave
	{
		// Modbus Class 0 function codes
		function readMultipleRegisters(startingAddress:int, quantity:int, transactionId:int = 0):void; // fc 3
		function writeMultipleRegisters(startingAddress:int, values:Array, transactionId:int = 0):void; // fc 16
		
		// Modbus Class 1 function codes		
		function readCoils(startingAddress:int, quantity:int, transactionId:int = 0):void; // fc 1
		function readInputDiscretes(startingAddress:int, quantity:int, transactionId:int = 0):void; // fc 2
		function readInputRegisters(startingAddress:int, quantity:int, transactionId:int = 0):void; // fc 4
		function writeCoil(address:int, value:int, transactionId:int = 0):void; // fc 5		
		function writeRegister(address:int, value:int, transactionId:int = 0):void; // fc 6		
	}
}