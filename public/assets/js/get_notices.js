$(document)
    .ready(function() {
      $("#new_notices").tablesorter();
      $("#sorted_notices").tablesorter();
    });

/*
    For moving notices between two tables.
    Update_notice class is attached to
    every notice. If a given notices sort button is pressed, jquery checks if a
    notice has sort_notice class or unsort_notice class.
    If a notice table row has sort_notice class, it means it is in a new
        notices
    table and clicking sort button will move it to sorted notices table. Same
    happens with sorted notices.
*/
$(document)
    .on('click', '.update_notice', function() {
      if ($(this).hasClass("sort_notice")) {
        var tr = $(this).closest('tr');
        var dropdown = tr.find('td:nth-child(4)');
        var selected_text = dropdown.find('select option:selected').text();
        if (selected_text != "Select") {
          var value = tr.find('td:last-child button').attr('value');
          $.ajax({type : "GET", url : value + "/" + selected_text});
          dropdown.replaceWith(
              '<td class=" tag text-center"><div class="tag-box">' +
              selected_text + '</div></td>');
          tr.detach();
          $(this).removeClass('sort_notice').addClass('unsort_notice');
          $('#sorted_notices > tbody:last-child').prepend(tr);
        }
      } else if ($(this).hasClass("unsort_notice")) {
        var tr = $(this).closest('tr');
        var tagLine = tr.find('td:nth-child(4)');
        tagLine.replaceWith('<td class="text-right"> ' +
                            '<select class="form-control"> ' +
                            '<option value="Select">Select</option> ' +
                            '<option value="Hookah">Hookah</option> ' +
                            '<option value="Eating out">Eating out</option> ' +
                            '<option value="Gas">Gas</option> ' +
                            '<option value="Taxes">Taxes</option> ' +
                            '<option value="Food">Food</option> ' +
                            '<option value="Car">Car</option> ' +
                            '<option value="Swimming">Swimming</option> ' +
                            '<option value="Alcohol">Alcohol</option> ' +
                            '<option value="One time">One time</option> ' +
                            '<option value="Other">Other</option> ' +
                            '</select></td>');
        var href = tr.find('td:last-child button').attr('value');
        $.ajax({type : "GET", url : href});
        tr.detach();
        $(this).removeClass('unsort_notice').addClass('sort_notice');
        $('#new_notices > tbody:last-child').prepend(tr);
      }
      // Tell tablesorter that the tables have been updated
      $("#new_notices").trigger("update");
      $("#sorted_notices").trigger("update");
    });

var monthNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

(function poll() {
  setTimeout(function() {
    $.ajax({
      url : '/notice/updated',
      type : 'GET',
      dataType : 'json',
      success : function(data) {
        if (parseInt(data) > 0) {
          $.ajax({
            url : '/notice/getnew/' + data,
            type : 'GET',
            dataType : 'json',
            success : function(data) {
              $.each(data, function(k) {
                var date_recieved =
                    new Date(parseInt(data[k].epoch_time) * 1000);
                var day = date_recieved.getDate().toString().length == 1
                              ? "0" + date_recieved.toString().getDate()
                              : date_recieved.getDate();
                var month = monthNames[date_recieved.getMonth()];
                var year = date_recieved.getFullYear();
                var hour = date_recieved.getHours().toString().length == 1
                               ? "0" + date_recieved.getHours().toString()
                               : date_recieved.getHours();
                var minutes = date_recieved.getMinutes().toString().length == 1
                                  ? "0" + date_recieved.getMinutes().toString()
                                  : date_recieved.getMinutes();

                var income = data[k].income;
                var sign = (income) ? '+' : '-';

                $('#new_notices > tbody:last-child')
                    .prepend(
                        '<tr><td>' + sign + data[k].amount + ' </td><td>' +
                        data[k].from_name + '</td><td class="text-right">' +
                        day + " " + month + " " + hour + ":" + minutes +
                        '</td>' +
                        '<td class="text-right"> ' +
                        '<select class="form-control"> ' +
                        '<option value="Select">Select</option> ' +
                        '<option value="Hookah">Hookah</option> ' +
                        '<option value="Eating out">Eating out</option> ' +
                        '<option value="Gas">Gas</option> ' +
                        '<option value="Taxes">Taxes</option> ' +
                        '<option value="Food">Food</option> ' +
                        '<option value="Car">Car</option> ' +
                        '<option value="Swimming">Swimming</option> ' +
                        '<option value="Alcohol">Alcohol</option> ' +
                        '<option value="One time">One time</option> ' +
                        '<option value="Other">Other</option> ' +
                        '</select></td>' +
                        '<td class="text-right">' +
                        '<button class="update_notice sort_notice" value="notice/"' +
                        data[k].id + '/edit">X</button>' +
                        '</td></tr>');
                $("#new_notices").trigger("update");
              });
            },
          });
        }
      },
      complete : poll
    });
  }, 3000);
})();
