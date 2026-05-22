`timescale 1ns/1ps

module tb_axi_lite_slave;

    reg clk;
    reg reset;

    //=========================
    // WRITE ADDRESS CHANNEL
    //=========================
    reg [3:0] awaddr;
    reg awvalid;
    wire awready;

    //=========================
    // WRITE DATA CHANNEL
    //=========================
    reg [31:0] wdata;
    reg [3:0]  wstrb;
    reg wvalid;
    wire wready;

    //=========================
    // WRITE RESPONSE CHANNEL
    //=========================
    wire [1:0] bresp;
    wire bvalid;
    reg bready;

    //=========================
    // READ ADDRESS CHANNEL
    //=========================
    reg [3:0] araddr;
    reg arvalid;
    wire arready;

    //=========================
    // READ DATA CHANNEL
    //=========================
    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire rvalid;
    reg rready;

    //=========================
    // INTERRUPT
    //=========================
    wire interrupt;

    //=====================================
    // DUT
    //=====================================
    axi_lite_slave dut (

        .clk(clk),
        .reset(reset),

        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),

        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),

        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),

        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),

        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),

        .interrupt(interrupt)

    );

    //=====================================
    // CLOCK
    //=====================================
    always #5 clk = ~clk;

    //=====================================
    // AXI WRITE TASK
    //=====================================
    task axi_write;

        input [3:0] addr;
        input [31:0] data;
        input [3:0] strb;

        begin

            @(posedge clk);

            awaddr  <= addr;
            awvalid <= 1;

            wdata   <= data;
            wstrb   <= strb;
            wvalid  <= 1;

            bready  <= 1;

            @(posedge clk);

            awvalid <= 0;
            wvalid  <= 0;

            wait(bvalid);

            @(posedge clk);

            bready <= 0;

        end

    endtask

    //=====================================
    // AXI READ TASK
    //=====================================
    task axi_read;

        input [3:0] addr;

        begin

            @(posedge clk);

            araddr  <= addr;
            arvalid <= 1;

            rready  <= 1;

            @(posedge clk);

            arvalid <= 0;

            wait(rvalid);

            @(posedge clk);

            rready <= 0;

        end

    endtask

    //=====================================
    // TEST SEQUENCE
    //=====================================
    initial begin

        //---------------------------------
        // WAVEFORM
        //---------------------------------
        $dumpfile("sim/axi_lite.vcd");
        $dumpvars(0, tb_axi_lite_slave);

        //---------------------------------
        // INITIAL VALUES
        //---------------------------------
        clk = 0;
        reset = 1;

        awaddr = 0;
        awvalid = 0;

        wdata = 0;
        wstrb = 0;
        wvalid = 0;

        bready = 0;

        araddr = 0;
        arvalid = 0;

        rready = 0;

        //---------------------------------
        // RESET
        //---------------------------------
        #20;
        reset = 0;

        #20;

        //---------------------------------
        // WRITE TEST
        //---------------------------------
        axi_write(4'h0, 32'h12345678, 4'b1111);

        $display("reg0 = %h", dut.registers[0]);

        //---------------------------------
        // READ TEST
        //---------------------------------
        axi_read(4'h0);

        if (rdata == 32'h12345678)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        //---------------------------------
        // INVALID ADDRESS TEST
        //---------------------------------
        axi_read(4'hF);

        if (rdata == 32'hDEADBEEF)
            $display("INVALID ADDRESS TEST PASSED");
        else
            $display("INVALID ADDRESS TEST FAILED");

        //---------------------------------
        // INTERRUPT TEST
        //---------------------------------

        // Start write transaction
        @(posedge clk);

        awaddr  <= 4'h4;
        awvalid <= 1;

        wdata   <= 32'h00000001;
        wstrb   <= 4'b1111;
        wvalid  <= 1;

        bready  <= 0;

        // FSM detects transaction
        @(posedge clk);

        // FSM executes WRITE state
        @(posedge clk);

        // NONBLOCKING assignment updates here
        @(posedge clk);

        // NOW check interrupt
        if (interrupt)
            $display("INTERRUPT ASSERT TEST PASSED");
        else
            $display("INTERRUPT ASSERT TEST FAILED");

        // Finish transaction
        awvalid <= 0;
        wvalid  <= 0;

        bready <= 1;

        @(posedge clk);

        bready <= 0;

        //---------------------------------
        // WSTRB TEST
        //---------------------------------
        axi_write(4'h0, 32'hFFFFFFFF, 4'b1111);

        axi_write(4'h0, 32'h000000AA, 4'b0001);

        if (dut.registers[0] == 32'hFFFFFFAA)
            $display("WSTRB TEST PASSED");
        else
            $display("WSTRB TEST FAILED");

        //---------------------------------
        // ASSERTION TEST
        //---------------------------------
        @(posedge clk);

        awvalid <= 1;
        arvalid <= 1;

        @(posedge clk);

        awvalid <= 0;
        arvalid <= 0;

        #50;

        $finish;

    end

    //=====================================
    // SIMPLE ASSERTION
    //=====================================
    always @(posedge clk) begin

        if (awvalid && arvalid)
            $display("ASSERTION FAILED: Simultaneous READ and WRITE detected");

    end

endmodule