%function Ja_dot = lwr4_jacob_dot(q, dq)
 
    q = sym('q',[7,1]);
    dq = sym('dq',[7,1]);
    
%     Ja = zeros(6,7);
%     Ja_dot = zeros(6,7);
    
%     s=[0,0,0,0,0,0,0]';  
%     c=s;
%     for i=1:7
%         c(i) = cos(q(i));
%         s(i) = sin(q(i));
%     end
    
    syms Ja Ja_dot

    Ja(1,1)   =  0.4*sin(q(1))*sin(q(2))+0.39*cos(q(4))*sin(q(1))*sin(q(2))-0.39*cos(q(1))*sin(q(3))*sin(q(4))-0.39*cos(q(2))*cos(q(3))*sin(q(1))*sin(q(4))+0.088*cos(q(4))*cos(q(6))*sin(q(1))*sin(q(2))-0.088*cos(q(1))*cos(q(6))*sin(q(3))*sin(q(4))+0.088*cos(q(1))*cos(q(3))*sin(q(5))*sin(q(6))-0.088*cos(q(2))*sin(q(1))*sin(q(3))*sin(q(5))*sin(q(6))+0.088*cos(q(5))*sin(q(1))*sin(q(2))*sin(q(4))*sin(q(6))-0.088*cos(q(2))*cos(q(3))*cos(q(6))*sin(q(1))*sin(q(4))+0.088*cos(q(1))*cos(q(4))*cos(q(5))*sin(q(3))*sin(q(6))+0.088*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(6));
    Ja(1,2)   = -cos(q(1))*(0.4*cos(q(2))+0.39*cos(q(2))*cos(q(4))+0.088*cos(q(2))*cos(q(4))*cos(q(6))+0.39*cos(q(3))*sin(q(2))*sin(q(4))+0.088*cos(q(3))*cos(q(6))*sin(q(2))*sin(q(4))+0.088*cos(q(2))*cos(q(5))*sin(q(4))*sin(q(6))+0.088*sin(q(2))*sin(q(3))*sin(q(5))*sin(q(6))-0.088*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(2))*sin(q(6)));
    Ja(1,3)   =  0.088*cos(q(1))*cos(q(2))*cos(q(3))*sin(q(5))*sin(q(6))-0.39*cos(q(3))*sin(q(1))*sin(q(2))^2*sin(q(4))-0.39*cos(q(1))*cos(q(2))*sin(q(3))*sin(q(4))-0.088*cos(q(2))^2*cos(q(3))*cos(q(6))*sin(q(1))*sin(q(4))-0.088*cos(q(3))*cos(q(6))*sin(q(1))*sin(q(2))^2*sin(q(4))-0.088*cos(q(2))^2*sin(q(1))*sin(q(3))*sin(q(5))*sin(q(6))-0.088*sin(q(1))*sin(q(2))^2*sin(q(3))*sin(q(5))*sin(q(6))-0.088*cos(q(1))*cos(q(2))*cos(q(6))*sin(q(3))*sin(q(4))-0.39*cos(q(2))^2*cos(q(3))*sin(q(1))*sin(q(4))+0.088*cos(q(1))*cos(q(2))*cos(q(4))*cos(q(5))*sin(q(3))*sin(q(6))+0.088*cos(q(2))^2*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(6))+0.088*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(2))^2*sin(q(6));
    Ja(1,4)   =  0.39*cos(q(1))*cos(q(3))^2*sin(q(2))*sin(q(4))-0.39*cos(q(2))^2*cos(q(4))*sin(q(1))*sin(q(3))+0.39*cos(q(1))*sin(q(2))*sin(q(3))^2*sin(q(4))-0.39*cos(q(4))*sin(q(1))*sin(q(2))^2*sin(q(3))+0.39*cos(q(1))*cos(q(2))*cos(q(3))*cos(q(4))+0.088*cos(q(1))*cos(q(3))^2*cos(q(6))*sin(q(2))*sin(q(4))-0.088*cos(q(2))^2*cos(q(4))*cos(q(6))*sin(q(1))*sin(q(3))+0.088*cos(q(1))*cos(q(6))*sin(q(2))*sin(q(3))^2*sin(q(4))-0.088*cos(q(4))*cos(q(6))*sin(q(1))*sin(q(2))^2*sin(q(3))+0.088*cos(q(1))*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(6))-0.088*cos(q(5))*sin(q(1))*sin(q(2))^2*sin(q(3))*sin(q(4))*sin(q(6))+0.088*cos(q(1))*cos(q(2))*cos(q(3))*cos(q(5))*sin(q(4))*sin(q(6))-0.088*cos(q(1))*cos(q(3))^2*cos(q(4))*cos(q(5))*sin(q(2))*sin(q(6))-0.088*cos(q(1))*cos(q(4))*cos(q(5))*sin(q(2))*sin(q(3))^2*sin(q(6))-0.088*cos(q(2))^2*cos(q(5))*sin(q(1))*sin(q(3))*sin(q(4))*sin(q(6));
    Ja(1,5)   =  sin(q(6))*(0.088*cos(q(5))*sin(q(1))*cos(q(2))^2*cos(q(3))*cos(q(4))^2+0.088*cos(q(5))*sin(q(1))*cos(q(2))^2*cos(q(3))*sin(q(4))^2-0.088*sin(q(1))*sin(q(5))*cos(q(2))^2*cos(q(4))*sin(q(3))+0.088*cos(q(1))*sin(q(5))*cos(q(2))*cos(q(3))*cos(q(4))+0.088*cos(q(1))*cos(q(5))*cos(q(2))*cos(q(4))^2*sin(q(3))+0.088*cos(q(1))*cos(q(5))*cos(q(2))*sin(q(3))*sin(q(4))^2+0.088*cos(q(1))*sin(q(5))*cos(q(3))^2*sin(q(2))*sin(q(4))+0.088*cos(q(5))*sin(q(1))*cos(q(3))*cos(q(4))^2*sin(q(2))^2+0.088*cos(q(5))*sin(q(1))*cos(q(3))*sin(q(2))^2*sin(q(4))^2-0.088*sin(q(1))*sin(q(5))*cos(q(4))*sin(q(2))^2*sin(q(3))+0.088*cos(q(1))*sin(q(5))*sin(q(2))*sin(q(3))^2*sin(q(4)));
    Ja(1,6)   =  0.088*cos(q(6))*sin(q(1))*cos(q(2))^2*cos(q(3))*cos(q(4))^2*sin(q(5))+0.088*cos(q(6))*sin(q(1))*cos(q(2))^2*cos(q(3))*sin(q(4))^2*sin(q(5))+0.088*cos(q(6))*sin(q(1))*cos(q(2))^2*cos(q(4))*cos(q(5))*sin(q(3))+0.088*sin(q(1))*sin(q(6))*cos(q(2))^2*cos(q(5))^2*sin(q(3))*sin(q(4))+0.088*sin(q(1))*sin(q(6))*cos(q(2))^2*sin(q(3))*sin(q(4))*sin(q(5))^2-0.088*cos(q(1))*cos(q(6))*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))-0.088*cos(q(1))*sin(q(6))*cos(q(2))*cos(q(3))*cos(q(5))^2*sin(q(4))-0.088*cos(q(1))*sin(q(6))*cos(q(2))*cos(q(3))*sin(q(4))*sin(q(5))^2+0.088*cos(q(1))*cos(q(6))*cos(q(2))*cos(q(4))^2*sin(q(3))*sin(q(5))+0.088*cos(q(1))*cos(q(6))*cos(q(2))*sin(q(3))*sin(q(4))^2*sin(q(5))+0.088*cos(q(1))*sin(q(6))*cos(q(3))^2*cos(q(4))*cos(q(5))^2*sin(q(2))+0.088*cos(q(1))*sin(q(6))*cos(q(3))^2*cos(q(4))*sin(q(2))*sin(q(5))^2-0.088*cos(q(1))*cos(q(6))*cos(q(3))^2*cos(q(5))*sin(q(2))*sin(q(4))+0.088*cos(q(6))*sin(q(1))*cos(q(3))*cos(q(4))^2*sin(q(2))^2*sin(q(5))+0.088*cos(q(6))*sin(q(1))*cos(q(3))*sin(q(2))^2*sin(q(4))^2*sin(q(5))+0.088*cos(q(1))*sin(q(6))*cos(q(4))*cos(q(5))^2*sin(q(2))*sin(q(3))^2+0.088*cos(q(6))*sin(q(1))*cos(q(4))*cos(q(5))*sin(q(2))^2*sin(q(3))+0.088*cos(q(1))*sin(q(6))*cos(q(4))*sin(q(2))*sin(q(3))^2*sin(q(5))^2+0.088*sin(q(1))*sin(q(6))*cos(q(5))^2*sin(q(2))^2*sin(q(3))*sin(q(4))-0.088*cos(q(1))*cos(q(6))*cos(q(5))*sin(q(2))*sin(q(3))^2*sin(q(4))+0.088*sin(q(1))*sin(q(6))*sin(q(2))^2*sin(q(3))*sin(q(4))*sin(q(5))^2;
    Ja(1,7)   =  0;
    Ja(2,1)   =  0.39*cos(q(1))*cos(q(2))*cos(q(3))*sin(q(4))-0.39*cos(q(1))*cos(q(4))*sin(q(2))-0.39*sin(q(1))*sin(q(3))*sin(q(4))-0.4*cos(q(1))*sin(q(2))-0.088*cos(q(1))*cos(q(4))*cos(q(6))*sin(q(2))-0.088*cos(q(6))*sin(q(1))*sin(q(3))*sin(q(4))+0.088*cos(q(3))*sin(q(1))*sin(q(5))*sin(q(6))+0.088*cos(q(1))*cos(q(2))*sin(q(3))*sin(q(5))*sin(q(6))-0.088*cos(q(1))*cos(q(5))*sin(q(2))*sin(q(4))*sin(q(6))+0.088*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(3))*sin(q(6))+0.088*cos(q(1))*cos(q(2))*cos(q(3))*cos(q(6))*sin(q(4))-0.088*cos(q(1))*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(6));
    Ja(2,2)   = -sin(q(1))*(0.4*cos(q(2))+0.39*cos(q(2))*cos(q(4))+0.088*cos(q(2))*cos(q(4))*cos(q(6))+0.39*cos(q(3))*sin(q(2))*sin(q(4))+0.088*cos(q(3))*cos(q(6))*sin(q(2))*sin(q(4))+0.088*cos(q(2))*cos(q(5))*sin(q(4))*sin(q(6))+0.088*sin(q(2))*sin(q(3))*sin(q(5))*sin(q(6))-0.088*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(2))*sin(q(6)));
    Ja(2,3)   =  0.39*cos(q(1))*cos(q(2))^2*cos(q(3))*sin(q(4))+0.39*cos(q(1))*cos(q(3))*sin(q(2))^2*sin(q(4))-0.39*cos(q(2))*sin(q(1))*sin(q(3))*sin(q(4))-0.088*cos(q(2))*cos(q(6))*sin(q(1))*sin(q(3))*sin(q(4))+0.088*cos(q(2))*cos(q(3))*sin(q(1))*sin(q(5))*sin(q(6))+0.088*cos(q(1))*cos(q(2))^2*cos(q(3))*cos(q(6))*sin(q(4))+0.088*cos(q(1))*cos(q(3))*cos(q(6))*sin(q(2))^2*sin(q(4))+0.088*cos(q(1))*cos(q(2))^2*sin(q(3))*sin(q(5))*sin(q(6))+0.088*cos(q(1))*sin(q(2))^2*sin(q(3))*sin(q(5))*sin(q(6))+0.088*cos(q(2))*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(3))*sin(q(6))-0.088*cos(q(1))*cos(q(2))^2*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(6))-0.088*cos(q(1))*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(2))^2*sin(q(6));
    Ja(2,4)   =  0.39*cos(q(1))*cos(q(2))^2*cos(q(4))*sin(q(3))+0.39*cos(q(1))*cos(q(4))*sin(q(2))^2*sin(q(3))+0.39*cos(q(3))^2*sin(q(1))*sin(q(2))*sin(q(4))+0.39*sin(q(1))*sin(q(2))*sin(q(3))^2*sin(q(4))+0.39*cos(q(2))*cos(q(3))*cos(q(4))*sin(q(1))+0.088*cos(q(1))*cos(q(2))^2*cos(q(4))*cos(q(6))*sin(q(3))+0.088*cos(q(1))*cos(q(4))*cos(q(6))*sin(q(2))^2*sin(q(3))+0.088*cos(q(3))^2*cos(q(6))*sin(q(1))*sin(q(2))*sin(q(4))+0.088*cos(q(6))*sin(q(1))*sin(q(2))*sin(q(3))^2*sin(q(4))+0.088*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(6))*sin(q(1))+0.088*cos(q(2))*cos(q(3))*cos(q(5))*sin(q(1))*sin(q(4))*sin(q(6))+0.088*cos(q(1))*cos(q(2))^2*cos(q(5))*sin(q(3))*sin(q(4))*sin(q(6))-0.088*cos(q(3))^2*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(2))*sin(q(6))+0.088*cos(q(1))*cos(q(5))*sin(q(2))^2*sin(q(3))*sin(q(4))*sin(q(6))-0.088*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(2))*sin(q(3))^2*sin(q(6));
    Ja(2,5)   =  sin(q(6))*(0.088*cos(q(1))*sin(q(5))*cos(q(2))^2*cos(q(4))*sin(q(3))-0.088*cos(q(1))*cos(q(5))*cos(q(2))^2*cos(q(3))*sin(q(4))^2-0.088*cos(q(1))*cos(q(5))*cos(q(2))^2*cos(q(3))*cos(q(4))^2+0.088*sin(q(1))*sin(q(5))*cos(q(2))*cos(q(3))*cos(q(4))+0.088*cos(q(5))*sin(q(1))*cos(q(2))*cos(q(4))^2*sin(q(3))+0.088*cos(q(5))*sin(q(1))*cos(q(2))*sin(q(3))*sin(q(4))^2+0.088*sin(q(1))*sin(q(5))*cos(q(3))^2*sin(q(2))*sin(q(4))-0.088*cos(q(1))*cos(q(5))*cos(q(3))*cos(q(4))^2*sin(q(2))^2-0.088*cos(q(1))*cos(q(5))*cos(q(3))*sin(q(2))^2*sin(q(4))^2+0.088*cos(q(1))*sin(q(5))*cos(q(4))*sin(q(2))^2*sin(q(3))+0.088*sin(q(1))*sin(q(5))*sin(q(2))*sin(q(3))^2*sin(q(4)));
    Ja(2,6)   =  0.088*cos(q(6))*sin(q(1))*cos(q(2))*cos(q(4))^2*sin(q(3))*sin(q(5))-0.088*cos(q(1))*cos(q(6))*cos(q(2))^2*cos(q(3))*sin(q(4))^2*sin(q(5))-0.088*cos(q(1))*cos(q(6))*cos(q(2))^2*cos(q(4))*cos(q(5))*sin(q(3))-0.088*cos(q(1))*sin(q(6))*cos(q(2))^2*cos(q(5))^2*sin(q(3))*sin(q(4))-0.088*cos(q(1))*sin(q(6))*cos(q(2))^2*sin(q(3))*sin(q(4))*sin(q(5))^2-0.088*cos(q(6))*sin(q(1))*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))-0.088*sin(q(1))*sin(q(6))*cos(q(2))*cos(q(3))*cos(q(5))^2*sin(q(4))-0.088*sin(q(1))*sin(q(6))*cos(q(2))*cos(q(3))*sin(q(4))*sin(q(5))^2-0.088*cos(q(1))*cos(q(6))*cos(q(2))^2*cos(q(3))*cos(q(4))^2*sin(q(5))+0.088*cos(q(6))*sin(q(1))*cos(q(2))*sin(q(3))*sin(q(4))^2*sin(q(5))+0.088*sin(q(1))*sin(q(6))*cos(q(3))^2*cos(q(4))*cos(q(5))^2*sin(q(2))+0.088*sin(q(1))*sin(q(6))*cos(q(3))^2*cos(q(4))*sin(q(2))*sin(q(5))^2-0.088*cos(q(6))*sin(q(1))*cos(q(3))^2*cos(q(5))*sin(q(2))*sin(q(4))-0.088*cos(q(1))*cos(q(6))*cos(q(3))*cos(q(4))^2*sin(q(2))^2*sin(q(5))-0.088*cos(q(1))*cos(q(6))*cos(q(3))*sin(q(2))^2*sin(q(4))^2*sin(q(5))+0.088*sin(q(1))*sin(q(6))*cos(q(4))*cos(q(5))^2*sin(q(2))*sin(q(3))^2-0.088*cos(q(1))*cos(q(6))*cos(q(4))*cos(q(5))*sin(q(2))^2*sin(q(3))+0.088*sin(q(1))*sin(q(6))*cos(q(4))*sin(q(2))*sin(q(3))^2*sin(q(5))^2-0.088*cos(q(1))*sin(q(6))*cos(q(5))^2*sin(q(2))^2*sin(q(3))*sin(q(4))-0.088*cos(q(6))*sin(q(1))*cos(q(5))*sin(q(2))*sin(q(3))^2*sin(q(4))-0.088*cos(q(1))*sin(q(6))*sin(q(2))^2*sin(q(3))*sin(q(4))*sin(q(5))^2;
    Ja(2,7)   =  0; 
    Ja(3,1)   =  0;
    Ja(3,2)   = -(cos(q(1))^2+sin(q(1))^2)*(0.4*sin(q(2))+0.39*cos(q(4))*sin(q(2))-0.39*cos(q(2))*cos(q(3))*sin(q(4))+0.088*cos(q(4))*cos(q(6))*sin(q(2))-0.088*cos(q(2))*cos(q(3))*cos(q(6))*sin(q(4))-0.088*cos(q(2))*sin(q(3))*sin(q(5))*sin(q(6))+0.088*cos(q(5))*sin(q(2))*sin(q(4))*sin(q(6))+0.088*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(6)));
    Ja(3,3)   = -sin(q(2))*(cos(q(1))^2+sin(q(1))^2)*(0.39*sin(q(3))*sin(q(4))+0.088*cos(q(6))*sin(q(3))*sin(q(4))-0.088*cos(q(3))*sin(q(5))*sin(q(6))-0.088*cos(q(4))*cos(q(5))*sin(q(3))*sin(q(6)));
    Ja(3,4)   =  (cos(q(1))^2+sin(q(1))^2)*(0.39*cos(q(3))*cos(q(4))*sin(q(2))-0.39*cos(q(2))*cos(q(3))^2*sin(q(4))-0.39*cos(q(2))*sin(q(3))^2*sin(q(4))-0.088*cos(q(2))*cos(q(3))^2*cos(q(6))*sin(q(4))-0.088*cos(q(2))*cos(q(6))*sin(q(3))^2*sin(q(4))+0.088*cos(q(3))*cos(q(4))*cos(q(6))*sin(q(2))+0.088*cos(q(3))*cos(q(5))*sin(q(2))*sin(q(4))*sin(q(6))+0.088*cos(q(2))*cos(q(3))^2*cos(q(4))*cos(q(5))*sin(q(6))+0.088*cos(q(2))*cos(q(4))*cos(q(5))*sin(q(3))^2*sin(q(6)));
    Ja(3,5)   =  sin(q(6))*(cos(q(1))^2+sin(q(1))^2)*(0.088*sin(q(2))*sin(q(5))*cos(q(3))*cos(q(4))-0.088*cos(q(2))*sin(q(5))*cos(q(3))^2*sin(q(4))+0.088*cos(q(5))*sin(q(2))*cos(q(4))^2*sin(q(3))-0.088*cos(q(2))*sin(q(5))*sin(q(3))^2*sin(q(4))+0.088*cos(q(5))*sin(q(2))*sin(q(3))*sin(q(4))^2);
    Ja(3,6)   = -(cos(q(1))^2+sin(q(1))^2)*(0.088*cos(q(2))*sin(q(6))*cos(q(3))^2*cos(q(4))*cos(q(5))^2+0.088*cos(q(2))*sin(q(6))*cos(q(3))^2*cos(q(4))*sin(q(5))^2-0.088*cos(q(2))*cos(q(6))*cos(q(3))^2*cos(q(5))*sin(q(4))+0.088*cos(q(6))*sin(q(2))*cos(q(3))*cos(q(4))*cos(q(5))+0.088*sin(q(2))*sin(q(6))*cos(q(3))*cos(q(5))^2*sin(q(4))+0.088*sin(q(2))*sin(q(6))*cos(q(3))*sin(q(4))*sin(q(5))^2-0.088*cos(q(6))*sin(q(2))*cos(q(4))^2*sin(q(3))*sin(q(5))+0.088*cos(q(2))*sin(q(6))*cos(q(4))*cos(q(5))^2*sin(q(3))^2+0.088*cos(q(2))*sin(q(6))*cos(q(4))*sin(q(3))^2*sin(q(5))^2-0.088*cos(q(2))*cos(q(6))*cos(q(5))*sin(q(3))^2*sin(q(4))-0.088*cos(q(6))*sin(q(2))*sin(q(3))*sin(q(4))^2*sin(q(5))); 
    Ja(3,7)   =  0;
    Ja(4,1)   =  0;
    Ja(4,2)   =  sin(q(1));
    Ja(4,3)   = -cos(q(1))*sin(q(2));
    Ja(4,4)   = -cos(q(3))*sin(q(1))-cos(q(1))*cos(q(2))*sin(q(3));
    Ja(4,5)   =  cos(q(1))*cos(q(2))*cos(q(3))*sin(q(4))-sin(q(1))*sin(q(3))*sin(q(4))-cos(q(1))*cos(q(4))*sin(q(2));
    Ja(4,6)   =  cos(q(3))*cos(q(5))*sin(q(1))+cos(q(1))*cos(q(2))*cos(q(5))*sin(q(3))+cos(q(1))*sin(q(2))*sin(q(4))*sin(q(5))-cos(q(4))*sin(q(1))*sin(q(3))*sin(q(5))+cos(q(1))*cos(q(2))*cos(q(3))*cos(q(4))*sin(q(5));
    Ja(4,7)   =  cos(q(3))*sin(q(1))*sin(q(5))*sin(q(6))-cos(q(6))*sin(q(1))*sin(q(3))*sin(q(4))-cos(q(1))*cos(q(4))*cos(q(6))*sin(q(2))+cos(q(1))*cos(q(2))*sin(q(3))*sin(q(5))*sin(q(6))-cos(q(1))*cos(q(5))*sin(q(2))*sin(q(4))*sin(q(6))+cos(q(4))*cos(q(5))*sin(q(1))*sin(q(3))*sin(q(6))+cos(q(1))*cos(q(2))*cos(q(3))*cos(q(6))*sin(q(4))-cos(q(1))*cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(6));
    Ja(5,1)   =  0;
    Ja(5,2)   = -cos(q(1));
    Ja(5,3)   = -sin(q(1))*sin(q(2));
    Ja(5,4)   =  cos(q(1))*cos(q(3))-cos(q(2))*sin(q(1))*sin(q(3));
    Ja(5,5)   =  cos(q(1))*sin(q(3))*sin(q(4))-cos(q(4))*sin(q(1))*sin(q(2))+cos(q(2))*cos(q(3))*sin(q(1))*sin(q(4));
    Ja(5,6)   =  cos(q(2))*cos(q(5))*sin(q(1))*sin(q(3))-cos(q(1))*cos(q(3))*cos(q(5))+cos(q(1))*cos(q(4))*sin(q(3))*sin(q(5))+sin(q(1))*sin(q(2))*sin(q(4))*sin(q(5))+cos(q(2))*cos(q(3))*cos(q(4))*sin(q(1))*sin(q(5));
    Ja(5,7)   =  cos(q(1))*cos(q(6))*sin(q(3))*sin(q(4))-cos(q(4))*cos(q(6))*sin(q(1))*sin(q(2))-cos(q(1))*cos(q(3))*sin(q(5))*sin(q(6))+cos(q(2))*sin(q(1))*sin(q(3))*sin(q(5))*sin(q(6))-cos(q(5))*sin(q(1))*sin(q(2))*sin(q(4))*sin(q(6))+cos(q(2))*cos(q(3))*cos(q(6))*sin(q(1))*sin(q(4))-cos(q(1))*cos(q(4))*cos(q(5))*sin(q(3))*sin(q(6))-cos(q(2))*cos(q(3))*cos(q(4))*cos(q(5))*sin(q(1))*sin(q(6));
    Ja(6,1)   =  1;
    Ja(6,2)   =  0;
    Ja(6,3)   =  cos(q(2));
    Ja(6,4)   = -sin(q(2))*sin(q(3));
    Ja(6,5)   =  cos(q(2))*cos(q(4))+cos(q(3))*sin(q(2))*sin(q(4));
    Ja(6,6)   =  cos(q(5))*sin(q(2))*sin(q(3))-cos(q(2))*sin(q(4))*sin(q(5))+cos(q(3))*cos(q(4))*sin(q(2))*sin(q(5));
    Ja(6,7)   =  cos(q(2))*cos(q(4))*cos(q(6))+cos(q(3))*cos(q(6))*sin(q(2))*sin(q(4))+cos(q(2))*cos(q(5))*sin(q(4))*sin(q(6))+sin(q(2))*sin(q(3))*sin(q(5))*sin(q(6))-cos(q(3))*cos(q(4))*cos(q(5))*sin(q(2))*sin(q(6));
    
    
    
%     for i=1:7
%         i
%         Ja_dot = Ja_dot + diff(Ja,q(i))*dq(i);
%     end
    
    Ja_dot = diff(Ja,q(1))*dq(1) + diff(Ja,q(2))*dq(2) + diff(Ja,q(3))*dq(3) + diff(Ja,q(4))*dq(4) + diff(Ja,q(5))*dq(5) + diff(Ja,q(6))*dq(6) + diff(Ja,q(7))*dq(7);
    
    Ja_dot = simplify(Ja_dot);


