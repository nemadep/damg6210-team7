BEGIN
    dbms_scheduler.create_job(job_name => 'cron_schedule_shifts', job_type => 'PLSQL_BLOCK', job_action => 'BEGIN insertdormmanagementdata.shiftscheduler(sysdate + 7); END;',
    start_date => current_timestamp, repeat_interval => 'FREQ=MINUTELY;');
END;
/

BEGIN
    dbms_scheduler.enable(name => 'CRON_SCHEDULE_SHIFTS');
END;
/


BEGIN
    dbms_scheduler.disable(name => 'CRON_SCHEDULE_SHIFTS');
END;
/

BEGIN
    dbms_scheduler.drop_job(job_name => 'CRON_SCHEDULE_SHIFTS');
END;
/

SELECT
    run_count
FROM
    all_scheduler_jobs
WHERE 
job_name = 'CRON_SCHEDULE_SHIFTS';

SELECT
    current_timestamp
FROM
    dual;

SELECT
    *
FROM
    admin.shifts;