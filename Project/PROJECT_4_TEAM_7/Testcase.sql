--Test Shift schedule when new dorm is inserted
Create or replace procedure testShiftScheduler as
CURSOR scheduledDays is select distinct(shift_date) from shifts;
schDay date;
no_shifts exception;
BEGIN
    --Insert a new dorm into the dorm table
    insertdormmanagementdata.insertdorm('Dev A', 600, 'Boston', 'MA', '02127',
                                       'Columbus Ave', '');
                                       
    --Schedule shifts for newly inserted dorm
    open scheduledDays;
    loop
        fetch scheduledDays into schDay;
        if scheduledDays%ROWCOUNT = 0 then
            raise no_shifts;
        end if;    
        EXIT WHEN scheduledDays%NOTFOUND;
        insertdormmanagementdata.shiftscheduler(schDay);
    end loop;
    
    close scheduledDays;
    
    exception
        when no_shifts then
            dbms_output.put_line('--No shifts scheduled till now--');
    

END;

begin
testshiftscheduler;
end;
/

select count(*) from shifts;