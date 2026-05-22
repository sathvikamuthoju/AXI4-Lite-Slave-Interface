module axi_lite_slave #(
    parameter REG_COUNT = 4
)(
    input wire clk,
    input wire reset,

    //=========================
    // WRITE ADDRESS CHANNEL
    //=========================
    input wire [3:0] awaddr,
    input wire awvalid,
    output reg awready,

    //=========================
    // WRITE DATA CHANNEL
    //=========================
    input wire [31:0] wdata,
    input wire [3:0]  wstrb,
    input wire wvalid,
    output reg wready,

    //=========================
    // WRITE RESPONSE CHANNEL
    //=========================
    output reg [1:0] bresp,
    output reg bvalid,
    input wire bready,

    //=========================
    // READ ADDRESS CHANNEL
    //=========================
    input wire [3:0] araddr,
    input wire arvalid,
    output reg arready,

    //=========================
    // READ DATA CHANNEL
    //=========================
    output reg [31:0] rdata,
    output reg [1:0]  rresp,
    output reg rvalid,
    input wire rready,

    //=========================
    // INTERRUPT
    //=========================
    output reg interrupt
);

    //=========================================
    // REGISTER ARRAY
    //=========================================
    reg [31:0] registers [0:REG_COUNT-1];

    integer i;

    //=========================================
    // FSM STATES
    //=========================================
    localparam IDLE  = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ  = 2'b10;
    localparam RESP  = 2'b11;

    reg [1:0] state;

    //=========================================
    // AXI-LITE FSM
    //=========================================
    always @(posedge clk) begin

        //-------------------------------------
        // RESET
        //-------------------------------------
        if (reset) begin

            awready   <= 0;
            wready    <= 0;
            bvalid    <= 0;
            bresp     <= 2'b00;

            arready   <= 0;
            rvalid    <= 0;
            rresp     <= 2'b00;
            rdata     <= 32'b0;

            interrupt <= 0;

            state <= IDLE;

            for (i = 0; i < REG_COUNT; i = i + 1)
                registers[i] <= 32'b0;

        end

        else begin

            case(state)

            //=================================
            // IDLE STATE
            //=================================
            IDLE: begin

                awready <= 1;
                wready  <= 1;
                arready <= 1;

                bvalid <= 0;
                rvalid <= 0;

                if (awvalid && wvalid)
                    state <= WRITE;

                else if (arvalid)
                    state <= READ;

            end

            //=================================
            // WRITE STATE
            //=================================
            WRITE: begin

                case (awaddr)

                    //---------------------------------
                    // REG0 WITH WSTRB SUPPORT
                    //---------------------------------
                    4'h0: begin

                        if (wstrb[0])
                            registers[0][7:0] <= wdata[7:0];

                        if (wstrb[1])
                            registers[0][15:8] <= wdata[15:8];

                        if (wstrb[2])
                            registers[0][23:16] <= wdata[23:16];

                        if (wstrb[3])
                            registers[0][31:24] <= wdata[31:24];

                    end

                    //---------------------------------
                    // REG1 + INTERRUPT
                    //---------------------------------
                    4'h4: begin

                        registers[1] <= wdata;

                        // Interrupt enable
                        if (wdata[0])
                            interrupt <= 1;

                    end

                    //---------------------------------
                    // REG2
                    //---------------------------------
                    4'h8: begin
                        registers[2] <= wdata;
                    end

                    //---------------------------------
                    // REG3
                    //---------------------------------
                    4'hC: begin
                        registers[3] <= wdata;
                    end

                    //---------------------------------
                    // INVALID ADDRESS
                    //---------------------------------
                    default: begin
                    end

                endcase

                bvalid <= 1;
                bresp  <= 2'b00;

                state <= RESP;

            end

            //=================================
            // READ STATE
            //=================================
            READ: begin

                case(araddr)

                    4'h0: rdata <= registers[0];
                    4'h4: rdata <= registers[1];
                    4'h8: rdata <= registers[2];
                    4'hC: rdata <= registers[3];

                    default: rdata <= 32'hDEADBEEF;

                endcase

                rvalid <= 1;
                rresp  <= 2'b00;

                state <= RESP;

            end

            //=================================
            // RESPONSE STATE
            //=================================
            RESP: begin

                //---------------------------------
                // WRITE RESPONSE
                //---------------------------------
                if (bvalid && bready) begin

                    bvalid <= 0;

                    // Clear interrupt after response
                    interrupt <= 0;

                    state <= IDLE;

                end

                //---------------------------------
                // READ RESPONSE
                //---------------------------------
                else if (rvalid && rready) begin

                    rvalid <= 0;

                    state <= IDLE;

                end

            end

            //=================================
            // DEFAULT
            //=================================
            default: begin
                state <= IDLE;
            end

            endcase

        end

    end

endmodule
