%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%Returns material refractive index to the main script, ...
%The Sellmeier Equation, refractive ...
%index values, and reflectivity values can be found at http://...
%refractiveindex.info/.
function [n0, n2, delta, me, Trans] = material_flag1(matFlag,...
    lambda, me0, e)% inputs: (matFlag, lambda, m_e,e)
% Use a switch/case structure to select between different materials
% Values for matFlag:

 % 1: ZnSe

 % 2: ZnS

 switch matFlag
 
%ZnSe
     case 1
      
         delta_eV = 2.71;
         delta = delta_eV * e;%in J
         me = 0.17 * me0;
         n0 = sqrt(1 + 4.45813734*lambda^2/(lambda^2-0.200859853^2) + ...
             0.467216334*lambda^2/(lambda^2-0.391371166^2) + ...
             2.89566290*lambda^2/(lambda^2-47.1362108^2));
         n2 = 6.5e-19; %@9.2 um
         %n2 = 2.3e-18; %@1030 nm, use it for 800 nm 
         %Ref = 0.32949; % 800nm
         Ref = 0.31059; % 9200nm
         Trans = 1-Ref;
         
  
 % ZnS
     case 2
        
         delta_eV = 3.6;
         delta= delta_eV * e;
         %me = 0.16 * me0;
         me = 0.34 * me0;
         n0 = sqrt(8.393 + 0.14383/(lambda^2-0.2421^2) + ...
             4430.99/(lambda^2-36.71^2)); % use http://refractiveindex.info.../;
         n2 = 4.0e-19; %@9.2 um
         %n2 = 6.8e-19; %@1030 nm, use it for 800 nm 
   
         Ref = 0.26693; % 9200nm
         %Ref = 0.38251; % 800nm
         Trans = 1-Ref;
 
     otherwise
         disp('Warning: Invalid material parameters');
         return
 end
end