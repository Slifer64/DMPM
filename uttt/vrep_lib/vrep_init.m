function [clientID, vrep] = vrep_init(simulation_time_step)

    vrep=remApi('remoteApi'); % using the prototype file (remoteApiProto.m)
	vrep.simxFinish(-1); % just in case, close all opened connections
	clientID=vrep.simxStart('127.0.0.1',19997,true,true,5000,5);
    if (clientID < 0)
        error('Error initializing V-REP!\nFailed connecting to remote API server...\n');
    end
    
    %set time step
    vrep.simxSetFloatingParameter(clientID,vrep.sim_floatparam_simulation_time_step, simulation_time_step, vrep.simx_opmode_oneshot_wait);

end