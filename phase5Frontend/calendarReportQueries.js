var express = require('express');
//var app = express();
var router = express.Router();
const client = require('./db');
module.exports = router;



router.get('/getschedule', (req, res) => {
    client.query(`
SELECT to_char(day, 'YYYY-MM-DD') as day, job_title, employee_name, to_char(shift_start, 'FMHH:MI AM') shift_start, to_char(shift_end, 'FMHH:MI AM')
shift_end 
FROM view_manager_scheduling
WHERE to_char(day, 'YYYY')::integer = 2020
Order BY day, shift_start desc
`,
        (err, queryRes) => {
            if (err) {
                console.log(err.stack)
                res.end()
            } else {
                console.table(queryRes.rows)
                res.send(JSON.stringify(queryRes.rows))
            }
        }
    )
})

router.post('/getSchedulebyWeek', (req, res) =>{

    date = req.body.dateSent

    client.query(`
    SELECT to_char(day, 'Day') as dayOfWeek, to_char(day, 'MM-DD-YYYY') as day, job_title, employee_name, to_char(shift_start, 'FMHH:MI AM') shift_start, to_char(shift_end, 'FMHH:MI AM')
    shift_end 
    FROM view_manager_scheduling
    WHERE to_char(day, 'IYYY-IW') = to_char($1::date, 'IYYY-IW')
    Order BY day::date, shift_start desc
    `,[date],
            (err, queryRes) => {
                if (err) {
                    console.log(err.stack)
                    res.end()
                } else {
                    console.table(queryRes.rows)
                    res.send(JSON.stringify(queryRes.rows))
                }
            }
        )
})
