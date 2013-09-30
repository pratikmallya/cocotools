function [opts coll] = coll_createRHSList(opts, coll, func)
%Create a list of right-hand sides over all segments.

segs   = coll.segs;
mfname = func.fname;

% we construct the list of right-hand sides in rhss
rhss    = [];
xcoloff = 0;
for segnum = 1:length(segs)
	rhs    = [];
	rhsnum = 0;
	
	% check if segment contains a mode name and compute RHS name from base
	% name 'mfname' and the mode name
	if isempty(segs(segnum).fname)
		fname   = mfname;
		fhan    = func.fhan;
    dfdxhan = func.dfdxhan;
    dfdphan = func.dfdphan;
	else
		fname    = sprintf('%s_%s', mfname, segs(segnum).fname);
		fhan     = str2func(fname);
		dfdxname = sprintf('%s_%s_DFDX', mfname, segs(segnum).fname);
		dfdpname = sprintf('%s_%s_DFDP', mfname, segs(segnum).fname);
    if any(exist(dfdxname, 'file') == [2 3])
      dfdxhan = str2func(dfdxname);
    else
      dfdxhan = [];
    end
    if any(exist(dfdpname, 'file') == [2 3])
      dfdphan = str2func(dfdpname);
    else
      dfdphan = [];
    end
	end
	
	% check if this RHS is already in the list
	for i=1:length(rhss)
		if strcmp(rhss(i).fname, fname)
			rhsnum = i;
			rhs    = rhss(rhsnum);
			break
		end
	end
	
	% if RHS is already in the list ...
	if rhsnum
		% ... append the collocation points of this segment to the
		% existing RHS entry
		rhs.xcolidx  = [rhs.xcolidx  xcoloff+segs(segnum).xcolidx     ];
		rhs.dxcolidx = [rhs.dxcolidx segs(segnum).dim*xcoloff+segs(segnum).dxcolidx];
		rhss(rhsnum) = rhs; %#ok<AGROW>
	else
		% ... create a new RHS entry
		rhs.fname      = fname;
		rhs.fhan       = fhan;
		rhs.dfdxhan    = dfdxhan;
		rhs.dfdphan    = dfdphan;
		rhs.xcolidx    = xcoloff+segs(segnum).xcolidx;
		rhs.dxcolidx   = segs(segnum).dim*xcoloff+segs(segnum).dxcolidx;
    rhs.vectorised = 1; % bug: this should be passed as an argument
		rhss           = [ rhss ; rhs ]; %#ok<AGROW>
	end
	xcoloff = rhs.xcolidx(end);
	
	segs(segnum).fname = fname;
	segs(segnum).fhan  = fhan;
end

% update collocation structure
coll.segs = segs;
coll.rhss = rhss;
