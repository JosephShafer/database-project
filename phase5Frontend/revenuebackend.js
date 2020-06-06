var express = require('express');
//var app = express();
var router = express.Router();
const client = require('./db');



router.get('/getRevenue', (req, res) => {
    client.query(`select * from view_positive_revenue LIMIT 12`,
        (err, queryRes) => {
            if (err) {
                console.log(err.stack)
                res.end()
            } else {
                console.table(queryRes.rows);
                res.send(JSON.stringify(queryRes.rows))
            }
        }
    )
})

router.get('/generatePayments', (req, res) => {
    client.query(`CALL fillIncomingPaymentsRandomly();
                  CALL fillOutgoingPaymentsRandomly();
    `,(err, queryRes) => {
        if (err) {
            console.log(err.stack)
            res.end()
        } else {
            console.table('success');
            res.end()
        }
    })
    
})

router.get('/getTotalRevenue', (req, res) => {
    client.query(`SELECT SUM(revenue) as total_revenue FROM view_positive_revenue`,
        (err,queryRes) => {
            if (err){
                console.log(err.stack)
                res.end()
            } else {
               // console.table(queryRes)
                res.send(JSON.stringify(queryRes.rows[0]))
            }
        }
    )
})

router.get('/getExpenses', (req, res) => {

    client.query(`SELECT * FROM view_expenditure`,
        (err, queryRes) => {
            if (err) {
                console.log(err.stack)
                res.end()
            } else {
                // console.table(queryRes.rows);
                res.send(JSON.stringify(queryRes.rows))
            }
        }
    )
})

router.get('/getTotalExpenses', (req, res) =>{
    client.query(` select SUM(expenditure) as total_expenses
    FROM view_expenditure `,
        (err, queryRes) =>{
            if (err) {
                console.log(err.stack)
                res.end()
            } else {
                // console.table(queryRes.rows);
                res.send(JSON.stringify(queryRes.rows[0]))
            }
        }
    )
})

router.get('/getProfit', (req, res) => {
    client.query(`
    SELECT SUM(revenue) - (
        select SUM(expenditure)
        FROM view_expenditure
    ) AS total
    FROM view_positive_revenue
    ;
    
    `, (err, queryRes) => {
        if (err) {
            console.log(err.stack)
            res.end()
        } else {
            // console.table(queryRes.rows);
            res.send(JSON.stringify(queryRes.rows[0]))
        }
    }

    )
})


module.exports = router;

