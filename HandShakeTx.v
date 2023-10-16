///////////////////////////////////////////////////////////////////////////////
// 
// 
// File name   : HandShakeTx.v
//
// Author      : ChaoyaWang
// Date        : 2023-10-12
// Version     : 0.1
// Description :
//              全握手模块发送端
//
// Parameter   :
//    
//    ...
// IO Port     :
//    ...
//    ...
// Modification History:
//   Date       |   Author      |   Version     |   Change Description
//==============================================================================
// 2023-10-12   |   ChaoyaWang  |     0.1       |   第一版
////////////////////////////////////////////////////////////////////////////////
module HandShakeTx #(
    parameter DATA_WIDTH = 32
)(
    input                       iTxClk,
    input                       iRstnTx,
    input                       iDataValid,
    input                       iRxAck,//接收应答
    input   [DATA_WIDTH-1:0]    iData,//要传输的数据

    output                      oTxRdy,//数据发送准备好信号
    output  [DATA_WIDTH-1:0]    oTxData//同步到TX时钟域，待发送数据
    
);

localparam IDLE             =   0,
           ASSERT_TXRDY     =   1,
           DEASSERT_TXRDY   =   2;
reg [1:0] rHndShkState,rHndShkStateNxt;
reg rTxRdy,rTxRdyNxt;
reg [DATA_WIDTH-1:0]    rTxData,rTxDataNxt;
reg rRxAck,rAckTxClk;
always @(*) begin
    rHndShkStateNxt =   rHndShkState;
    rTxRdyNxt       =   1'b0;
    rTxDataNxt      =   rTxData;
    case (rHndShkState)
        IDLE:begin
            if (iDataValid) begin//如果数据已经OK
                rHndShkStateNxt =   ASSERT_TXRDY;
                rTxRdyNxt       =   1'b1;
                rTxDataNxt      =   iData;
            end
        end 
        ASSERT_TXRDY:begin//发送Ready信号
            if (rAckTxClk) begin//接收到应答信号
                rTxRdyNxt       =   1'b0;
                rHndShkStateNxt =   DEASSERT_TXRDY;
                rTxDataNxt      =   0;
            end
            else begin
                rTxRdyNxt   =   1'b1;
                rTxDataNxt  =   rTxData;
            end
        end
        DEASSERT_TXRDY:begin
            if (!rAckTxClk) begin
                if (iDataValid) begin
                    rHndShkStateNxt =   ASSERT_TXRDY;
                    rTxRdyNxt   =   1'b1;
                    rTxDataNxt  =   iData;
                end
                else    begin
                    rHndShkStateNxt =   IDLE;
                end
            end
        end
        default: ;
    endcase
end
always @(posedge iTxClk or negedge iRstnTx ) begin
    if(!iRstnTx) begin
        rHndShkState    <=  IDLE;
        rTxRdy          <=  1'b0;
        rTxData         <=  0;
        rRxAck          <=  0;
        rAckTxClk       <=  0;
    end
    else begin
        rHndShkState    <=  rHndShkStateNxt;
        rTxRdy          <=  rTxRdyNxt;
        rTxData         <=  rTxDataNxt;
        rRxAck          <=  iRxAck;
        rAckTxClk       <=  rRxAck;
    end
end
assign  oTxRdy  =   rTxRdy;
assign  oTxData =   rTxData;

endmodule //HandShakeTx
