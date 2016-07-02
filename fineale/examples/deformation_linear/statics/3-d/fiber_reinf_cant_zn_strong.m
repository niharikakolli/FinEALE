% Fiber-reinforced cantilever.
function fiber_reinf_cant_zn_strong
% @article{
%    author = {Krysl, P.},
%    title = {Mean-strain 8-node hexahedron with optimized energy-sampling stabilization},
%    journal = {Finite Elements in Analysis and Design},
%    volume = {108},
%    pages = {41-53},
%    ISSN = {0168-874X},
%    DOI = {10.1016/j.finel.2015.09.008},
%    year = {2016},
%    type = {Journal Article}
% }

u= physical_units_struct;

% Anisotropic, but much stronger anisotropy
E1=100000*1e9*u.PA; E2=1e9*u.PA; E3=E2; G12=0.2e9*u.PA;  G13=G12; G23=0.2e9*u.PA;
nu12= 0.25; nu13= 0.25; nu23= 0.25;
aangle =-45;
% hs=[2   4   8  16];
% [xestim, beta, c, residual] = richextrapol(uz(end-2:end),hs)
uz_ref =  -1.119145781010554e-05;
prop = property_deformation_linear_ortho (...
    struct('E1',E1,'E2',E2,'E3',E3,...
    'G12',G12,'G13',G13,'G23',G23,...
    'nu12',nu12,'nu13',nu13,'nu23',nu23));


a=90*u.MM; b=10*u.MM;  t=20*u.MM;
q0 = -1000*u.PA;

[na,nb,nt] =adeal(1*[1,1,1]);
tolerance =t/nt/100;
u_scale  = 10000;
graphics =~ true;

Rm= rotmat(aangle/180*pi* [0,0,1]);

mater = material_deformation_linear_triax (struct('property',prop ));

clear eltyd
eix=1;
 
        eltyd(eix).description ='T10MS';% tetrahedron
        eltyd(eix).mf =@(ref)T10MS_block(a,b,t,ref*na,ref*nb,ref*nt);
        eltyd(eix).femmf =@(fes)femm_deformation_linear_t10ms(struct('fes',fes,'material',mater,'Rm',Rm,...
        'integration_rule',tet_rule(struct('npts',1))));
        eltyd(eix).surface_integration_rule=tri_rule(struct('npts',3));
        eltyd(eix).styl='b^-';
        eix=eix+1;
    
eltyd(eix).description ='H20R';
eltyd(eix).mf =@(ref)H20_block(a,b,t,ref*na,ref*nb,ref*nt);
eltyd(eix).femmf =@(fes)femm_deformation_linear(struct('fes',fes, 'material',mater,...
    'Rm',Rm,...
    'integration_rule',gauss_rule(struct('dim',3, 'order',2))));
eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',2));
eix=eix+1;

    eltyd(eix).description ='T10';% tetrahedron
    eltyd(eix).mf =@(ref)T10_block(a,b,t,ref*na,ref*nb,ref*nt);
    eltyd(eix).femmf =@(fes)femm_deformation_linear(struct('fes',fes,'material',mater,'Rm',Rm,...
        'integration_rule',tet_rule(struct('npts',4))));
    eltyd(eix).surface_integration_rule=tri_rule(struct('npts',3));
    eix=eix+1;

eltyd(eix).description ='H8-GSRI';%
eltyd(eix).mf =@(ref)H8_block(a,b,t,2*ref*na,2*ref*nb,2*ref*nt);
eltyd(eix).femmf =@(fes)femm_deformation_linear_gsri(struct('fes',fes,'material',mater,...
    'Rm',Rm,...
    'integration_rule_constrained',gauss_rule(struct('dim',3, 'order',1)),...
    'integration_rule_unconstrained',gauss_rule(struct('dim',3, 'order',2))));
eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',2));
eix=eix+1;
 
eltyd(eix).description ='H8MSGSO';%
eltyd(eix).mf =@(ref)H8_block(a,b,t,2*ref*na,2*ref*nb,2*ref*nt);
eltyd(eix).femmf =@(fes)femm_deformation_nonlinear_h8msgso(struct('fes',fes,'material',mater,...
    'Rm',Rm,...
    'integration_rule',gauss_rule(struct('dim',3, 'order',2))));
eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',2));
eix=eix+1;
 
% eltyd(eix).description ='T10-GSRI';
% eltyd(eix).mf =@(ref)T10_block(a,b,t,ref*na,ref*nb,ref*nt);
% eltyd(eix).femmf =@(fes)femm_deformation_linear_gsri(struct('fes',fes, 'material',mater,...
%     'Rm',Rm,...
%     'integration_rule_constrained',tet_rule(struct('npts',1)),...
%     'integration_rule_unconstrained',tet_rule(struct('npts',4))));
% eltyd(eix).surface_integration_rule=tri_rule(struct('npts',3));
% eltyd(eix).styl='kv-';
% eix=eix+1;

%         eltyd(eix).description ='H20R';
%         eltyd(eix).mf =@(ref)H20_block(a,b,t,ref*na,ref*nb,ref*nt);
%         eltyd(eix).femmf =@(fes)fem_deformation_linear(struct('fes',fes, 'material',mater,...
%             'Rm',Rm,...
%             'integration_rule',gauss_rule(struct('dim',3, 'order',2))));
%         eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',2));
%         eltyd(eix).styl='ro-';
%         eix=eix+1;
%
%         eltyd(eix).description ='H20';
%         eltyd(eix).mf =@(ref)H20_block(a,b,t,ref*na,ref*nb,ref*nt);
%         eltyd(eix).femmf =@(fes)fem_deformation_linear(struct('fes',fes, 'material',mater,...
%             'Rm',Rm,...
%             'integration_rule',gauss_rule(struct('dim',3, 'order',3))));
%         eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',2));
%         eltyd(eix).styl='bo-';
%         eix=eix+1;

%         eltyd(eix).description ='H64';
%         eltyd(eix).mf =@(ref)H64_block(a,b,t,ref*na,ref*nb,ref*nt);
%         eltyd(eix).femmf =@(fes)fem_deformation_linear(struct('fes',fes, 'material',mater,...
%             'Rm',Rm,...
%             'integration_rule',gauss_rule(struct('dim',3, 'order',4))));
%         eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',3));
%         eltyd(eix).styl='ch-';
%         eix=eix+1;

%         eltyd(eix).description ='H27';
%         eltyd(eix).mf =@(ref)H27_block(a,b,t,ref*na,ref*nb,ref*nt);
%         eltyd(eix).femmf =@(fes)fem_deformation_linear(struct('fes',fes, 'material',mater,...
%             'Rm',Rm,...
%             'integration_rule',gauss_rule(struct('dim',3, 'order',3))));
%         eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',3));
%         eltyd(eix).styl='cd-';
%         eix=eix+1;
%
%         eltyd(eix).description ='T10';% tetrahedron
%         eltyd(eix).mf =@(ref)T10_block(a,b,t,ref*na,ref*nb,ref*nt);
%         eltyd(eix).femmf =@(fes)fem_deformation_linear(struct('fes',fes,'material',mater,...
%             'Rm',Rm,'integration_rule',tet_rule(struct('npts',4))));
%         eltyd(eix).surface_integration_rule=tri_rule(struct('npts',3));
%         eltyd(eix).styl='gd-';
%         eix=eix+1;
%
%         eltyd(eix).description ='H8';
%         eltyd(eix).mf =@(ref)H8_block(a,b,t,2*ref*na,2*ref*nb,2*ref*nt);
%         eltyd(eix).femmf =@(fes)femm_deformation_linear(struct('fes',fes, 'material',mater,...
%             'Rm',Rm,...
%             'integration_rule', gauss_rule(struct('dim',3, 'order',2))));
%         eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',3));
%         eltyd(eix).styl='rh-';
%         eix=eix+1;
%
%     eltyd(eix).description ='H8-Bbar';
%     eltyd(eix).mf =@(ref)H8_block(a,b,t,2*ref*na,2*ref*nb,2*ref*nt);
%     eltyd(eix).femmf =@(fes)femm_deformation_linear_bbar(struct('fes',fes, 'material',mater,...
%         'Rm',Rm,...
%         'integration_rule_constrained', gauss_rule(struct('dim',3, 'order',1)),...
%         'integration_rule_unconstrained', gauss_rule(struct('dim',3, 'order',2))));
%     eltyd(eix).surface_integration_rule=gauss_rule(struct('dim',2, 'order',3));
%     eltyd(eix).styl='gs--';
%     eix=eix+1;

legends ={};
for eix = 1:length(eltyd)
    ns=[];
    uzs=[];
    uys=[];
    
    disp(['%' eltyd(eix).description ': ' ])
    disp(['uz=[' ])
    %         for ref = [4,8,16]
    refs = [2,4,8,16];
    refs = [2:6];
    for ref = refs
        
        % Mesh
        [fens,fes] = eltyd(eix).mf(ref);
        
        % Compose the model data
        clear model_data
        model_data.fens =fens;
        
        clear region
        region.fes= fes;
        region.femm= eltyd(eix).femmf(fes);
        model_data.region{1} =region;
        
        clear essential
        essential.component= [1,2,3];
        essential.fixed_value= 0;
        essential.node_list = fenode_select(fens, struct('box', [0,0,-Inf,Inf,-Inf,Inf],...
            'inflate',tolerance));
        model_data.boundary_conditions.essential{1} = essential;
        
        clear traction
        bdry_fes = mesh_boundary(fes, []);
        bcl = fe_select(fens, bdry_fes, ...
            struct ('box',[a,a,-Inf,Inf,-Inf,Inf],'inflate',tolerance));
        traction.fes =subset(bdry_fes,bcl);;
        traction.traction= [0;0; q0];
        traction.integration_rule =eltyd(eix).surface_integration_rule;
        model_data.boundary_conditions.traction{1} = traction;
        
        model_data.renumber=true;
        
        % Solve
        model_data =deformation_linear_statics(model_data);
        
        
        nc=[fenode_select(fens, struct('box', [a,a,b,b,0,0],...
            'inflate',tolerance))];
        ab_displacement=gather_values(model_data.u,nc);
        nc=[fenode_select(fens, struct('box', [a,a,0,0,0,0],...
            'inflate',tolerance))];
        a0_displacement=gather_values(model_data.u,nc);
        abz =mean(ab_displacement(:,3) );
        aby =mean(ab_displacement(:,2) );
        disp([ num2str(abz)])
        ns=[ns,model_data.u.nfreedofs];
        uzs=[uzs,abz];
        uys=[uys,aby];
        
       if (graphics )
            figure
            model_data.postprocessing.u_scale= u_scale;
            model_data.postprocessing.stress_component=2;
            %                     options=deformation_plot_stress(model_data, options)
            model_data=deformation_plot_deformation(model_data);
            anchor =[0,5*b,0]; tip = anchor +3*b*Rm(:, 1)';
            draw_arrow (model_data.postprocessing.gv,...
                anchor, tip-anchor, struct('facecolor', 'black'));
            draw_polyline(model_data.postprocessing.gv,...
                [anchor;  [tip(1),anchor(2),anchor(3)]; tip], [1,2;2,3],  struct('facecolor', 'black'))
            draw_polyline(model_data.postprocessing.gv,...
                [anchor;  [anchor(1),tip(2),anchor(3)]; tip], [1,2;2,3],  struct('facecolor', 'black'))
            draw_polyline(model_data.postprocessing.gv,...
                [anchor;  [anchor(1),anchor(2),tip(3)]; tip], [1,2;2,3],  struct('facecolor', 'black'))
        end
    end
    disp([']; %' eltyd(eix).description  ])
    disp(['hs=[' num2str(refs) '];' ])
    
    %         [xestim, beta, c, residual] = richextrapol(uzs(end-2:end),refs(end-2:end));
    if (~graphics )
        loglog(ns,abs(uzs/uz_ref-1),name_to_style(eltyd(eix).description),'linewidth',3); hold on
        %                 plot(ns,uys,eltyd(eix).styl,'linewidth',3); hold on
        %                 plot(diff(ns),diff(uzs),eltyd(eix).styl,'linewidth',3); hold on
        figure (gcf); pause (1)
    end
    legends{end+1} =eltyd(eix).description;
end
legend (legends);
title (['Fiber dir =[' num2str(Rm(:,1)') ']'])
labels(  'Number of equations', 'Estimated true error')
grid on
set_graphics_defaults
% clear options
% options.u_scale= scale;
% options.stress_component= 1;
% options=deformation_plot_stress(model_data, options)
end
