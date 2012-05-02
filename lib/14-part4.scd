PR(\timmerHuffPlayer).v.clone({
	~bufPaths =  BP(\q).paths(\banks, 'part4-huff');
	~bufPaths.size.postln;
	~reloadBufIndex.();
}) => PR(\test).subType_(\timmerBuf);

/*
BP(\test).free
PR(\test) => BP(\test)
BP(\test).play
*/