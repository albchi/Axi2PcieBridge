module axi_to_pcie_bridge (

    // AXI interface
    input         axi_aclk,
    input         axi_aresetn,
    input         axi_awvalid,
    input  [31:0] axi_awaddr,
    output reg    axi_awready,
    input         axi_wvalid,
    input  [31:0] axi_wdata,
    output reg    axi_wready,
    output reg    axi_bvalid,
    input         axi_bready,
    
    input         axi_arvalid,
    input  [31:0] axi_araddr,
    output reg    axi_arready,
    output reg [31:0] axi_rdata,
    output reg    axi_rvalid,
    input         axi_rready,

    // PCIe interface
    output reg      pcie_req,
    output reg      pcie_wr,
    output reg [31:0] pcie_addr,
    output reg [31:0] pcie_wdata,
    input         pcie_gnt,
    input  [31:0] pcie_rdata,
    input         pcie_ready
);

    // Internal state
    reg [1:0] state;
    localparam IDLE       = 2'b00;
    localparam AXI_WRITE  = 2'b01;
    localparam AXI_READ   = 2'b10;

    always @(posedge axi_aclk or negedge axi_aresetn) begin
        if (!axi_aresetn) begin
            axi_awready <= 1'b0;
            axi_wready <= 1'b0;
            axi_bvalid <= 1'b0;
            axi_arready <= 1'b0;
            axi_rvalid <= 1'b0;
            pcie_req <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    // Handle AXI Write
                    if (axi_awvalid && !axi_awready) begin
                        axi_awready <= 1'b1;
                        pcie_req <= 1'b1;
                        pcie_wr <= 1'b1;
                        pcie_addr <= axi_awaddr;
                        pcie_wdata <= axi_wdata;  // Assume data is ready
                        state <= AXI_WRITE;
                    end else if (axi_arvalid && !axi_arready) begin
                        axi_arready <= 1'b1;
                        pcie_req <= 1'b1;
                        pcie_wr <= 1'b0;
                        pcie_addr <= axi_araddr;
                        state <= AXI_READ;
                    end
                end
                
                AXI_WRITE: begin
                    if (pcie_gnt) begin
                        pcie_req <= 1'b0;  // Clear request
                        axi_bvalid <= 1'b1; // Indicate write response
                        state <= IDLE; // Go back to IDLE
                    end
                end
                
                AXI_READ: begin
                    if (pcie_gnt) begin
                        pcie_req <= 1'b0; // Clear request
                        axi_rdata <= pcie_rdata; // Capture read data
                        axi_rvalid <= 1'b1; // Indicate read response
                        state <= IDLE; // Go back to IDLE
                    end
                end

                default: state <= IDLE; // Fallback
            endcase
        end
    end

    // Handle ready signals
    always @(posedge axi_aclk) begin
        if (axi_bready && axi_bvalid) begin
            axi_bvalid <= 1'b0;
            axi_awready <= 1'b0;
        end
        if (axi_rready && axi_rvalid) begin
            axi_rvalid <= 1'b0;
            axi_arready <= 1'b0;
        end
    end

endmodule
