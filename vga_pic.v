`timescale  1ns/1ns

module  vga_pic
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [9:0]   pix_x       ,   //输入有效显示区域像素点X轴坐标
    input   wire    [9:0]   pix_y       ,   //输入有效显示区域像素点Y轴坐标

    output  wire    [15:0]  pix_data_out    //输出VGA显示图像数据

);

parameter   H_VALID =   10'd640     ,   //行有效数据
            V_VALID =   10'd480     ;   //场有效数据

parameter   H_PIC   =   10'd100     ,   //图片长度
            W_PIC   =   10'd100     ,   //图片宽度
            PIC_SIZE=   14'd10000   ;   //图片像素个数

parameter   RED     =   16'hF800    ,   //红色
            ORANGE  =   16'hFC00    ,   //橙色
            YELLOW  =   16'hFFE0    ,   //黄色
            GREEN   =   16'h07E0    ,   //绿色
            CYAN    =   16'h07FF    ,   //青色
            BLUE    =   16'h001F    ,   //蓝色
            PURPPLE =   16'hF81F    ,   //紫色
            BLACK   =   16'h0000    ,   //黑色
            WHITE   =   16'hFFFF    ,   //白色
            GRAY    =   16'hD69A    ;   //灰色

//wire  define
wire            rd_en       ;   //ROM读使能
wire    [15:0]  pic_data    ;   //自ROM读出的图片数据

//reg   define
reg     [13:0]  rom_addr    ;   //读ROM地址
reg             pic_valid   ;   //图片数据有效信号
reg     [15:0]  pix_data    ;   //背景色彩信息

//rd_en:ROM读使能
assign  rd_en = (((pix_x >= (((H_VALID - H_PIC)/2) - 1'b1))
                && (pix_x < (((H_VALID - H_PIC)/2) + H_PIC - 1'b1))) 
                &&((pix_y >= ((V_VALID - W_PIC)/2))
                && ((pix_y < (((V_VALID - W_PIC)/2) + W_PIC)))));

//pic_valid:图片数据有效信号
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pic_valid   <=  1'b1;
    else
        pic_valid   <=  rd_en;

//pix_data_out:输出VGA显示图像数据
assign  pix_data_out = (pic_valid == 1'b1) ? pic_data : pix_data;

//根据当前像素点坐标指定当前像素点颜色数据，在屏幕上显示彩条
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pix_data    <= 16'd0;
    else    if((pix_x >= 0) && (pix_x < (H_VALID/10)*1))
        pix_data    <=  RED;
    else    if((pix_x >= (H_VALID/10)*1) && (pix_x < (H_VALID/10)*2))
        pix_data    <=  ORANGE;
    else    if((pix_x >= (H_VALID/10)*2) && (pix_x < (H_VALID/10)*3))
        pix_data    <=  YELLOW;
    else    if((pix_x >= (H_VALID/10)*3) && (pix_x < (H_VALID/10)*4))
        pix_data    <=  GREEN;
    else    if((pix_x >= (H_VALID/10)*4) && (pix_x < (H_VALID/10)*5))
        pix_data    <=  CYAN;
    else    if((pix_x >= (H_VALID/10)*5) && (pix_x < (H_VALID/10)*6))
        pix_data    <=  BLUE;
    else    if((pix_x >= (H_VALID/10)*6) && (pix_x < (H_VALID/10)*7))
        pix_data    <=  PURPPLE;
    else    if((pix_x >= (H_VALID/10)*7) && (pix_x < (H_VALID/10)*8))
        pix_data    <=  BLACK;
    else    if((pix_x >= (H_VALID/10)*8) && (pix_x < (H_VALID/10)*9))
        pix_data    <=  WHITE;
    else    if((pix_x >= (H_VALID/10)*9) && (pix_x < H_VALID))
        pix_data    <=  GRAY;
    else
        pix_data    <=  BLACK;

//rom_addr:读ROM地址
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr    <=  14'd0;
    else    if(rom_addr == (PIC_SIZE - 1'b1))
        rom_addr    <=  14'd0;
    else    if(rd_en == 1'b1)
        rom_addr    <=  rom_addr + 1'b1;

//------------- rom_pic_inst -------------
rom_pic rom_pic_inst
(
    .address    (rom_addr   ),  //输入读ROM地址,14bit
    .clock      (vga_clk    ),  //输入读时钟,vga_clk,频率25MHz,1bit
    .rden       (rd_en      ),  //输入读使能,1bit

    .q          (pic_data   )   //输出读数据,16bit
);

endmodule
