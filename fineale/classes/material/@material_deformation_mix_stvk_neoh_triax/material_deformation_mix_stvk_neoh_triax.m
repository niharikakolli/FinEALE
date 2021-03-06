classdef material_deformation_mix_stvk_neoh_triax < material_deformation_triax
% Class that represents deformable nonlinear hyperelastic 
% materials of the St.Venant-Kirchhoff type.
    %
    
    properties
        D=[]; % The 6 x 6 constant constitutive matrix.
        mix = 0.75;
    end
    
    properties (Access = private)
        mI = diag([1 1 1 0.5 0.5 0.5]);
        m1     = [1 1 1 0 0 0]';
        m1m1 =[1 1 1 0 0 0]'*[1 1 1 0 0 0]; %m1 * m1'
    end
    
    methods
        
        function self = material_deformation_mix_stvk_neoh_triax(Parameters)
            % Constructor.
            % Parameters:
            % none
            %
            % See discussion of constructors in <a href="matlab:helpwin 'fineale/classes/Contents'">classes/Contents</a>.
            if (nargin < 1)
                Parameters =struct( [] );
            end
            self = self@material_deformation_triax(Parameters);
            self.D = tangent_moduli(self.property, []);% 
        end
        
        function [out, newms] = state(self, ms, context)
            % Retrieve material state. 
            %
            %   function [out, newms] = state(self, ms, context)
            %
            % The method is used with either one output argument or with
            % two output arguments.
            % 1.  With only "out" as output argument:  Retrieve the
            %     the requested variable from the material state. 
            % 2.  With both output arguments: Update the material state,
            %     and return the requested variable from the material state 
            %     and the updated material state.
            %
            %     The requested quantity may or may not be supported by
            %     the particular material model.(default is the stress). 
            %
            %   Input arguments:
            % self=material
            % ms = material state
            % context=structure
            %    with mandatory fields
            %       Fn1= current deformation gradient (at time t_n+1)
            %       Fn=  previous converged deformation gradient (at time t_n)
            %    and optional fields
            %       output=type of quantity to output, and interpreted by the
            %           particular material; [] is returned when the material 
            %           does not recognize the requested quantity to indicate 
            %           uninitialized value.  It can be tested with isempty().
            %           output ='Cauchy' - Cauchy stress; this is the default
            %              when output type is not specified.
            %           output ='2ndPK' - 2nd Piola-Kirchhoff stress;
            %                  
            %              output ='strain_energy'
            %    It is assumed that stress is output in 6-component vector
            %    form. 
            %
            %   Output arguments:
            % out=requested quantity
            % newms=new material state; don't forget that if the update is
            %       final the material state newms must be assigned and
            %       stored.  Otherwise the material update is lost!
            %
            
            E = self.property.E;
            nu = self.property.nu;
            lambda = E * nu / (1 + nu) / (1 - 2*(nu));          % Lame constant #1
            mu     = E / (2 * (1 + nu));                        % shear modulus
                    
            % Get the basic kinematic variables
            Fn1 = context.Fn1;
            Fn  = context.Fn;
            dt  = context.dt;
            J=det(Fn1);
            
            % 1. St. Venant-Kirchhoff material
            C=Fn1'*Fn1;% Cauchy-Green deformation tensor
            % Green-Lagrange strain
            Egl=self.strain_3x3t_to_6v(1/2*(C-eye(3,3)));;
            S = self.D*Egl;
            sigma1=Fn1*(self.stress_6v_to_3x3t(S)/J)*Fn1';
            
            % 2. Neohookean material
            b=Fn1*Fn1'; % Finger deformation tensor
            sigma2 = (mu/J) * (b - eye(3,3)) + (lambda *log(J)/J) * eye(3,3);
            
            % Produce a mixture
            sigma =self.mix*sigma1+(1.0-self.mix)*sigma2 ;
            
            out =get_var();
            newms = ms;
            return;
            
            function out =get_var()
                switch context.output
                    case 'Cauchy'
                        out = self.stress_3x3t_to_6v(sigma);
                    case'strain_energy'
                        C=Fn1'*Fn1;
                        out = mu/2*(trace(C)-3) - mu*log(J) + lambda/2*(log(J))^2;
                    case '2ndPK'
                        invF1=inv(Fn1);
                        S = J * (invF1*sigma*invF1');
                        out= self.stress_3x3t_to_6v(S);
                    case 'pressure'
                        out = -(sum(diag(sigma))/3);
                    case 'princCauchy'
                        [V,D]=eig(sigma);
                        out =sort(diag(D),'descend');
                    case {'vonMises','vonmises','von_mises','vm'}
                        stress = self.stress_3x3t_to_6v(sigma);
                        s1=stress(1);s2=stress(2);s3=stress(3);
                        s4=stress(4);s5=stress(5);s6=stress(6);
                        out = sqrt(1/2*((s1-s2)^2+(s1-s3)^2+(s2-s3)^2+6*(s4^2+s5^2+s6^2)));
                    case 'equiv_pl_def'
                        out =0.0;
                    otherwise
                        out = [];
                end
            end
        end
        
        function D = tangent_moduli(self, context)
            % Calculate the material stiffness matrix.
            %   Call as:
            %     D = tangent_moduli(m, context)
            %   where
            %     m=material
            %    context=struct
            % with fields
            %  - mandatory
            %  - optional
            %     stiff_type=type of the stiffness,
            %        either 'Lagrangean'
            %        or 'Eulerian'
            %              requires field 'F'= current deformation gradient
            % the output arguments are
            %     D=matrix 6x6
            %
            stiff_type='Eulerian';
            if isfield(context,'stiff_type')
                stiff_type= context.stiff_type;
            end
            switch (stiff_type)
                case 'Eulerian'
                    % 1. St. Venant-Kirchhoff material
                    D1 = Lagrangean_to_Eulerian(self, self.D, context.Fn1);
                    
                    E = self.property.E;
                    nu = self.property.nu;
                    J =det(context.Fn1);
                    lambda = E * nu / (1 + nu) / (1 - 2*(nu));          % Lame constant #1
                    mu     = E / (2 * (1 + nu));                        % shear modulus
                    D2 = (lambda / J) * self.m1m1 + 2 * (mu - lambda*log(J))/J * self.mI;
                    % Produce a mixture
                    D =self.mix*D1+(1.0-self.mix)*D2 ;
                    return;
                otherwise
                    error('Cannot handle');
                    D=[]; % return non-usable value
                    return;
            end
        end
        
        function val = are_tangent_moduli_constant (self)
        % Is the material stiffness matrix independent of location (constant, 
        % corresponding to a homogeneous material)?
            val =are_tangent_moduli_constant(self.property);
        end
             
    end
    
end

