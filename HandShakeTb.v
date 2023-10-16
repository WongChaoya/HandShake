///////////////////////////////////////////////////////////////////////////////
// 
// 
// File name   : HandShakeTb.v
//
// Author      : ChaoyaWang
// Date        : 2023-10-16
// Version     : 0.1
// Description :
//              全握手模块测试激励
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
module HandShakeTb ();

localparam  TX_CLK_FREQ =   30;
localparam  RX_CLK_FREQ =   20;
localparam  DATA_WIDTH  =   32;
reg TxClk;
reg TxRstn;
reg RxClk;
reg RxRstn;


always    #(TX_CLK_FREQ)  TxClk   =   ~TxClk;
always    #(RX_CLK_FREQ)  RxClk   =   ~RxClk;   
reg rValid;
reg [DATA_WIDTH-1:0]  rData;
wire [DATA_WIDTH-1:0] wTxData;
wire wTxRdy;
wire wRxAck;
HandShakeTx #(
    .DATA_WIDTH(DATA_WIDTH)
)    HandShakeTx_U0(
    .iTxClk(TxClk),
    .iRstnTx(TxRstn),
    .iDataValid(rValid),
    .iRxAck(wRxAck),//接收应答
    .iData(rData),//要传输的数据

    .oTxRdy(wTxRdy),//数据发送准备好信号
    .oTxData(wTxData)//同步到TX时钟域，待发送数据
);

HandShakeRx #(
    .DATA_WIDTH(DATA_WIDTH)
)   HandShakeRx_U0(
    .iRxClk(RxClk),
    .iRstnRx(RxRstn),
    .iTxRdy(wTxRdy),
    .iData(wTxData),
    .oRxAck(wRxAck)
);
initial begin
    TxClk   =   0;
    RxClk   =   0;
    TxRstn  =   0;
    RxRstn  =   0;
    rValid  =   0;
    rData   =   0;
    #(3*TX_CLK_FREQ);
    TxRstn  =   1;
    RxRstn  =   1;
    repeat(20) begin
        #(10*TX_CLK_FREQ);
        rValid  =   1;
        rData   =   rData   +   1;
        #(10*TX_CLK_FREQ);
        rValid  =   0;
    end
    $stop;
end
endmodule //HandShakeTb
