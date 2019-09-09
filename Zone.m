classdef Zone
    properties
        iteration
        id_zone
        id_zones
        id_radiator_inlets
        id_radiator_outlets
        wall_thicknesses
        wall_surfaces
        window_thicknesses
        window_surfaces
        heat_transfer_coefficient_radiators
        time_step
        matrix_size
        matrix_coefficients
        right_hand_side_vector
        
        
    end
    
    methods
        function obj = Zone(id_zone, id_zones, id_radiator_inlets, id_radiator_outlets, solver, wall_thicknesses, wall_surfaces, window_thicknesses, window_surfaces, heat_transfer_coefficient_radiators)
            if nargin > 0
                obj.id_zone = id_zone;
                obj.id_zones = id_zones;
                obj.id_radiator_inlets = id_radiator_inlets;
                obj.id_radiator_outlets = id_radiator_outlets;
                obj.time_step = solver.time_step;
                obj.matrix_size = solver.matrix_size;
                obj.wall_thicknesses = wall_thicknesses;
                obj.wall_surfaces = wall_surfaces;
                obj.window_thicknesses = window_thicknesses;
                obj.window_surfaces = window_surfaces;
                obj.heat_transfer_coefficient_radiators = heat_transfer_coefficient_radiators;

                obj.iteration = 0;
                obj.matrix_coefficients = zeros(1,solver.matrix_size);
                obj.right_hand_side_vector = 0;
                
            end
        end
        
        % equivalent heat transfer coefficient of wall
        function U = wall_heat_transfer(obj, d_w)
            U = 1/(obj.r_w_o+d_w/obj.k_w+obj.r_w_i);
        end
        
        % equivalent heat transfer coefficient of window
        function U = window_heat_transfer(obj, d_win)
            U = 1/(obj.r_win_o+d_win/obj.k_win+obj.r_win_gap+obj.r_win_i);
        end
        
        % coefficient of radiator inlet temperature
        function c = c_tri(obj, a_r)
            c = -obj.u_r*a_r/2;
        end
        
        % coefficient of radiator outlet temperature
        function c = c_tro(obj, a_r)
            c = -obj.u_r*a_r/2;
        end
        
        % coefficient of zone temperature
        function c = c_tz(obj, dt, v_a, a_r_total, d_w, a_w, v_w, d_win, a_win)
            c = (obj.rho_a*v_a*obj.c_a+obj.rho_w*v_w*obj.c_w)/dt + obj.u_r*a_r_total + obj.wall_heat_transfer(d_w)*a_w + obj.window_heat_transfer(d_win)*a_win;
        end
        
        % right-hand coefficient
        function c = c_r(obj, dt, v_a, d_w, a_w, v_w, d_win, a_win, T_e, T_o) 
            c = ((obj.rho_a*v_a*obj.c_a+obj.rho_w*v_w*obj.c_w)/dt)*T_e + (obj.wall_heat_transfer(d_w)*a_w+obj.window_heat_transfer(d_win)*a_win)*T_o;
        end
        
        % create matrix of coefficients and right-hand side vector
        function obj = create(obj, solver)
            obj.iteration = obj.iteration + 1;
            obj.matrix_coefficients = zeros(1,obj.matrix_size);
            obj.right_hand_side_vector = 0;
            for i=1:length(obj.id_inlets)
                obj.temperature_inlets(i) = solver.temperatures(obj.id_inlets(i));
                obj.matrix_coefficients(obj.id_inlets(i)) = obj.c_ti(i);
            end
            for i=1:length(obj.id_outlets)
                obj.temperature_outlets(i) = solver.temperatures(obj.id_outlets(i));
                obj.matrix_coefficients(obj.id_outlets(i)) = obj.c_to(i);
            end
        end

    end
end