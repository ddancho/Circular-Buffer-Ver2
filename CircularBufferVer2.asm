format PE console 6.0
entry main
include 'win32ax.inc'

BUFFER_SIZE = 10

struct Buffer
	first		dd	?
	last		dd	?
	items		dd	?
	bufferData	dd	BUFFER_SIZE	dup	?
ends

section '.code' code readable executable
main:
	
	ccall Main
	invoke ExitProcess,eax
	
	proc Main c
	local buffer:Buffer
	local adrBuffer:DWORD
	
		lea eax,[buffer]
		mov [adrBuffer],eax
		
		cinvoke printf,<'init...',13,10,0>
		ccall init,[adrBuffer]
		
		cinvoke printf,<'putting some values in the buffer...',13,10,0>
		ccall put,[adrBuffer],1
		ccall put,[adrBuffer],2
		ccall put,[adrBuffer],3
		ccall put,[adrBuffer],4
		ccall put,[adrBuffer],5
		ccall put,[adrBuffer],6
		ccall put,[adrBuffer],7
		ccall put,[adrBuffer],8
		ccall put,[adrBuffer],9
		ccall put,[adrBuffer],10
		ccall print,[adrBuffer]
		
		cinvoke printf,<'ups...',13,10,0>
		ccall put,[adrBuffer],11
		
		cinvoke printf,<'get out 1. and 2. ...',13,10,0>
		ccall get,[adrBuffer]
		ccall get,[adrBuffer]
		
		cinvoke printf,<'what is left...',13,10,0>
		ccall print,[adrBuffer]
		
		cinvoke printf,<'add two more...',13,10,0>
		ccall put,[adrBuffer],11
		ccall put,[adrBuffer],12
		
		cinvoke printf,<'print the buffer...',13,10,0>
		ccall print,[adrBuffer]
		
		cinvoke printf,<'thats is it, Circular Buffer in the FASM...',13,10,0>
		cinvoke printf,<'exit...',13,10,0>
		
		xor eax,eax
		ret
	endp
	
	proc put c uses ebx esi edi,adrBuffer,value
		ccall isFull,[adrBuffer]
		.if eax = 1
			cinvoke printf,<'The Buffer is Full...',13,10,0>
			jmp .out
		.endif
		
		mov ecx,BUFFER_SIZE	
		mov esi,[value]
		mov ebx,[adrBuffer]
		mov eax,[ebx + Buffer.last]
		lea edi,[ebx + Buffer.bufferData]
		mov [edi + eax * 4],esi
		inc eax
		
		xor edx,edx
		div ecx 
		mov [ebx + Buffer.last],edx
		
		inc dword[ebx + Buffer.items]
		
		xor eax,eax
	.out:
		ret
	endp
	
	proc get c uses ebx esi edi,adrBuffer
	local value:DWORD
		
		ccall isEmpty,[adrBuffer]
		.if eax = 1
			cinvoke printf,<'The Buffer is Empty...',13,10,0>
			jmp .out
		.endif
		
		mov edi,[value]
		mov ecx,BUFFER_SIZE
		mov ebx,[adrBuffer]
		mov eax,[ebx + Buffer.first]
		lea esi,[ebx + Buffer.bufferData]
		mov edi,[esi + eax * 4]
		mov [value],edi
		inc eax
		
		xor edx,edx
		div ecx
		mov [ebx + Buffer.first],edx
		dec dword[ebx + Buffer.items]
		
		cinvoke printf,<'Element %d is out...',13,10,0>,[value]
		
		xor eax,eax
	.out:
		ret
	endp
	
	proc print c uses ebx esi edi,adrBuffer
		ccall isEmpty,[adrBuffer]
		.if eax = 1
			cinvoke printf,<'nothing to print, the buffer is empty...',13,10,0>
			jmp .out
		.endif
		
		mov ebx,[adrBuffer]
		mov eax,[ebx + Buffer.first]
		mov edi,[ebx + Buffer.items]
		lea esi,[ebx + Buffer.bufferData]
		
		.repeat
			push eax
				cinvoke printf,<'Element %d',13,10,0>,dword[esi + eax * 4]
			pop eax
			inc eax
			
			mov ecx,BUFFER_SIZE
			xor edx,edx
			div ecx
			mov eax,edx
			
			dec edi
		.until edi = 0
		
	.out:
		xor eax,eax	
		ret
	endp
	
	proc isFull c uses ebx,adrBuffer
		mov ebx,[adrBuffer]
		.if dword[ebx + Buffer.items] = BUFFER_SIZE
			mov eax,1
			jmp .out
		.endif
		
		xor eax,eax
	.out:	
		ret
	endp
	
	proc isEmpty c uses ebx,adrBuffer
		mov ebx,[adrBuffer]
		.if dword[ebx + Buffer.items] = 0
			mov eax,1
			jmp .out
		.endif
		
		xor eax,eax
	.out:
		ret
	endp
	
	proc init c uses ebx,adrBuffer
		mov ebx,[adrBuffer]
		mov dword[ebx + Buffer.first],0
		mov dword[ebx + Buffer.last],0
		mov dword[ebx + Buffer.items],0
		
		lea edx,[ebx + Buffer.bufferData]
		xor ecx,ecx
		.repeat
			mov dword[edx + ecx * 4],0
			inc ecx
		.until ecx = BUFFER_SIZE
		
		xor eax,eax
		ret
	endp
	
section '.data' data readable writeable
	nop

section '.idata' data import readable
	library kernel32,'kernel32.dll',\
			msvcrt,'msvcrt.dll'

	import kernel32,\
			ExitProcess,'ExitProcess'

	import msvcrt,\			
			printf,'printf'
			
