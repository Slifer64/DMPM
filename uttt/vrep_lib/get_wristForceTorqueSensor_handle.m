function wristForceTorqueSensor = get_wristForceTorqueSensor_handle(clientID, vrep, wristForceSennsor_id, enable_forceData_streaming)
    
    force_torque_sensor_name = ['Wrist_force_torque_sensor' wristForceSennsor_id];
    [err_code, wristForceTorqueSensor] = vrep.simxGetObjectHandle(clientID,force_torque_sensor_name,vrep.simx_opmode_blocking);
    if (err_code), error('Error getting %s handle!\nError message: %s\n',force_torque_sensor_name,get_vrep_error_code_string(err_code)), end

    if (enable_forceData_streaming)
        [err_code, wrist_state, wrist_force, wrist_torque] = vrep.simxReadForceSensor(clientID,wristForceTorqueSensor,vrep.simx_opmode_streaming);
        if (err_code>1), error('Error enabling force-torque sensor data streaming! Error message: %s\n',get_vrep_error_code_string(err_code)), end
    end
end

function [wrist_state, wrist_force, wrist_torque] = get_WristForceTorqueSensor_data(clientID, vrep, WristForceTorqueSensor)

    [err_code, wrist_state, wrist_force, wrist_torque] = vrep.simxReadForceSensor(clientID,WristForceTorqueSensor,vrep.simx_opmode_buffer);
    if (err_code>1), error('Error getting wrist force-torque sensor data\nError message: %s\n',get_vrep_error_code_string(err_code)); end
    
end