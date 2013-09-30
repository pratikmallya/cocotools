function [K B OM] = rec_srf(bd2s1, bd2s2, N)

	if nargin<3
		N = 100;
	end
	
	% plot k-b-om
	% axis([2.5 6.5 0.5 0.9 0.93 1.1]);

	k = []; b = []; om = [];
	for bds = bd2s1
		bds = bds{1}; %#ok<FXSET>
		css = [ bds{2:end,9} ]; % om b k
		k  = [k  css(3,:)]; %#ok<AGROW>
		b  = [b  css(2,:)]; %#ok<AGROW>
		om = [om css(1,:)]; %#ok<AGROW>
	end

	for bds = bd2s2
		bds = bds{1}; %#ok<FXSET>
		css = [ bds{2:end,9} ]; % om k b
		k  = [k  css(2,:)]; %#ok<AGROW>
		b  = [b  css(3,:)]; %#ok<AGROW>
		om = [om css(1,:)]; %#ok<AGROW>
	end

	th = atan2((k-6.5)/4, (b-0.5)/0.4);

	TH      = linspace(min(th), max(th), N);
	OM      = linspace(0.93, 1.1, N);
	[TH OM] = meshgrid(TH, OM);

	K = griddata(th, om, k, TH, OM, 'cubic');
	B = griddata(th, om, b, TH, OM, 'cubic');

	% 	plot3(th, om, k, 'k.');
	% 	grid on
	% 	hold on
	% 	mesh(TH, OM, K);
	% 	hold off
	%
	% 	plot3(th, om, b, 'k.');
	% 	grid on
	% 	hold on
	% 	mesh(TH, OM, B);
	% 	hold off
end
