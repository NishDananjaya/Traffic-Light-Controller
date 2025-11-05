
module top_module(
    input logic clk ,traffic_B,rstn,
    output logic red_light_A,amber_light_A,green_light_A,
    output logic red_light_B,amber_light_B,green_light_B,
    output logic [7:0]sec_counter_val,
    output logic [3:0]mili_sec_counter_val
);

logic amber_timer_done,amber_timer_enable;

controll_logic controll_logic(
    .clk(clk),
    .timer_done(amber_timer_done),
    .traffic_B(traffic_B),
    .rstn(rstn),
    .red_light_A(red_light_A),
    .amber_light_A(amber_light_A),
    .green_light_A(green_light_A),
    .red_light_B(red_light_B),
    .amber_light_B(amber_light_B),
    .green_light_B(green_light_B),
    .amber_timer_en(amber_timer_enable)
);

amber_timer amber_timer(
    .clk(clk),
    .enable(amber_timer_enable),
    .timer_done(amber_timer_done),
    .sec_counter_val(sec_counter_val),
    .mili_sec_counter_val(mili_sec_counter_val)
);
endmodule


module amber_timer(
    input logic  clk,
    input logic enable,
    output logic timer_done,
    output logic [7:0]sec_counter_val,
    output logic [3:0]mili_sec_counter_val
);

logic sec_done ;

down_counter #(.N(70)) sec_counter (
    .clk(clk),
    .enable(enable),
    .count(sec_counter_val),
    .done(sec_done)
);

down_counter  #(.N(5))mili_sec_counter(
    .clk(clk),
    .enable(sec_done),
    .count(mili_sec_counter_val),
    .done(timer_done)
);
    
endmodule

module down_counter #(parameter N = 10)(
    input logic clk,
    input logic enable,
    output logic [$clog2(N):0] count,
    output logic done
);

    always_ff @(posedge clk) begin
        if (enable) begin
            if (count > 0) begin
                count <= count - 1;
                done <= 1'b0;
            end else begin
                done <= 1'b1;
            end
        end else begin
            count <= N ;
            done <= 1'b0;
        end
    end

endmodule

module controll_logic(
    input logic clk,timer_done,traffic_B,rstn,
    output logic red_light_A,amber_light_A,green_light_A,red_light_B,amber_light_B,green_light_B,amber_timer_en
);

enum logic [1:0] { F0, F1, F2, F3 }state, next_state ;

//next state 
always_comb begin
    case(state)

    F0: if(traffic_B) next_state = F1 ;
        else next_state = state ;

    F1: if(timer_done) next_state = F2 ;
        else next_state = state ;

    F2: if(!traffic_B) next_state = F3 ;
        else next_state = state ;

    F3: if(timer_done) next_state = F0 ;
        else next_state = state ;

    endcase
end

//state sequencer
always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) state <= F0 ;
    else state <= next_state ;
end

//output logic
always_comb begin
    if(state == F1) begin 
        red_light_A = 0; amber_light_A = 1; green_light_A = 0;
        red_light_B = 1; amber_light_B = 0; green_light_B = 0;
        amber_timer_en = 1;
    end

    else if(state == F2) begin 
        red_light_A = 1; amber_light_A = 0; green_light_A = 0;
        red_light_B = 0; amber_light_B = 0; green_light_B = 1;
        amber_timer_en = 0;
    end
    else if(state == F3) begin 
        red_light_A = 1; amber_light_A = 0; green_light_A = 0;
        red_light_B = 0; amber_light_B = 1; green_light_B = 1;
        amber_timer_en = 1;
    end
    else  begin 
        red_light_A = 0; amber_light_A = 0; green_light_A = 1;
        red_light_B = 1; amber_light_B = 0; green_light_B = 0;
        amber_timer_en = 0;
    end
 end
    
endmodule