module CLA
(
    input  [3:0]	A,
    input  [3:0]    B,
    input           Cin,
    output [3:0]	S,
    output          Cout
);

wire [3:0]	P;
wire [3:0]	G;
wire [9:0]	T;
wire [4:0]	C;

assign C[0] = Cin;
assign Cout = C[4];

/* generate P and G */
genvar i;
generate
	for (i=0; i<4; i=i+1)
	begin
		XOR2 gen_P
		(
			.A	(A[i]),
			.B	(B[i]),
			.Z	(P[i])
		);
		AND2 gen_G
		(
			.A	(A[i]),
			.B 	(B[i]),
			.Z	(G[i])
		);
	end
endgenerate

/* generate T */
AND2 T_0
(
	.A	(C[0]),
	.B 	(P[0]),
	.Z	(T[0])
);
AND2 T_1
(
	.A	(G[0]),
	.B 	(P[1]),
	.Z	(T[1])
);
AND2 T_3
(
	.A	(G[1]),
	.B 	(P[2]),
	.Z	(T[3])
);
AND2 T_6
(
	.A	(G[2]),
	.B 	(P[3]),
	.Z	(T[6])
);

AND3 T_2
(
	.A	(C[0]),
	.B 	(P[1]),
	.C	(P[0]),
	.Z	(T[2])
);
AND3 T_4
(
	.A	(G[0]),
	.B 	(P[2]),
	.C	(P[1]),
	.Z	(T[4])
);
AND3 T_7
(
	.A	(G[1]),
	.B 	(P[3]),
	.C	(P[2]),
	.Z	(T[7])
);

AND4 T_5
(
	.A	(C[0]),
	.B 	(P[2]),
	.C	(P[1]),
	.D	(P[0]),
	.Z	(T[5])
);
AND4 T_8
(
	.A	(G[0]),
	.B 	(P[3]),
	.C	(P[2]),
	.D	(P[1]),
	.Z	(T[8])
);

AND5 T_9
(
	.A	(C[0]),
	.B 	(P[3]),
	.C	(P[2]),
	.D	(P[1]),
	.E 	(P[0]),
	.Z	(T[9])
);

/* generate C */
OR2 C_1
(
	.A	(G[0]),
	.B 	(T[0]),
	.Z 	(C[1])
);
OR3 C_2
(
	.A	(G[1]),
	.B 	(T[1]),
	.C 	(T[2]),
	.Z 	(C[2])
);
OR4 C_3
(
	.A	(G[2]),
	.B 	(T[3]),
	.C 	(T[4]),
	.D 	(T[5]),
	.Z 	(C[3])
);
OR5 C_4
(
	.A	(G[3]),
	.B 	(T[6]),
	.C 	(T[7]),
	.D 	(T[8]),
	.E 	(T[9]),
	.Z 	(C[4])
);

/* generate S */
generate
	for (i=0; i<4; i=i+1)
	begin
		XOR2 gen_P
		(
			.A	(P[i]),
			.B	(C[i]),
			.Z	(S[i])
		);
	end
endgenerate

endmodule