% Arr is a Bellop output, already sorted for increasing delay

myChannel = [Arr.Delay' Arr.A.'];
Delay(iT,iNode,jNode) = computeDelayFromChannel( myChannel );
Delay(iT,jNode,iNode) = Delay(iT,iNode,jNode);
