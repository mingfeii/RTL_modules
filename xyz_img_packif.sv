// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 Percipio.xyz.
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : img_packif.sv
// Author        : Yushi Liang
// Created On    : 2020-05-02 00:07
// Last Modified : 2020-05-04 18:53
// -----------------------------------------------------------------
// Description:
// imgpack interface to recv dvp line pack & write to  memory by dma
//
// -FHDR------------------------------------------------------------


`timescale 1ns/1ns

module xyz_img_packif #(parameter 
DVP_PACK_ID = 32'h01,
IMG_WIDTH   = 1280,
AW  = 32,  //bus address width
DW  = 64,  //bus data width
PDW = 32, //pack data width
BL  = 8,
DMA_BL=3, 
APB_AW=8,
IPPID=12'hCA0, // Unique ID of XYZLIB
IPUID=4'h0  // assign an unique ID to each instance of this module in the system 
)(

input                   clk,
input                   rst_n,

input                   cpb_r, 
input                   cpb_w,
input   [APB_AW-1:2]    cpb_a, // [9-12]
input         [31:0]    cpb_d,
output  logic [31:0]    cpb_q,
output                  irq,

input                   bus_wrdy,
output                  bus_wval,
output  [BL-1:0]        bus_wlen,
output  [AW-1:0]        bus_waddr,
output  [DW-1:0]        bus_wdata,

input                   pack_clk,
input   [PDW-1:0]       pack_data,
input                   pack_valid,
input                   pack_length,
input                   pack_sop,
input                   pack_eop 

);

localparam SYNC_STAGE=2; // 2|3
localparam IPID_REG_VAL ={IPPID, IPUID, 16'b0};

localparam 
    REG_ID = 0,
    REG_CR = 1,
    REG_BR = 2,
    REG_BUF_SZ  = 3,
    REG_DMA_LR  = 4,
    REG_DMA_AR  = 5,
    REG_DMA_ISR = 6,
    REG_DMA_TR  = 7;//timestamp

//typedef enum{
//    ST_HEAD,
//    ST_TIMESTAMP,
//    ST_OFFSET,
//    ST_PIXLEN,
//    ST_DATA 
//} state_t;
//
//state_t state,nstate;

localparam 
    ST_HEAD      = 6'h01,
    ST_TIMESTAMP = 6'h02,
    ST_OFFSET    = 6'h04,
    ST_PIXLEN    = 6'h08,
    ST_WAITDATA  = 6'h10,
    ST_DATA      = 6'h20; 

logic[5:0] state;
logic [5:0] nstate;

logic           frame_started;
logic [PDW-1:0] timestamp;
logic [AW-1:0]  img_buf_sz;
logic [PDW-1:0] pre_plength; //pack length
logic [PDW-1:0] pre_offset;
logic [AW-1:0]  img_buf_base; //base address
logic           en;
logic           str_en; //stream data on. accept data input

logic           irq_done_is;
logic           irq_syncerr_is;

//pixle2word
logic           p2wd_val ; 
logic           p2wd_eof ;
logic [PDW-1:0] p2wd_d   ;
logic           p2wq_val; 
logic           p2wq_eop; 
logic [DW-1:0]  p2wq_d   ;
//dma
logic           dma_w_ar;
logic           dma_w_lr;
logic [31:0]    dma_d;
logic           dma_done;
logic [31:0]    dma_lr;
logic [31:0]    dma_ar;
logic           is_dma_run;

//in fifo for clk cross

localparam FF_DW = PDW+3;
localparam DFF_FW = $clog2(IMG_WIDTH * 2);

logic               ff_wreq ;           
logic [FF_DW-1:0]   ff_wd   ;           
logic               ff_wne ;           
logic               ff_wnf  ;           
logic [DFF_FW-0:0]  ff_wcnt ;           
logic               ff_rreq;           
logic [FF_DW-1:0]   ff_rd ;           
logic               ff_rne ;           
logic               ff_rnf ;           
logic [DFF_FW-0:0]  ff_rcnt ;           

logic [PDW-1:0]     fp_data;
logic               fp_sop;
logic               fp_eop;
logic               fp_length;
logic   [DMA_BL-1:0]   ReadCnt;  

assign ff_wreq = (pack_valid | pack_length | pack_sop | pack_eop) ;
assign ff_wd   =  {pack_length,pack_sop,pack_eop,pack_data};

assign {fp_length,fp_sop,fp_eop,fp_data} = ff_rd;
// assign ff_rreq = ff_rne;
assign ff_rreq = ~(state==ST_WAITDATA || state==ST_HEAD && is_dma_run) && ff_rne;

always_ff @(posedge clk or negedge rst_n)
    if(~rst_n)
        ReadCnt <= '0;
    else if(~(state==ST_DATA))
        ReadCnt <= '0;    
    else if(ff_rreq)
        ReadCnt <= ReadCnt+1'b1;

xlib_xyz_fifoa #(
    .DW(FF_DW),
    .FW(DFF_FW), 
    .SYNC_STAGE(SYNC_STAGE),
    .WRST_SYNC(1)) u_ff_in (
    .rst_n  ( en              ),
    .wclk   ( pack_clk        ),
    .wreq   ( ff_wreq         ),
    .wd     ( ff_wd           ),
    .wne    ( ff_wne          ), // ff_wne
    .wnf    ( ff_wnf          ), // ff_wnf
    .wcnt   ( ff_wcnt         ), // ff_wcnt
    .rclk   ( clk             ),
    .rreq   ( ff_rreq         ),
    .rd     ( ff_rd           ),
    .rne    ( ff_rne          ),
    .rnf    ( ff_rnf          ), // ff_rnf
    .rcnt   ( ff_rcnt         ) // ff_rcnt
);


//--------------------------------------------------

//state signals
logic  offset_err;
logic  timestamp_err;
logic  pack_length_err; 
logic  img_buffer_full; 
logic  img_last_pack;
logic  img_first_pack;
// logic  is_dma_run;

wire cpb_w_br     = cpb_w && cpb_a == REG_BR;
wire cpb_w_cr     = cpb_w && cpb_a == REG_CR;
wire cpb_w_sr     = cpb_w && cpb_a == REG_DMA_ISR;
wire cpb_w_buf_sz = cpb_w && cpb_a == REG_BUF_SZ;

//state
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        state <= ST_HEAD;
    else
        state <= nstate;

//nstate
always_comb
    if(~str_en || ~en)
        nstate = ST_HEAD;
    else if (~ff_rne)
        nstate = state;
    else case(state)
        ST_HEAD:
            nstate = (fp_sop && fp_data == DVP_PACK_ID && ~irq && en && ~is_dma_run) ? ST_TIMESTAMP : ST_HEAD;
        ST_TIMESTAMP:
            nstate = timestamp_err ?  ST_HEAD : ST_OFFSET;
        ST_OFFSET:
            nstate = offset_err ? ST_HEAD : ST_PIXLEN ;
        ST_PIXLEN:
            nstate = (frame_started || img_first_pack) && ~img_buffer_full ? ST_WAITDATA : ST_HEAD ;
        ST_WAITDATA :
            nstate = (ff_rcnt>=2**DMA_BL) ? ST_DATA : ST_WAITDATA; 
        ST_DATA:
            if(fp_eop) nstate = ST_HEAD;
            else if(&ReadCnt && ff_rreq && ff_rcnt<2**DMA_BL) nstate = ST_WAITDATA; 
            else nstate = ST_DATA;
        default:
            nstate = ST_HEAD;
    endcase


//offset_err
always_comb
begin
    offset_err = 'b0;
    if(state==ST_OFFSET && ff_rne) 
    begin
        if(frame_started)
            offset_err = pre_offset > ff_rd;
        else
            offset_err = ff_rd!=0;
    end
end

//assign offset_err      = (pre_offset > ff_rd) && state == ST_OFFSET && ff_rne;
assign timestamp_err   = frame_started  && (timestamp != ff_rd) && state == ST_TIMESTAMP && ff_rne;
assign pack_length_err = (ff_rd > IMG_WIDTH)  &&  (state==ST_PIXLEN) && ff_rne;

assign img_buffer_full = ((fp_data + pre_offset) > img_buf_sz ) && state == ST_PIXLEN; 
assign img_last_pack   = (pre_plength + pre_offset) == img_buf_sz ;
assign img_first_pack  = ~frame_started && pre_offset==0;
assign is_dma_run      = dma_lr == 'b01;

//frame_started
//indicate that frame data already starting to xfer
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        frame_started <= 'b0;
    else if (~en || ~str_en)
        frame_started <= 'b0;
    else 
        frame_started <= (state == ST_PIXLEN && nstate == ST_WAITDATA) ||  frame_started;

//timestamp
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        timestamp <='b0;
    else if(~en)
        timestamp <='b0;
    else if(state== ST_TIMESTAMP && ~frame_started && ff_rne)
        timestamp <= fp_data;

//pre_plength
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        pre_plength <= 'b0;
    else if(state==ST_PIXLEN && ff_rne)
        pre_plength <= fp_data;

//img_buf_base
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        img_buf_base <= 'b0;
    else if(cpb_w_br)
        img_buf_base <= cpb_d;

//img_buf_sz
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        img_buf_sz <= 'b0; 
    else if(cpb_w_buf_sz)
        img_buf_sz <= cpb_d;

//pre_offset
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        pre_offset <= 'b0;
    else if(~en || ~str_en) 
        pre_offset <= 'b0;
    else if(state == ST_OFFSET && ff_rne && frame_started)
        pre_offset <= fp_data;

//--------------------------------------------------
//cpb port


assign irq = irq_done_is | irq_syncerr_is;

//irq_syncerr_is
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        irq_syncerr_is <= 1'b0;
    else if(cpb_w_sr && cpb_d[1])
        irq_syncerr_is <= 1'b0;
    else  if((timestamp_err || offset_err) && frame_started)
        irq_syncerr_is <= 1'b1;

//irq_done_is 
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        irq_done_is <= 1'b0;
    else if(cpb_w_sr && cpb_d[0])
        irq_done_is <= 1'b0;
    else if(dma_done && img_last_pack)
        irq_done_is <= 1'b1;

//str_en
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        str_en <= 'b0;
    else if(cpb_w_cr )
        str_en <= cpb_d[1];
    else if(irq_done_is || irq_syncerr_is)
        str_en <= 'b0;

//en
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        en <= 'b0;
    else if(cpb_w_cr )
        en <= cpb_d[0];


//cpb_q
always_comb
    case(cpb_a)
        REG_ID :
            cpb_q = IPID_REG_VAL;
        REG_CR :
            cpb_q = {30'b0,str_en,en};
        REG_BR :
            cpb_q = img_buf_base;
        REG_BUF_SZ :
            cpb_q = img_buf_sz;
        REG_DMA_LR :
            cpb_q = dma_lr;
        REG_DMA_AR :
            cpb_q = dma_ar;
        REG_DMA_ISR :
            cpb_q = {30'b0,irq_syncerr_is,irq_done_is};
        REG_DMA_TR:
            cpb_q = timestamp;
        default:
            cpb_q = 0;
    endcase



//--------------------------------------------------
//dma control


assign dma_w_ar = state == ST_OFFSET;
// assign dma_w_lr = (state == ST_PIXLEN) && (nstate == ST_DATA);
assign dma_w_lr = (state == ST_PIXLEN) && (nstate == ST_WAITDATA);

//dma_d
always_comb
    case(state)
        ST_OFFSET:
            dma_d = img_buf_base + fp_data;
        ST_PIXLEN:
            dma_d = 32'b01;
        default:
            dma_d = fp_data;
    endcase

assign p2wd_val = (state==ST_DATA) && ff_rne;
assign p2wd_d   = fp_data;
assign p2wd_eof = fp_eop;

//--------------------------------------------------
wire v_pos;

reg frame_started_1d;


always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        frame_started_1d <= 1'b0;
    else 
        frame_started_1d <= frame_started;


assign v_pos = frame_started & ~frame_started_1d;


logic xsb_val;
logic xsb_eof;
logic [PDW-1:0] xsb_data;

img_sobel_wrapper #(
  .CAM_DW(8), //fixed 8
  .CAM_RW(8),
  .LANE(4),
  .XSOBEL_OUT_MAX(15),
  .XSOBEL_TRUCLSB(0),
  .WIDTH(1280),
  .HEIGHT(100)
) sobel_inst(
  .cam_clk(clk),
  .cam_rst_n(rst_n),
  .v_pos(v_pos),
  .xsb_en(1'b1),
  .rsz_val(p2wd_val),
  .rsz_eof(p2wd_eof),
  .rsz_d(p2wd_d),
  .xsb_val(xsb_val),
  .xsb_eof(xsb_eof),
  .xsb_data(xsb_data)

);


// assign xsb_val = p2wd_val;
// assign xsb_eof = p2wd_eof;
// assign xsb_data = p2wd_d;

xlib_stream_p2w #(
    .UNALIGN(0  ), 
    .PW     (PDW), 
    .DW     (DW ) // Avalon Bus width. 32|64
) u_p2w (
    .clk     ( clk      ), 
    .rst_n   ( en       ), 
    .clr_n   ( 1'b1     ), 
    .bpp     ( 3'd3      ), //// byte per primitive: 0=1B, 1=2B, 2=3B, 3=4B ...
    .m_val   ( xsb_val  ), 
    .m_eof   ( xsb_eof  ), 
    .m_dat   ( xsb_data    ),
    .s_rdy   ( 1'b1     ), 

    .m_rdy   (           ),
    .s_val   ( p2wq_val  ), 
    .s_eof   ( p2wq_eop  ), 
    .s_dat   ( p2wq_d    )
);


localparam DFF_DW = DW+1;
logic               dff_wreq ;           
logic [DFF_DW-1:0]  dff_wd   ;           
logic               dff_wne  ;           
logic               dff_wnf  ;           
logic [DFF_FW-0:0]  dff_wcnt ;           
logic               dff_rreq ;           
logic [DFF_DW-1:0]  dff_rd   ;           
logic               dff_rne  ;           
logic               dff_rnf  ;           
logic [DFF_FW-0:0]  dff_rcnt ;           
wire [DMA_BL:0]     bus_wcnt;

assign dff_wreq = p2wq_val;
assign dff_wd   = { p2wq_eop , p2wq_d };

assign bus_wlen = bus_wcnt;
assign {dff_eop , bus_wdata} = dff_rd;

xlib_xyz_fifoa #(
    .DW(DFF_DW),
    .FW(DFF_FW), 
    .SYNC_STAGE(SYNC_STAGE),
    .WRST_SYNC(1)) u_dma_ff (
    .rst_n  ( en            ),
    .wclk   ( clk           ),
    .wreq   ( dff_wreq      ),
    .wd     ( dff_wd        ),
    .wne    ( dff_wne       ),
    .wnf    ( dff_wnf       ),
    .wcnt   ( dff_wcnt      ),
    .rclk   ( clk           ),
    .rreq   ( dff_rreq      ),
    .rd     ( dff_rd        ),
    .rne    ( dff_rne       ),
    .rnf    ( dff_rnf       ),
    .rcnt   ( dff_rcnt      )
);

localparam AL = $clog2(DW/8); 

xlib_dma_wc #(
    .AL(AL), .AW(AW),
    .BL(DMA_BL),
    .FW(DFF_FW),
    .DELAY_CNT(1)
) u_dma (
    .clk        ( clk         ),
    .rst_n      ( en          ), // dma reset
    .bus_rst_n  ( rst_n       ), // bus reset
    .pio_adr_we ( dma_w_ar    ),
    .pio_len_we ( dma_w_lr    ),
    .pio_d      ( dma_d       ),
    .pio_adr    ( dma_ar      ),
    .pio_len    ( dma_lr      ),
    .pio_cst    (             ),
    .dff_cnt    ( dff_rcnt    ),
    .dff_eof    ( dff_eop     ),
    .dff_ack    ( dff_rreq    ),
    .done       ( dma_done    ),
    .biu_adr    ( bus_waddr   ),
    .biu_len    ( bus_wcnt    ),
    .biu_sob    (             ),
    .biu_eob    (             ),
    .biu_val    ( bus_wval    ),
    .biu_rdy    ( bus_wrdy    ),
    .rsp_val    ( 1'bx        )
);


//TODO:  for  prevent burst writing miss-align
//for pixel number count debug
//TODO: remove this 

logic [15:0] statd_cnt; 
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        statd_cnt<= 'b0;
    else if(state!=ST_DATA)
        statd_cnt<= 'b0;
    else if(state==ST_DATA && ff_rne)
        statd_cnt<= statd_cnt+ 1'b1;

logic [15:0] dma_wcnt; 
always_ff@(posedge clk or negedge rst_n)
    if(~rst_n)
        dma_wcnt <= 'b0;
    else if(dma_lr==0)
        dma_wcnt <= 'b0;
    else if(bus_wrdy && bus_wval)
        dma_wcnt <= dma_wcnt + 1'b1;

//pack_length check
reg cnt_flag;
reg pack_sop_1r;
reg pack_eop_1r;
reg cnt_flag_1r;
reg err_eof;
logic [15:0] plen_cnt; 
logic [15:0] plen_cnt_1; 

wire nege_cnt_flag = cnt_flag_1r & ~cnt_flag ;
wire pose_sop = ~pack_sop_1r & pack_sop;
wire nege_eop = pack_eop_1r & ~pack_eop;


always@(posedge pack_clk or negedge rst_n)
    if (~rst_n) begin
        pack_sop_1r <= 0;
        pack_eop_1r <= 0;
        cnt_flag_1r <= 0;
    end else begin
        pack_sop_1r <= pack_sop;
        pack_eop_1r <= pack_eop;
        cnt_flag_1r <= cnt_flag;
    end


always@(posedge pack_clk or negedge rst_n)
    if (~rst_n)
        cnt_flag <= 0;
    else if (nege_eop)
        cnt_flag <= 0;
    else if (pose_sop) 
        cnt_flag <= 1;

always@(posedge pack_clk or negedge rst_n)
    if (~rst_n)
        err_eof <= 0;
    else if (nege_cnt_flag)
            if (plen_cnt_1 ^ 'd324)
                err_eof <= 'b1;
            else err_eof <= 'b0;
    else err_eof <= 'b0;


always_ff@(posedge pack_clk or negedge rst_n)
    if(~rst_n)
        plen_cnt <= 'b0;
    else if(pack_sop && pack_valid)
        plen_cnt <= 'b1;
    else if(pack_valid)
        plen_cnt <= plen_cnt + 1'b1;

always_ff@(posedge pack_clk or negedge rst_n)
    if(~rst_n)
        plen_cnt_1 <= 'b0;
    else if(pack_sop && pack_valid)
        plen_cnt_1 <= 'b1;
    else if(pack_valid  && cnt_flag)
        plen_cnt_1 <= plen_cnt_1 + 1'b1;



//end debug

endmodule



