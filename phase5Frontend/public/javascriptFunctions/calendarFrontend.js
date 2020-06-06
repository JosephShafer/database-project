function createCalendar() {
  const firstDayInMonthIndex = (
    monthIndex = new Date().getMonth(),
    year = new Date().getFullYear()
  ) => new Date(`${year}-${monthIndex + 1}-01`).getDay();

  const lastDayInMonthIndex = (
    monthIndex = new Date().getMonth(),
    year = new Date().getFullYear()
  ) => new Date(year, monthIndex + 1, 0).getDay();

  let firstDay = firstDayInMonthIndex();
  let lastDay = lastDayInMonthIndex();
  console.log(lastDay);
  let firstRowFilled = false;
  let day = 1;
  for (let row = 0; row < 6; row++) {
    let htmlTemplate = ``;
    htmlTemplate += `<div class="row">`;
    for (let dayBlock = 0; dayBlock < 7; dayBlock++) {
      if (firstRowFilled) {
          
        htmlTemplate += `
      <div id=day-${day} class="col card calendar-box-issue" data-toggle="modal" data-target="#exampleModalCenter">${day}
        <a class="card-block stretched-link">
          <div id=${day}-emp-list>
          </div>
        </a>
      </div>`;
        day++;
      } else {
        htmlTemplate += `<div class="col card"></div>`;
        if (dayBlock == firstDay) {
          firstRowFilled = true;
        }
      }
    }
    htmlTemplate += `</div>`;
    $('.calendar-manager').append(htmlTemplate);
  }
}

function fillEmployeeNameModal() {
  fetch('getactiveemployees')
    .then((response) => response.json())
    .then((response) => {
      for (row in response) {
        //console.log(response[row].employee_name)
        $('#employee-list').append(
          `<option value="${response[row].employee_id}">${response[row].employee_name} - ${response[row].job_title}</option>`
        );
      }
    })
    .catch((err) => console.log(err));
}

function fillCalendar() {
  fetch('getDateCurrent')
    .then((response) => response.json())
    .then((response) => {
      $('#month-text').html(response.currentmonth);
      return response;
    })
    .then((response) => {
      //console.log(response.currentmonth);
      let dateParse =
        '2020-' +
        (new Date().getMonth(response.currentmonth) + 1).toString() +
        '-01';
      return fetch('allEmployeesThisMonth', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ thismonth: dateParse }),
      });
    })
    .then((response) => response.json())
    .then((queryRes) => {
      console.log(queryRes)
      for (let shift in queryRes) {
        let day = new Date(queryRes[shift].day).getDate();
        console.log($(`#${day}-emp-list p`));
        $(`#day-${day}`).removeClass('calendar-box-issue');
        $(`#day-${day}`).addClass('calendar-box-ok');
        if($(`#${day}-emp-list #cal-emp-id-${queryRes[shift].employee_id}`).length < 1){
          $(`#${day}-emp-list`).append(`<p id=cal-emp-id-${queryRes[shift].employee_id}>${queryRes[shift].employee_name}</p>`);
        }
      }
    })
    .catch((err) => console.log(err));
}





// function makeManySliders() {
//   var sliders = document.getElementsByClassName('sliders');

//   for (var i = 0; i < sliders.length; i++) {
//     // noUiSlider.create(sliders[i], {
//     //   start: 50,
//     //   step: 5,
//     //   connect: 'lower',
//     //   orientation: 'horizontal',
//     //   range: {
//     //     min: 0,
//     //     max: 100,
//     //   },
//     // });

//     // sliders[i].noUiSlider.on('slide', addValues);
//   }

//   function addValues() {
//     var allValues = [];

//     for (var i = 0; i < sliders.length; i++) {
//       console.log(allValues.push(sliders[i].noUiSlider.get()));
//     }

//     console.log(allValues);
//   }
// }

// function createEmployeeSlider() {
//   // need an id
//   // need a way to submit

//   var slider = document.getElementById('slider');

//   noUiSlider.create(slider, {
//     start: [8, 12],
//     connect: true,
//     range: {
//       min: [8, 0.5],
//       max: [18],
//     },
//     format: {
//       to: function (num) {
//         pmOrAm = ' am';
//         if (num >= 12) {
//           pmOrAm = ' pm';
//         }
//         if (num >= 13) {
//           num = num - 12;
//         }
//         var hours = Math.floor(num);
//         var minutes = num;

//         if (hours - minutes < 0) {
//           return hours + ':30' + pmOrAm;
//         } else {
//           return hours + ':00' + pmOrAm;
//         }
//       },
//       // 'from' the formatted value.
//       // Receives a string, should return a number.
//       from: function (value) {
//         return Number(value.replace(',-', ''));
//       },
//     },
//   });

//   var nodes = [
//     document.getElementById('lower-value'), // 0
//     document.getElementById('upper-value'), // 1
//   ];

//   slider.noUiSlider.on('update', function (
//     values,
//     handle,
//     unencoded,
//     isTap,
//     positions
//   ) {
//     nodes[handle].innerHTML = values[handle];
//   });
// }
