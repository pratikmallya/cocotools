classdef atlas_2d < AtlasBase
    
    properties (Access = private)
        base_chart = struct([]);
        cont       = struct([]);
        boundary = [], charts = {}, pt = -1;
    end
    
    methods % constructor
        
        function atlas = atlas_2d(opts, cont, dim)
            if(dim~=2)
                error('%s: wrong manifold dimension dim=%d, expected dim=1', ...
                    mfilename, dim);
            end
            atlas      = atlas@AtlasBase(opts, dim);
            atlas.cont = atlas_2d.get_settings(cont);
            atlas.cont.prf_idx = coco_get_func_data(opts, 'covering.prcond', 'fidx');
        end
        
    end
    
    methods (Static=true) % static construction method
        
        function [opts atlas] = create(opts, cont, dim)
            atlas = atlas_2d(opts, cont, dim);
        end
        
    end
    
    methods (Static=true, Access = private)
        
        function cont = get_settings(cont)
            defaults.h    = 0.1; % continuation step size
            defaults.PtMX = 100; % number of continuation steps
            defaults.thk  = 0.1; % thickness of ellipsoids
            defaults.sp   = 'first'; % sampling algorithm
            cont          = coco_set(defaults, cont);
        end
        
        function [atls chart] = merge_into_atlas(chart, atls, root)
            chart.checked(end+1) = root;
            phi1 = atls{root}.TS'*(chart.x - atls{root}.x);
            phi2 = chart.TS'*(atls{root}.x - chart.x);
            merged = false;
            if (norm(phi1) < 2*chart.R) && ...
                    (norm(chart.x - atls{root}.x - atls{root}.TS*phi1) < chart.thk)
                chart.neighbors = union(chart.neighbors, root);
                atls{root} = atlas_2d.voronoi(atls{root}, phi1);
                merged = true;
            end
            if (norm(phi2) < 2*chart.R) && ...
                    (norm(atls{root}.x - chart.x - chart.TS*phi2) < chart.thk)
                chart.neighbors = union(chart.neighbors, root);
                chart = atlas_2d.voronoi(chart, phi2);
                merged = true;
            end
            if merged
                neighbors = atls{root}.neighbors;
                for neighbor = neighbors
                    if ~ismember(neighbor, chart.checked)
                        [atls chart] = atlas_2d.merge_into_atlas(chart, atls, neighbor);
                    end
                end
            end
        end
        
        function chart = voronoi(chart, phi)
            sg = chart.sg;
            test = zeros(size(sg,2),1);
            for j=1:numel(test)
                test(j) = sg(:,j)'*phi - (0.5 / chart.R) * norm(phi)^2;
            end
            if any(test > 0)
                j = 0;
                while test(1) > 0 || test(1)*test(end) > 0
                    j = j+1;
                    test = circshift(test, -1);
                end
                sg   = circshift(sg, [0 -j]);
                
                j = find(test < 0, 1, 'last');
                nsg1 = sg(:,j) - test(j) / ((sg(:,j+1) - sg(:,j))' * phi) ...
                    * (sg(:,j+1) - sg(:,j));
                nsg2 = sg(:,end) - test(end) / ((sg(:,1) - sg(:,end))' * phi) ...
                    * (sg(:,1) - sg(:,end));
                chart.sg = [ sg(:,1:j) nsg1 nsg2];
                chart.vx = find(sqrt(sum(chart.sg.^2,1)) > 1);
            end
        end
        
        function X = nullspace(A)
            % A rectangular (m,n)-matrix with m<n and full row rank.
            [L U P]  = lu(A'); %#ok<ASGLU>
            [m n] = size(A);
            Y  = L(1:m, 1:m)' \ L(m+1:end, 1:m)';
            X  = P'*[Y; -eye(n-m)];
            X  = orth(X);
        end
    end
    
    methods % interface methods
        
        function [opts atlas chart accept] = init_chart(atlas, opts, chart)
            % Initialize initial chart
            chart.t = chart.t/norm(chart.t);
            
            [opts chart J] = opts.efunc.DFDX(opts, chart, chart.x);
            J(atlas.cont.prf_idx,:) = [];
            chart.TS = atlas.nullspace(full(J));
            
            chart.R         = 0;
            chart.pt_type   = 'IP';
            chart.ep_flag   = 1;
            chart.pt        = atlas.pt;
            chart.thk       = 0;
            chart.sg        = [];
            chart.vx        = [];
            chart.s         = [];
            chart.neighbors = [];
            chart.checked   = [];
            
            % accept initial point without correction
            accept = false;
        end
        
        function [opts atlas cseg] = init_update_chart(atlas, opts, cseg)
            % update tangent space TS
            [opts cseg.curr_chart] = cseg.tangent_space(opts, cseg.curr_chart);
            
            % update vertex listing
            cseg.curr_chart.sg  = [-1.1 -1.1 1.1 1.1; -1.1 1.1 1.1 -1.1];
            cseg.curr_chart.vx  = 1:4;
            
            % initialise tangents t
            cseg.curr_chart.t = cseg.curr_chart.TS*(cseg.curr_chart.sg./...
                repmat(sqrt(sum(cseg.curr_chart.sg.^2,1)), [2 1]));
        end
                
        function [opts atlas chart] = init_admissible(atlas, opts, chart, flags, msg)
            % Check if computed point is not inside computational domain
            if chart.ep_flag > 1
                [opts atlas chart] = atlas.init_admissible@AtlasBase(opts, chart, flags, msg);
            else
                % Remove directions and associated values that are not admissible
                idx = (flags==opts.atlas.IsAdmissible);
                if ~any(idx)
                    chart.t         = nan(size(chart.t,1),1);
                    chart.p         = chart.p(:,1);
                    atlas.cont.PtMX = 0;
                else
                    chart.t    = chart.t(:,idx);
                    chart.p    = chart.p(:,idx);
                    chart.vx   = chart.vx(:,idx);
                end
            end
        end
        
        function [opts atlas cseg accept] = init_atlas(atlas, opts, cseg)
            % Initialize atlas, but flush only if atlas.cont.PtMX=0
            chart         = cseg.curr_chart;
            atlas.pt = atlas.pt + 1;
            chart.pt = atlas.pt;
            chart.R   = atlas.cont.h;
            chart.thk = atlas.cont.thk;
            chart.pt_type = 'EP';
            chart.ep_flag = 1;
            
            if numel(chart.vx)==4
                atlas.boundary = 1;
            end
            atlas.charts = { chart };
            atlas.base_chart = chart;
            if atlas.cont.PtMX == 0
                cseg.ptlist = { chart };
                accept = true;
            else
                accept = false;
            end
        end
        
        function [opts atlas cseg accept] = add_chart(atlas, opts, cseg)
            % update tangent space TS and curve tangent t
            [opts chart]     = cseg.tangent_space(opts, cseg.curr_chart);
            [opts chart]     = cseg.tangent(opts, chart);
            % update chart counter, radius, thickness, and vertices
            atlas.pt         = atlas.pt + 1;
            chart.pt         = atlas.pt;
            chart.R          = atlas.cont.h;
            chart.thk        = atlas.cont.thk;
            chart.sg         = [-1.1 -1.1 1.1 1.1; -1.1 1.1 1.1 -1.1];
            chart.neighbors  = [];
            chart.checked    = [];
              
            if chart.pt >= atlas.cont.PtMX
                chart.pt_type = 'EP';
                chart.ep_flag = 1;
            end
            
            % add chart to point list
            cseg.ptlist = [ cseg.ptlist chart ];
            
            % accept curve segment without adding further points
            accept = true;
        end
        
        function [opts atlas cseg] = predict(atlas, opts, cseg) %#ok<INUSD>
            % use pseudo arc-length projection condition
            chart      = atlas.base_chart;
            if strcmp(atlas.cont.sp, 'first')
                i = chart.vx(1);
            elseif strcmp(atlas.cont.sp, 'random')
                i = chart.vx(randi(numel(chart.vx)));
            end
            chart.s    = chart.sg(:,i)/norm(chart.sg(:,i));
            chart.t    = chart.TS * chart.s;
            pr_cond.x  = chart.x;
            pr_cond.TS = chart.TS;
            pr_cond.s  = chart.s;
            pr_cond.h  = chart.R;
            
            % construct new curve segment
            cseg        = CurveSegment(opts, chart, pr_cond);
            cseg.ptlist = { chart };
            
            % update curr_chart with predicted point
            cseg.curr_chart.x = chart.x + chart.R*chart.t;
        end
        
        function [opts atlas cseg accept] = flush(atlas, opts, cseg)
            % Merge new charts with atlas 
            if cseg.Status == cseg.CurveSegmentOK
                chart = cseg.ptlist{end};

                bdry = atlas.boundary;
                atls = atlas.charts;
                if chart.pt>=0
                    for root = bdry
                        if ~ismember(root, chart.checked)
                            [atls chart] = atlas.merge_into_atlas(chart, atls, root);
                        end
                    end
                    atlas.charts = [ atls chart ];
                    for i = chart.neighbors
                        atlas.charts{i}.neighbors(end+1) = numel(atlas.charts);
                    end
                    j = 0;
                    for i = bdry
                        if any(sqrt(sum(atlas.charts{i}.sg.^2, 1)) > 1)
                            j = j+1;
                            atlas.boundary(j) = i;
                        end
                    end
                    % Include chart in atlas boundary unless it lies on the
                    % boundary of the computational domain
                    if any(sqrt(sum(chart.sg.^2,1)) > 1) && chart.ep_flag==0
                        atlas.boundary = [atlas.boundary(1:j) chart.pt+1];
                    else
                        atlas.boundary = atlas.boundary(1:j);
                    end
                end
                
                % check if final chart
                if isempty(atlas.boundary)
                    cseg.ptlist{end}.pt_type = 'EP';
                    cseg.ptlist{end}.ep_flag = 1;
                else
                    atlas.base_chart = atlas.charts{atlas.boundary(end)};
                end
            end
            % Flush new charts to disk and screen output
            [opts atlas cseg accept] = atlas.flush@AtlasBase(opts, cseg);
            
            if accept == cseg.CurveSegmentOK
                chart = cseg.ptlist{end};
                % terminate if chart counter equals or exceeds PtMx
                accept = accept || isempty(atlas.boundary);
                accept = accept || (chart.pt>=atlas.cont.PtMX);
            end
            if accept
                opts.cont.atlas = atlas.charts;
            end
        end
        
    end
    
end