module tb_ahb_to_pci_bridge;

    // Testbench signals
    reg HCLK;
    reg HRESETn;
    reg HSEL;
    reg HWRITE;
    reg [31:0] HADDR;
    reg [31:0] HWDATA;
    wire [31:0] HRDATA;
    wire HREADY;

    reg PCI_GNT;
    reg [31:0] PCI_RDATA;
    reg PCI_READY;
    wire PCI_REQ;
    wire PCI_WR;
    wire [31:0] PCI_ADDR;
    wire [31:0] PCI_WDATA;

    // Instantiate the AHB to PCI bridge
    ahb_to_pci_bridge dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL),
        .HWRITE(HWRITE),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .
