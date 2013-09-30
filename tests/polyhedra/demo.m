%tests the hierarchical bounding boxes

clc

A=createHyperCube(3,1)

A=subtractHalfSpaceFromPoly(A,10,[1;1;1],2)
