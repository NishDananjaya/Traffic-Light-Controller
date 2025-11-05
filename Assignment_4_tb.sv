module top_module_tb;

  
    logic clk, traffic_B, rstn;
    logic red_light_A, amber_light_A, green_light_A;
    logic red_light_B, amber_light_B, green_light_B;
    logic [7:0] sec_counter_val;
    logic [3:0] mili_sec_counter_val;

  
    top_module dut (
        .clk(clk),
        .traffic_B(traffic_B),
        .rstn(rstn),
        .red_light_A(red_light_A),
        .amber_light_A(amber_light_A),
        .green_light_A(green_light_A),
        .red_light_B(red_light_B),
        .amber_light_B(amber_light_B),
        .green_light_B(green_light_B),
        .sec_counter_val(sec_counter_val),
        .mili_sec_counter_val(mili_sec_counter_val)
    );

    // Clock generation: 100MHz clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        traffic_B = 0;

        // Reset sequence
        #10 rstn = 1;

        // Test 1: Normal operation with traffic_B toggling
        #20 traffic_B = 1;   
        #100 traffic_B = 0;  
        #50 traffic_B = 1;    
        #200 traffic_B = 0;

        // Test 2: Extended traffic presence
        #300 traffic_B = 1;
        #500 traffic_B = 0;

        // Test 3: Reset in between operations
        #50 rstn = 0;
        #20 rstn = 1;

   
        #1000 $finish;
    end
endmodule