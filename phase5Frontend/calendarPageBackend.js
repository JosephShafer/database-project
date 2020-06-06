var express = require('express');
//var app = express();
var router = express.Router();
const client = require('./db');
module.exports = router;

router.get('/getDateCurrent', function (req, res) {
  client.query(
    `SELECT to_char(CURRENT_DATE, 'DD') as currentday, to_char(CURRENT_DATE, 'Mon') as currentmonth,
           to_char(CURRENT_DATE + 7, 'DD') as futureday, to_char(CURRENT_DATE + 7, 'Mon') as futuremonth,
            to_char(CURRENT_DATE, 'YYYY') as currentyear`,
    (err, QueryRes) => {
      if (err) {
        console.log(err.stack);
        res.send('getDateCurrent get Error');
      } else {
        //console.table('getDateCurrent get Success');
        res.send(JSON.stringify(QueryRes.rows[0]));
      }
    }
  );
});

router.post('/employeeShiftsPost', function (req, res) {
  // Possibly SQL Function?


  client.query(
    `
          SELECT employee_name
          FROM view_manager_scheduling
          WHERE shift_start between $1 AND $2
  
          `,
    [req.body.start_date, req.body.end_date],
    (err, QueryRes) => {
      if (err) {
        console.log(err.stack);
        res.send('Shift Post Error');
      } else {
        console.table('Shift Post Success');
        //console.table(QueryRes.rows);
        res.send(JSON.stringify(QueryRes.rows));
      }
    }
  );
});

router.post('/allEmployeesThisMonth', function (req, res) {
  console.log(req.body);
  client.query(
    `
      SELECT employee_id, employee_name, day, shift_start, shift_end
      FROM view_manager_scheduling
      WHERE EXTRACT(MONTH from day::DATE) = EXTRACT(MONTH from $1::DATE)
      ORDER BY shift_start
      `,
    [req.body.thismonth],
    (err, QueryRes) => {
      if (err) {
        console.log(err.stack);
        res.send('allEmployeesThisMonth Post Error');
      } else {
        console.table('Shift Post Success');
        console.table(QueryRes.rows);
        res.send(JSON.stringify(QueryRes.rows));
      }
    }
  );
});

router.get('/getactiveemployees', function (req, res) {
  let jobTitleFilter = 'any()'; // default option
  console.log('Get active Employees')
  client.query(
    `
      SELECT employee.employee_id, job_title, employee.fname || ' ' || employee.lname as employee_name
      FROM employee
      INNER JOIN work_history ON employee.employee_id = work_history.employee_id
      WHERE work_history.end_date IS NULL
      ORDER BY job_title, employee_name
      `, (err, queryRes) => {
    if (err) {
      console.log(err.stack)
      res.end()
    } else {
      console.table(queryRes.rows);
      res.send(JSON.stringify(queryRes.rows))
    }
  }
  )
});

router.post('/addEmployeesToShift', (req, res) => {
  let emp_id = req.body.id;
  let shift_day = req.body.day;
  let shift_start = req.body.start;
  let shift_end = req.body.end;
  console.log(emp_id, shift_day, shift_start, shift_end);

  // todo make function
  client.query(
    `
      INSERT INTO work_shift (employee_id, shift_date, begin_time, end_time)
      VALUES ($1, $2, $3, $4)
      `,
    [emp_id, shift_day, shift_start, shift_end],
    (err, queryRes) => {
      if (err) {
        console.log(err.stack)
        res.end()
      } else {
        console.table(queryRes.rows);
        console.log('success insert employee schedule')
        res.send('insert Employee Success!');
      }
    }
  );
});


router.post('/getEmployeeForDay', (req, res) => {
  let shift_day = req.body.day;
  console.log(shift_day);
  client.query(`
    SELECT employee_id, employee_name, to_char(shift_start, 'FMHH:MI AM') shift_start, to_char(shift_end, 'FMHH:MI AM') shift_end
    from view_manager_scheduling
    WHERE day = $1
    ORDER BY job_title
`, [shift_day], (err, queryRes) => {
    if (err) {
      console.log(err.stack)
      res.end()
    } else {
      console.table(queryRes.rows);
      res.send(queryRes.rows);
    }
  }
  )
})

router.post('/getCalendarBlock', (req, res) => {

  let thisDay = req.body.sentDay;
  let dateDiff = req.body.timeDiff;
  console.log('This day is here')
 
  client.query(`
  select to_char(cast(date_trunc('week', $1::date) as date) + i, 'DD') weekDay
  from generate_series(0 +$2 ,6 + $2) i
  `, [thisDay, dateDiff], (err, queryRes) => {
    if (err) {
      console.log(err.stack)
      res.end()
    } else {
      console.table(queryRes.rows);
      res.send(queryRes.rows);
    }
  })
})


router.post('/generateScheduleForWeek', (req, res) => {
  client.query(`CALL fill_work_shift($1)`, [req.body.dayToSend],
  (err, queryRes) => {
    if (err) {
      console.log(err.stack)
      res.end()
    } else {
      console.table('Generate Success');
      res.end()
    }
  })
   
})







// client.query(
//   `
//     SELECT employee_name, day, shift_start, shift_end
//     FROM view_manager_scheduling

//     `, (err, queryRes) => {
//   if (err) {
//     console.log(err.stack)
//     //res.end()
//   } else {
//     console.log('success insert employee schedule')
//     console.table(queryRes.rows);
//     //res.send('insert Employee Success!');
//   }
// }
// )


// client.query(
//    schedule_manager_view,
//     (err, QueryRes) => {
//         if (err) {
//             console.log(err.stack);

//         } else {
//             console.table(QueryRes.rows)

//         }
//     }
// )



