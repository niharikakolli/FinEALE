% Inspect the integration point quantities.
%
% function idat = inspect_integration_points(self, ...
%         geom, u, dT, gcell_list, context,...
%         inspector, idat)
%
% Input arguments
%    x - reference geometry field
%    u - displacement field
%    dT - temperature difference field
%    gcell_list - indexes of the geometric cells that are to be inspected:
%          The gcells to be included are: gcells(gcell_list).
%    context    - structure: see the update() method.
%    inspector - function handle or in-line function with the signature
%             idat =inspector(idat, out, xyz, pc),
%        where
%     idat - a structure or an array that the inspector may
%                use to maintain some state, for instance minimum or
%                maximum of stress, out is the output  of the update()
%                method, and xyz is the location of the integration point
%                in the *reference* configuration. The argument pc are the
%                parametric coordinates of the quadrature point.
% Output arguments
%     idat - see the description of the input argument
%
function idat = inspect_integration_points(self, ...
        geom, u, dT, list, context,...
        inspector, idat)
    fes = self.fes;% grab the finite elements to work on
    %     Evaluate the nodal basis function gradients
    bfun_gradients = nodal_bfun_gradients (self, geom);
    % Material orientation
    Rm_constant = is_material_orientation_constant(self);% if not constant, need to compute  at each point
    if (~Rm_constant)
        Rmh = self.Rm;% handle to a function  to evaluate Rm
    else
        Rm = self.Rm;
    end    
    % Material
    mat = self.material;
    D_constant = are_tangent_moduli_constant (mat);
    if (D_constant)
        D_constrained = tangent_moduli(mat,struct('kind','constrained'));
    end
    % Retrieve data for efficiency
    conns = fes.conn; % connectivity
    labels = fes.label; % connectivity
    xs =geom.values;
    listconn=reshape (conns(list,:),1, []);
    for nix=1:length(bfun_gradients)
        if (ismember (nix,listconn) )
            if bfun_gradients{nix}.Vpatch~=0 % This node has a element patch in this block
                np=length(bfun_gradients{nix}.patchconn);
                c = xs(nix, :); % coordinates of central node
                D = tangent_moduli (mat, struct ('xyz',c));% material tangent
                if (~Rm_constant)% do I need to evaluate the local material orientation?
                    if (~isempty(labels )),  Rm =Rmh(c,J,labels(i));
                    else,                    Rm =Rmh(c,J,[]);                end
                end
                Bnodal= self.hBlmat (self,bfun_gradients{nix}.Nspd,c,Rm);
                if (~D_constant)
                    D_constrained = tangent_moduli(mat,struct('xyz',c,...
                                        'kind','constrained'));
                end
                U = reshape(u,gather_values(u, bfun_gradients{nix}.patchconn)); % displacement
                context.strain = Bnodal*U ;
                s=D_constrained*context.strain;
                context.dT = [];% To do: collect temperatures
                context.xyz =c;
                [out,ignore] = update(mat, [], context);
                out =mean(s(1:3) );
                if ~isempty (inspector)
                    idat =feval(inspector,idat,out,c,[]);% To do: do I need the parametric coordinates?
                end
            end
        end
    end
end
    