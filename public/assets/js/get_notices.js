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
        tr.detach();
        $(this).removeClass('sort_notice').addClass('unsort_notice');
        $('#sorted_notices > tbody:last-child').prepend(tr);
      } else if ($(this).hasClass("unsort_notice")) {
        var tr = $(this).closest('tr');
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
                        '</td><td class="text-right">' +
                        "<a class=\"update_notice sort_notice\" data-remote=\"true\" data-method=\"get\" href=\"notice/" +
                        data[k].id + "/edit\">X</a>" + '</td></tr>');
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
