$(function () {
    let showManagers = true;
    let showCashiers = true;
    let showDrivers = true;
    let showFlorists = true;

    console.log(showManagers)

    $('#defaultCheck1').change(function () {
        if ($(this).is(":checked")) {

            showManagers = true;

        }

        else if ($(this).is(":not(:checked)")) {
            showManagers = false;
        }

        console.log("showManagers: " + showManagers);


    })
    $('#defaultCheck2').change(function () {
        if ($(this).is(":checked")) {

            showCashiers = true;
        }

        else if ($(this).is(":not(:checked)")) {
            showCashiers = false;
        }
        console.log("showCashiers: " + showCashiers);

    })
    $('#defaultCheck3').change(function () {
        if ($(this).is(":checked")) {

            showDrivers = true;
        }

        else if ($(this).is(":not(:checked)")) {
            showDrivers = false;
        }
        console.log("showDrivers: " + showDrivers);

    })
    $('#defaultCheck4').change(function () {
        if ($(this).is(":checked")) {

            showFlorists = true;
        }

        else if ($(this).is(":not(:checked)")) {
            showFlorists = false;
        }
        console.log("showFlorists: " + showFlorists);

    })




    $('#cmd').click(
        function () {
            let dateObj = new Date()
            $('#report-date').html(dateObj.toDateString())

            queryString = $('.chosen-day-text').html()


            fetch('getSchedulebyWeek', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ dateSent: queryString })
            })
                .then(res => res.json())
                .then(queryRes => {
                    $('#schedule-div').html('')
                    $('.week-of-calendar-report').html(queryRes[0].day);
                    console.log(showManagers, showCashiers, showDrivers, showFlorists)

                    let day = '';
                    let job_name = queryRes[0].job_title
                    for (row in queryRes) {
                        if (day != queryRes[row].day) {
                            
                            day = queryRes[row].day;

                            let stringToAppend = `
                    <h3 class="date-line">${queryRes[row].dayofweek} ${day}</h3>
                     <div class="row text-center bg-light">
                    
                    `

                            if (showManagers === true) {

                                stringToAppend +=
                                    `
            <div class="col report-manager-bg">
            <h1>
                Managers
            </h1>
            <div id=Manager-day-${day} ">
            
            </div>
        </div>
            
            `
                            }

                            if (showCashiers === true) {
                                stringToAppend += `
            <div class="col report-cashier-bg">
            <h1>
                Cashiers
            </h1>
            <div id=cashier-day-${day} ">
            
            </div>
        </div>
            `
                            }

                            if (showDrivers === true) {
                                stringToAppend += `
            <div class="col report-driver-bg">
            <h1>
                Delivery Drivers
            </h1>
            <div id=driver-day-${day}>
            
            </div>
        </div>
            `
                            }

                            if (showFlorists === true) {
                                stringToAppend += `
        <div class="col report-florist-bg">
            <h1>
                Florists
            </h1>
            <div id=florist-day-${day}>
            
            </div>
        </div>
            `

                            }

                            stringToAppend += `</div>`

                            $('#schedule-div').append(stringToAppend)
                        }


                        if (queryRes[row].job_title === 'Cashier') {
                            $(`#cashier-day-${day}`).append(`
                        
                        <p>${queryRes[row].employee_name} ${queryRes[row].shift_start} - ${queryRes[row].shift_end}</p>
                        
                            `)
                        }
                        if (queryRes[row].job_title === 'Delivery Driver') {
                            $(`#driver-day-${day}`).append(
                                `

                        <p>${queryRes[row].employee_name} ${queryRes[row].shift_start} - ${queryRes[row].shift_end}</p>
                   
                            `
                            )
                        }
                        if (queryRes[row].job_title === 'Florist') {
                            $(`#florist-day-${day}`).append(
                                `
                        <p>${queryRes[row].employee_name} ${queryRes[row].shift_start} - ${queryRes[row].shift_end}</p>
                 
                            `
                            )
                        }
                        if (queryRes[row].job_title === 'Manager') {
                            $(`#Manager-day-${day}`).append(
                                `
                        <p>${queryRes[row].employee_name} ${queryRes[row].shift_start} - ${queryRes[row].shift_end}</p>
                            
                            `
                            )
                        }

                        console.log(queryRes[row])
                    }
                }).then(() => {

                    html2canvas(document.querySelector("#content"),
                        {
                            removeContainer: false, onclone: function (doc) {
                                div = $(doc).find('#content');
                                div.css('opacity', '1.0');
                            }
                        }).then(canvas => {
                            document.body.appendChild(canvas);
                            console.log(canvas);
                            var imagedata = canvas.toDataURL('image/png');
                            var doc = new jsPDF('p', 'px', 'a4');

                            var width = doc.internal.pageSize.getWidth();
                            var height = doc.internal.pageSize.getHeight();

                            doc.addImage(imagedata, 'JPEG', 0, 0, width, height);

                            doc.save('schedule.pdf');
                            console.log(imagedata);
                        })

                })
        })
})


