function [visionSensorHandle, robotBaseHandle, ObjectFrameHandle, TargetHandle] = get_scence_object_handles(clientID,vrep,robot_id)
    
	visionSensorHandle = get_object_handle(clientID,vrep,'Vision_sensor');

	robotBaseHandle = get_object_handle(clientID,vrep,['base_dummy' robot_id]);
	
	ObjectFrameHandle = get_object_handle(clientID,vrep,'Object_frame');
	
	TargetHandle = get_object_handle(clientID,vrep,'Target');

end