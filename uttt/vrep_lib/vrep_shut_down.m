function vrep_shut_down(clientID, vrep)

    % stop the simulation:
    vrep.simxStopSimulation(clientID,vrep.simx_opmode_oneshot_wait);

    % Now close the connection to V-REP:	
    vrep.simxFinish(clientID);
    
end