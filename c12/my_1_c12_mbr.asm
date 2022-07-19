;文件说明：自己重写一遍c12程序。
;原c12程序内容：保护模式等。

;设置堆栈段和栈指针 
[bits16]        ;nasm的默认编译尺寸即为16位
mov eax,cs       ;设置栈段寄存器
mov ss,eax
mov sp,0x7c00    ;设置栈段大小

;根据GDT物理地址，即GDT的线性基地址，计算出在实模式下需要的：段地址与偏移地址。
xor eax,eax
mov ds,eax

mov eax,[gdt_reg+0x02]
xor edx,edx
mov ebx,16
div ebx

mov ds,eax      ;段地址
mov ebx,edx     ;偏移地址

;创建0#描述符，它是空描述符，这是处理器的要求。
mov [ebx+0x00],0x00000000
mov [ebx+0x04],0x00000000

;创建1#描述符，这是一个数据段，对应0~4GB的线性地址空间。
mov [ebx+0x08],0x0000ffff
mov [ebx+0x0c],0x00cf9200 

;创建2#描述符，这是一个代码段，即本段。
mov [ebx+0x10],0x7c0001ff
mov [ebx+0x14],0x00409800

;创建3#以上代码段的别名描述符
mov [ebx+0x18],0x7c0001ff    ;基地址为0x00007c00，512字节
mov [ebx+0x1c],0x00409200    ;粒度为1个字节，数据段描述符

;创建4#描述符，这是一个栈段，对应0x7e00~0x7f00的线性地址空间。
mov [ebx+0x18],0x6c0007ff
mov [ebx+0x1c],0x00409200

;初始化GDTR
mov word [cs:0x7c00+gdt_reg], 0x1f
lgdt [cs:0x7c00+gdt_reg]

;开启第二十一根地址线，端口0x92的第二位设置1。
in al,0x92        ;8位的端口
or al,0000_0010B
out 0x92,al

cli     ;禁止中断

;修改寄存器cR0（32位寄存器）的第一位设置1。
mov al,cr0
or al,0000_0001B
mov cr0,al

;————————以下进入保护模式————————

;jump入代码段
jump 0010:flush     ;段选择子：有效地址

flush:
;加载数据段选择子
mov eax,0x0008
mov ds,eax

;加载栈段选择子
mov eax,0x0020
mov ss,eax
mov esp,0x800

;将字符压入栈段


;再弹出到显存0xb8000开始

gdt_reg:
    dw 0;
    dd 0x00007e00






