module XOR2
(
    input    A,
    input    B,
    output   Z
);
assign Z = A^B;
endmodule

module OR2
(
    input    A,
    input    B,
    output   Z
);
assign Z = A|B;
endmodule 

module OR3
(
    input    A,
    input    B,
    input    C,
    output   Z
);
assign Z = A|B|C;
endmodule 

module OR4
(
    input    A,
    input    B,
    input    C,
    input    D,
    output   Z
);
assign Z = A|B|C|D;
endmodule 

module OR5
(
    input    A,
    input    B,
    input    C,
    input    D,
    input    E,
    output   Z
);
assign Z = A|B|C|D|E;
endmodule 

module AND2
(
    input    A,
    input    B,
    output   Z
);
assign Z = A&B;
endmodule 

module AND3
(
    input    A,
    input    B,
    input    C,
    output   Z
);
assign Z = A&B&C;
endmodule 

module AND4
(
    input    A,
    input    B,
    input    C,
    input    D,
    output   Z
);
assign Z = A&B&C&D;
endmodule 

module AND5
(
    input    A,
    input    B,
    input    C,
    input    D,
    input    E,
    output   Z
);
assign Z = A&B&C&D&E;
endmodule 