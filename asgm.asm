.model small
.stack 100h
.386
.data

    ; Syntax
    CRLF DB 13,10,'$'
    
    ;Validations
    InvalidMsg DB 13,10, 'Invalid input. Please try again.', 13,10,10,10,10,'$'
    CannotSell DB 13,10,'Cannot Sell More than the Available Quantity. $'
    MaximumStock DB 13,10,'The Item will Exceed Maximum Stock (9)! $'

    ; Strings for Main Menu Display, Exit & UserInput
    Mheader DB 13, '---------------------<Flash Electronic Management System>-------------------', 13, 10, 9,'------------------MAIN MENU-----------------', 13, 10, 10 ,'1.View Storage Inventory', 13, 10, '2.View Items By ... Category', 13, 10, '3.Sell Electronic Devices or Accessories', 13, 10, '4.Items Restock', 13, 10, '5.Exit the Program', 13, 10, '$'
    user_input DB 13,10, 'Select an Option: $'
    EnterRet DB 13,10, 'Press Enter to Return to Menu$',13,10
    Exit DB 13,10,'Are you sure you want to exit (y/n): $',13,10
    TyMsg DB 13,10,9,'-------------------------------------------------------------------',13,10,9,9,'Thank You for Using Flash Electronic Management Sytem !',13,10,9,'-------------------------------------------------------------------','$'

    ; View Inventory Header
    INVTheader DB 13,10,'-----------------<Flash Electronic Management System>-----------------',13,10,9,'-------------------<INVENTORY>-----------------',13,10,'ID',9,'Name',9,9,9,9,'Price',9,9,'Quantity',13,10,'$'
    
    ;Sell Items Strings
    SellOption DB 13,10,'Select an Item to Sell (e to Exit to Main Menu): $'
    SellQuantity DB 13,10,'How many do you want to sell?: $'
    Remain_Qty DB 13,10,'Remaining Quantity for $'

    ;Restock Items Strings
    RestockQuantity DB 13,10,'How many do you want to restock?: $'
    RestockOption DB 13,10,'Select an Item to Restock (e to Exit to Main Menu): $'

    ;Categories Strings
    CatHeader DB 13,'-----------------<Flash Electronic Management System>-----------------',13,10,9,'---------------<View By Categories>---------------',13,10,'1. Tablets',13,10,'2. Mobile Phones',13,10,'3. TVs',13,10,'4. Exit to Main Menu',13,10,'$'
    CatOption DB 13,'Select a Category: $'
    TabletHeader DB 13,'-----------------<Flash Electronic Management System>-----------------',13,10,9,'----------------<   Tablets   >----------------',13,10,'ID',9,'Name',9,9,9,9,'Price',9,9,'Quantity',13,10,'$'
    PhoneHeader DB 13,'-----------------<Flash Electronic Management System>-----------------',13,10,9,'----------------<   Mobile Phones   >----------------',13,10,'ID',9,'Name',9,9,9,9,'Price',9,9,'Quantity',13,10,'$'
    TVHeader DB 13,'-----------------<Flash Electronic Management System>-----------------',13,10,9,'----------------<   TVs   >----------------',13,10,'ID',9,'Name',9,9,9,9,'Price',9,9,'Quantity',13,10,'$'

    ; Inventory
    item0 DB '1',9,'Flash Tablet Series 1',9,9,'RM2500',9,9,'$'
    item1 DB '2',9,'Flash Phone Pro Max',9,9,'RM5700',9,9,'$'
    item2 DB '3',9,'Flash Tablet SlimZ Ver 8 ',9,'RM2500',9,9,'$'
    item3 DB '4',9,'Flash TV 4K ',9,9,9,'RM100000',9,'$'
    item4 DB '5',9,'Flash Flip Zen',9,9,9,'RM4200',9,9,'$'
    
    ;Items Name
    itemn0 DB 'Flash Tablet Series 1 :$'
    itemn1 DB 'Flash Phone Pro Max :$'
    itemn2 DB 'Flash Tablet SlimZ Ver 8 :$'
    itemn3 DB 'Flash TV 4K :$'
    itemn4 DB 'Flash Flip Zen :$'

    ; Items' Quantity
    q_Item0 DB 4
    q_Item1 DB 6
    q_Item2 DB 1 
    q_Item3 DB 8 
    q_Item4 DB 3 
    
.code

;Display Messages
DisplayMsg Macro Msg
    lea  dx, Msg      ; load message address
    mov  ah, 09h       ; function to display string
    int  21h          ; call DOS
EndM

;Display Items and Quantity
DisplayQty Macro Qty, Color
    LOCAL LessThanFiveQty, DisplayNormal, EndQty

    mov dl, Qty
    cmp dl, 5          ; Compare the quantity with 5
    jl LessThanFiveQty ; Jump to LessThanFiveQty if quantity is less than 5
    jge DisplayNormal

    DisplayNormal:
        ; Display the quantity normally
        mov dl, Qty    ; Move the quantity back to DL
        add dl, '0'    ; Convert numerical value to ASCII character
        mov ah, 02h    ; Display character
        int 21h        ; Call DOS
        jmp EndQty     ; Jump to the end of the macro

    LessThanFiveQty:
        ; Display the quantity in red color
        mov al, Qty    ; Move the quantity to AL
        add al, '0'    ; Convert numerical value to character
        mov ah, 09h    ; Display character
        mov bh, 0      ; Page number (0 for current page)
        mov bl, Color  ; Text attribute (red color)
        mov cx, 1      ; Set to print only 1 char
        int 10h        ; Call BIOS
        jmp EndQty

    EndQty:
EndM

; Selling an item
SellItem MACRO item,quantityitem
    LOCAL CantSell
    DisplayMsg SellQuantity
    mov ah, 01h
    int 21h

    sub al, '0'
    cmp quantityitem,al
    jl CantSell ; if input > quantity, cant sell

    sub quantityitem, al ; Subtract the quantity from the corresponding item

    ;Display the remaing quantity
    DisplayMsg CRLF
    DisplayMsg Remain_Qty
    DisplayMsg item
    mov dl, quantityitem
    DisplayQty dl, 4

    DisplayMsg CRLF
    call ReturnToMenu
    jmp sell_items

CantSell:
    DisplayMsg CRLF
    DisplayMsg CannotSell
    DisplayMsg CRLF
    call ReturnToMenu
    call sell_items

ENDM

;Restocking an item
RestockItem MACRO item, quantityitem
    LOCAL CheckQuantity

    DisplayMsg RestockQuantity
    mov ah, 01h
    int 21h

    sub al, '0'

    mov bl, quantityitem ; Save the original quantity in BL

    add al, bl ; Calculate the updated quantity

    cmp al, 9
    jg CheckQuantity ; if +stock > 9, invalid

    mov quantityitem, al ; Update the quantity

    DisplayMsg CRLF
    DisplayMsg Remain_Qty
    DisplayMsg item
    mov dl, quantityitem
    DisplayQty dl, 4

    DisplayMsg CRLF
    call ReturnToMenu
    call restock_items

CheckQuantity:
    DisplayMsg CRLF
    DisplayMsg MaximumStock
    DisplayMsg CRLF
    call ReturnToMenu
    call restock_items
    
ENDM

;Main Function
MAIN PROC
    mov ax, @Data     ; Set data segment
    mov ds, ax        ; Data register

    main_loop:

    call display_menu
    mov ah, 01h       ; Read user character input
    int 21h
    
    ; Compare user_input and direct to selected option
    cmp al,'1'
    je inventory_menu
    cmp al, '2'
    je category_menu
    cmp al, '3'
    je sell_items
    cmp al,'4'
    je restock_items
    cmp al, '5'
    je exit_confirmed

    ;Invalid Input
    DisplayMsg CRLF
    DisplayMsg InvalidMsg
    DisplayMsg CRLF
    jmp main_loop

    
;Loops
;Display Main Menu and UserInput String
display_menu:
    DisplayMsg Mheader
    DisplayMsg user_input
    ret

;Option 2: View Inventory
inventory_menu:
    call view_inventory
    call ReturnToMenu
    jmp main_loop

view_inventory:
    DisplayMsg INVTheader

    ; Display Item 0    
    DisplayMsg item0
    DisplayQty q_Item0, 4
    DisplayMsg CRLF
    
    DisplayMsg item1 
    DisplayQty q_Item1, 4
    DisplayMsg CRLF

    DisplayMsg item2
    DisplayQty q_Item2, 4
    DisplayMsg CRLF
    
    DisplayMsg item3
    DisplayQty q_Item3, 4
    DisplayMsg CRLF
    
    DisplayMsg item4
    DisplayQty q_Item4, 4
    DisplayMsg CRLF
    ret

;Sell Menu
sell_items:

    DisplayMsg CRLF
    call view_inventory

    ; Read user's input for item selection
    DisplayMsg SellOption
    mov ah, 01h       ; Read user character input
    int 21h
    cmp al,'1'
    je sellitem0
    cmp al, '2'
    je sellitem1
    cmp al, '3'
    je sellitem2
    cmp al, '4'
    je sellitem3
    cmp al, '5'
    je sellitem4
    cmp al,'e'
    je main_loop
    cmp al,'E'
    je main_loop

    ;Invalid Input
    DisplayMsg CRLF
    DisplayMsg InvalidMsg
    DisplayMsg CRLF
    jmp sell_items

sellitem0:
    DisplayMsg CRLF
    SellItem itemn0,q_Item0
sellitem1:
    DisplayMsg CRLF
    SellItem itemn1,q_Item1
sellitem2:
    DisplayMsg CRLF
    SellItem itemn2,q_Item2
sellitem3:
    DisplayMsg CRLF
    SellItem itemn3,q_Item3
sellitem4:
    DisplayMsg CRLF
    SellItem itemn4,q_Item4

;Restock Menu
restock_items:
    DisplayMsg CRLF
    call view_inventory

    ; Read user's input for item selection
    DisplayMsg RestockOption
    mov ah, 01h  
    int 21h
    cmp al,'1'
    je restock0
    cmp al,'2'
    je restock1
    cmp al,'3'
    je restock2
    cmp al,'4'
    je restock3
    cmp al,'5'
    je restock4
    cmp al,'e'
    je main_loop
    cmp al,'E'
    je main_loop

    ;Invalid Input
    DisplayMsg CRLF
    DisplayMsg InvalidMsg
    DisplayMsg CRLF
    jmp restock_items

restock0:
    DisplayMsg CRLF
    RestockItem itemn0,q_Item0
restock1:
    DisplayMsg CRLF
    RestockItem itemn1,q_Item1
restock2:
    DisplayMsg CRLF
    RestockItem itemn2,q_Item2
restock3:
    DisplayMsg CRLF
    RestockItem itemn3,q_Item3
restock4:
    DisplayMsg CRLF
    RestockItem itemn4,q_Item4
    
;Sort By Category Menu
category_menu:
    DisplayMsg CatHeader
    DisplayMsg CatOption
    mov ah,01h
    int 21h
    cmp al,'1'
    je tablets
    cmp al,'2'
    je phones
    cmp al,'3'
    je tvs 
    cmp al,'4'
    je main_loop

    ;Invalid Input
    DisplayMsg CRLF
    DisplayMsg InvalidMsg
    DisplayMsg CRLF
    jmp category_menu

tablets:
    DisplayMsg TabletHeader
    DisplayMsg CRLF
    DisplayMsg item0
    DisplayQty q_Item0, 4
    DisplayMsg CRLF

    DisplayMsg item2
    DisplayQty q_Item2, 4
    DisplayMsg CRLF
    call ReturnToMenu
    jmp category_menu

phones:
    DisplayMsg PhoneHeader
    DisplayMsg CRLF
    DisplayMsg item1
    DisplayQty q_Item1, 4
    DisplayMsg CRLF

    DisplayMsg item4
    DisplayQty q_Item4, 4
    DisplayMsg CRLF
    call ReturnToMenu
    jmp category_menu

tvs:
    DisplayMsg TVHeader
    DisplayMsg CRLF
    DisplayMsg item3
    DisplayQty q_Item3, 4
    DisplayMsg CRLF
    call ReturnToMenu
    jmp category_menu

;Confirmation for Exit
exit_confirmed:
    
    DisplayMsg Exit
    mov ah,01h
    int 21h

    cmp al,'n'
    je main_loop

    cmp al,'y'
    call clear_screen
    DisplayMsg TyMsg
    je exit_main

;Prompt User to enter Menu
ReturnToMenu:
    DisplayMsg EnterRet
    mov ah, 01h       ; Read user character input
    int 21h
    ;Check if the Enter key pressed
    cmp al, 0Dh 
    ;If not, prompt again
    jne ReturnToMenu 
    
    ;If yes, return to the main loop
    ret

;Clear Screen
clear_screen:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret

;End Program
exit_main:
    mov ah,4Ch
    int 21h

MAIN ENDP
END MAIN