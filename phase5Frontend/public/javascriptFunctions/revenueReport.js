$(function () {
    $('#cmd-revenue').click(
        function () {
            let dateObj = new Date()
            $('#report-date').html(dateObj.toDateString())

            fetch('getRevenue')
                .then((response) => response.json())
                .then((response) => {
                    $('#revenue-items').html(`<div class="row justify-content-around">
                    <div class="col">
                        <h3 class="text-center">Customer Name</h3>
                    </div>
                    <div class="col">
                        <h3 class="text-center">Total Purchase Amount</h3>
                    </div>
                    <div class="col">
                        <h3 class="text-center">Most Recent Purchase</h3>
                    </div>

                </div>`)
                    for (row in response) {
                        $('#revenue-items').append(
                            `
                        <div class="row justify-content-between">
                            <div class="col">
                                <h4 class="text-center">${response[row].customer_name}</h4>
                            </div>
                            <div class="col">
                                <h4 class="text-center">$${response[row].revenue}</h4>
                            </div>
                            <div class="col">
                                <h4 class="text-center">${response[row].last_bought}</h4>
                            </div>
                        </div
                        `)
                    }

                }).then((res) => {

                    return fetch('getExpenses')
                        .then((response) => response.json())
                        .then((response) => {
                            $('#expense-items').html(`<div class="row justify-content-around">
                            <div class="col">
                                <h3 class="text-center">Supplier Name</h3>
                            </div>
                            <div class="col">
                                <h3 class="text-center">Total Paid To Supplier</h3>
                            </div>
                            <div class="col">
                                <h3 class="text-center">Most Recent Supply Order</h3>
                            </div>
            
                        </div>`)
                            for (row in response) {
                                $('#expense-items').append(`
                        <div class="row justify-content-between">
                            <div class="col">
                                <h4 class="text-center">${response[row].vendor_name}</h4>
                                </div>
                                <div class="col">
                                <h4 class="text-center">$${response[row].expenditure}</h4>
                                </div>
                                <div class="col">
                                <h4 class="text-center">${response[row].last_paid_to}</h4>
                                </div>
                        </div
`)
                            }
                        
                        })
                })
                
                .then((res) => {




                   return fetch('getTotalRevenue')
                        .then((response) => response.json())
                        .then((response) => {
                            console.log(response.total_revenue)
                            $('#total-revenue-element').html(`$${response.total_revenue}`)
                        })
                }).then((res) => {



                   return fetch('getTotalExpenses')
                        .then((response) => response.json())
                        .then((response) => {
                            $('#total-expenses-element').html(`$${response.total_expenses}`)
                        })
                }).then((res) => {
                    return fetch('getProfit')
                        .then((response) => response.json())
                        .then((response) => {
                            $('#profit-element').html(`$${response.total}`)
                        })
                })

.then(() =>{
    html2canvas(document.querySelector("#revenue-content"),
        {
            removeContainer: false, onclone: function (doc) {
                div = $(doc).find('#revenue-content');
                div.css('opacity', '1.0');
            }
        }).then(canvas => {
            document.body.appendChild(canvas);
            console.log(canvas);
            var imagedata = canvas.toDataURL('image/png');
            var doc = new jsPDF('p', 'pt', 'a4');

            var width = doc.internal.pageSize.getWidth();
            var height = doc.internal.pageSize.getHeight();

            doc.addImage(imagedata, 'JPEG', 0, 0, width, height);

            doc.save('revenue.pdf');
            console.log(imagedata);
        });

})
    
})
})
