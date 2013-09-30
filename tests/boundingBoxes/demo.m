% Tests the hierarchical bounding boxes.

Tree=createBinaryTree(2);
Tree=addChartToBinaryTree(Tree, 1, [0,0], 1);
Tree=addChartToBinaryTree(Tree, 2, [-1,1], .8);
Tree=addChartToBinaryTree(Tree, 3, [-1,0], .8);
Tree=addChartToBinaryTree(Tree, 4, [-1,-1], .8);
Tree=addChartToBinaryTree(Tree, 5, [-.25,.75], .8);
Tree=addChartToBinaryTree(Tree, 6, [.75,.25], .8);

'Find neightbors'
list=createListOfIntersectingCharts(Tree,-1,[.5,0],.4)