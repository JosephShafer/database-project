
//  function getFullMonthEmployees(month) {
//     // make work for not 2020 also
//     let dateParse = '2020-' + (new Date().getMonth(month) + 1).toString() + '-01';
//     console.log(dateParse);
//     $.post('allEmployeesThisMonth', { thismonth: dateParse }, function (queryRes) {
//         queryRes = JSON.parse(queryRes);
//         console.log(queryRes)

//         return JSON.stringify(queryRes);
//     })
// }






function retrieveDate() {
    $.get('getDateCurrent', function (DateQueryResult) {
        dateQuery = JSON.parse(DateQueryResult)
        $("#dateSelectorMonth-Start").html(`${dateQuery['currentmonth']}`)
        $("#dateSelectorDay-Start").html(`${dateQuery['currentday']}`)
        $("#dateSelectorMonth-End").html(`${dateQuery['futuremonth']}`)
        $("#dateSelectorDay-End").html(`${dateQuery['futureday']}`)
        $("#currentYear").html(`${dateQuery['currentyear']}`);
        retrieveEmployees();

    })
}




function retrieveEmployees() {
    // NOT ACCOUNTING FOR FUTURE YEAR WARNING TODO FIX prob fix on backend
    var date = new Date();
    console.log(date.getMonth('May'))
    let queryJSON = { start_date: "", end_date: "" }
    //queryJSON.start_date = $('#currentYear').html() + '-' + (date.getMonth($("#dateSelectorMonth-Start").html()) + 1) + '-' + $("#dateSelectorDay-Start").html()
    //queryJSON.end_date = $('#currentYear').html() + '-' + (date.getMonth($("#dateSelectorMonth-End").html()) + 1) + '-' + $("#dateSelectorDay-End").html()

    queryJSON.start_date = '2020-5-05'
    queryJSON.end_date = '2020-5-20'

    console.log(queryJSON);

    $.post('employeeShiftsPost', queryJSON, function (Query) {
        EmpQueryRes = JSON.parse(Query)
        console.log(EmpQueryRes);
        for (row in EmpQueryRes) {
            $('.scheduled-employees').append(`
                    <p>${EmpQueryRes[row].employee_name}</p>
                    `);
        }

    })
}

