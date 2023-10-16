///////////////////////////////////////////////////////////////////////////////
// 
// 
// File name   : HandShakeRx.v
//
// Author      : ChaoyaWang
// Date        : 2023-10-16
// Version     : 0.1
// Description :
//              全握手模块接收端
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
// 2023-10-16   |   ChaoyaWang  |     0.1       |   第一版
////////////////////////////////////////////////////////////////////////////////
module HandShakeRx #(
    parameter DATA_WIDTH = 32
)(
    input                       iRxClk,
    input                       iRstnRx,
    input                       iTxRdy,
    input      [DATA_WIDTH-1:0] iData,
    output                      oRxAck
    
);
localparam  IDLE        =   0,
            ASSERT_ACK  =   1;
reg     rHndShkState,rHndShkStateNxt;
reg     rRxAck,rRxAckNxt;
reg [DATA_WIDTH-1:0]    rDataRxClk,rDataRxClkNxt;
reg     rTxRdy,rTxRdyRxClk;

always @(*) begin
    rHndShkStateNxt =   rHndShkState;
    rRxAckNxt       =   0;
    rDataRxClkNxt   =   rDataRxClk;
    case (rHndShkState)
        IDLE:begin
            if (rTxRdyRxClk) begin
                rHndShkStateNxt =   ASSERT_ACK;
                rRxAckNxt       =   1'b1;
                rDataRxClkNxt   =   iData;
            end
        end 
        ASSERT_ACK:begin
            if (!rTxRdyRxClk) begin
                rRxAckNxt   =   1'b0;
                rHndShkStateNxt =   IDLE;
            end
            else begin
                rRxAckNxt   =   1'b1;
            end
        end
        default: ;
    endcase
end
always @(posedge iRxClk or negedge iRstnRx) begin
    if(!iRstnRx) begin
        rHndShkState <= IDLE;
        rRxAck       <= 0;
        rDataRxClk   <= 0;
        rTxRdy       <= 0;
        rTxRdyRxClk  <= 0;   
    end
    else begin
        rHndShkState <= rHndShkStateNxt;
        rRxAck       <= rRxAckNxt;
        rDataRxClk   <= rDataRxClkNxt;
        rTxRdy       <= iTxRdy;
        rTxRdyRxClk  <= rTxRdy;
    end
end
assign oRxAck   =   rRxAck;
endmodule //HandShakeRx
