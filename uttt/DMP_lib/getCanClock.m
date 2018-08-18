function canClockPtr = getCanClock(CAN_CLOCK_TYPE, tau)

%% ========================================================
%% Init canonical clock
if (strcmpi(CAN_CLOCK_TYPE,'lin'))
    canClockPtr = LinCanonicalClock();
else
    error('Unsupported canonical clock type ''%s''', CAN_CLOCK_TYPE);
end
canClockPtr.init(tau);

end

