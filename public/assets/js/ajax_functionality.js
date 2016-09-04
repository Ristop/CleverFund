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



function updateTable() {
    $.ajax({
        url: '/notice/isScanning',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            if (data == 'False') {
                $.ajax({
                    url: '/notice/updated',
                    type: 'GET',
                    dataType: 'json',
                    success: function(data) {
                        if (parseInt(data) > 0) {
                            $.ajax({
                                url: '/notice/getnew/' + data,
                                type: 'GET',
                                dataType: 'json',
                                success: function(data) {
                                    $.each(data, function(k) {
                                        $.ajax({
                                            url: '/tag/all',
                                            type: 'GET',
                                            dataType: 'json',
                                            success: function(tag_data) {
                                                $('#new_notices > tbody:last-child')
                                                    .prepend(consturctNewNoticeTableRow(data[k], tag_data));
                                                $("#new_notices").trigger("update");
                                            },
                                        });

                                    });
                                },
                            });
                        }
                    },
                });
            } else {
                setTimeout(updateTable, 1000);
            }
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            alert("Status: " + textStatus);
            alert("Error: " + errorThrown);
        }
    });
}



/**
 * Construct new dropdown liss based on tags_data
 * @param {Notice} tags_data
 */
function getTagsDropdownList(data, income) {
    var dropdownList = '<td class="text-right"> ' +
        '<select class="form-control form-tags"> ';
    if (income) {
        dropdownList += '<option value="Income">Income</option>';
    } else {
        dropdownList += '<option value="Select">Select</option> ';
        $.each(data, function(k) {
            dropdownList +=
                '<option value="' + data[k].name + '">' + data[k].name + '</option> ';

        });
    }
    dropdownList += '</select></td>';
    return dropdownList;
}

Date.prototype.YYYYMMDDhhmmss = function() {
    var YYYY = this.getFullYear().toString(),
        MM = (this.getMonth()+1).toString(),
        DD  = this.getDate().toString(),
        hh = this.getUTCHours().toString(),
        mm = this.getUTCMinutes().toString(),
        ss = this.getUTCSeconds().toString();
    return YYYY + "-" + (MM[1]?MM:"0"+MM[0]) + "-" + (DD[1]?DD:"0"+DD[0]) + " " + (hh[1]?hh:"0"+hh[0]) + ":" + (mm[1]?mm:"0"+mm[0]) + ":" + (ss[1]?ss:"0"+ss[0]);
};

/**
 * Construct new table entry for new notice table based on Notice object data
 * and tags_data.
 * @param {Notice} data
 * @param {Tag[]} tags_data
 */
function consturctNewNoticeTableRow(data, tags_data) {
    var income = data.income;
    var sign = (income) ? '+' : '-';
    var dropdownList = getTagsDropdownList(tags_data, income);
    var date_recieved = new Date(parseInt(data.epoch_time) * 1000).YYYYMMDDhhmmss();
    var number_format_class = (income) ? "increased-amount-new" : "decreased-amount-new";

    var tableRowHTML =
        '<tr><td class="'+number_format_class+'">' + sign + data.amount + ' </td><td>' + data.from_name +
        '</td><td class="text-right">' + date_recieved + '</td>' + dropdownList + '<td class="text-right">' +
        '<button class="update_notice sort_notice" value="notice/"' + data.id +
        '/edit">X</button>' +
        '</td></tr>';

    return tableRowHTML;
}

/**
 * Initialize tablesorter on both tables.
 * Change tag container colort and text when hovering containter
 */
$(document)
    .ready(function() {
        $("#new_notices").tablesorter(
          {
            dateFormat : 'ddmmyyyy'
          }
        ); // Initialize tablesorter on new notices
        $("#sorted_notices")
            .tablesorter(); // Initialize tablesorter on sorted notices
        $('.scan-btn').click(function(){
          setTimeout(updateTable, 1000)
        });

        var tag;
        var tag_width;

        // Tag container color change when hovering
        $('.tag-container')
            .hover(
                function() {
                    tag = $(this).find('span').text(); // Get tag name
                    tag_width = $(this).width(); // Get container width
                    $(this).find('span').text('x'); // Set container text to 'x'
                    $(this).width(tag_width); // Keep orignal width
                },
                function() {
                    $(this).find('span').text(tag); // Set container text to tag
                });
    });

/**
 * listens to click on a tag and deletes a tag that was clicked
 */
$(document)
    .on('click', '.tag-container', function() {
        var tag_id = $(this).find("input").val(); // Get tag id
        $.ajax({
            type: "DELETE",
            url: "/tag/" + tag_id
        }); // Delete tag
        $(this).fadeOut(); // Remove from view
    });

/**
 * For moving notices between two tables. Update_notice class is attached to
 * every notice. If a given notices sort button is pressed, jquery checks if a
 * notice has sort_notice class or unsort_notice class. If a notice table row
 * has
 * sort_notice class, it means it is in a new notices table and clicking sort
 * button will move it to sorted notices table. Same happens with sorted
 * notices.
 */
$(document)
    .on('click', '.update_notice', function() {
        if ($(this).hasClass("sort_notice")) { // Move new notice to sorted

            var tr = $(this).closest('tr');
            var dropdown = tr.find('td:nth-child(4)');
            var selected_text = dropdown.find('select option:selected').text();

            if (selected_text != "Select") { // Only move when tag is selected
                var value = tr.find('td:last-child button').attr('value');
                $.ajax({
                    // Call to controller to update Notice model object
                    type: "GET",
                    url: value + "/" + selected_text
                });
                dropdown.replaceWith(
                    '<td class="tag text-right"><div class="tag-box">' +
                    selected_text + '</div></td>');
                tr.detach();
                $(this).removeClass('sort_notice').addClass('unsort_notice');
                $('#sorted_notices > tbody:last-child').prepend(tr);
            }
        } else if ($(this)
            .hasClass("unsort_notice")) { // Move sorted notice to new

            var tr = $(this).closest('tr');
            var tagLine = tr.find('td:nth-child(4)');

            tagLine.find(".tag-box").hide();
            $.ajax({
                // Get all tag values and consturct dropdown list
                url: '/tag/all',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    var dropdownList = getTagsDropdownList(
                        data,
                        tagLine.find(".tag-box").text().replace(/\s/g, '') == "Income" ?
                        true :
                        false);
                    tagLine.replaceWith(dropdownList);
                    tagLine.find("select").show();
                },
            });

            var href = tr.find('td:last-child button').attr('value');
            $.ajax({
                // Call to controller to update Notice model object
                type: "GET",
                url: href
            });
            tr.detach();
            $(this).removeClass('unsort_notice').addClass('sort_notice');
            $('#new_notices > tbody:last-child').prepend(tr);
        }

        // Tell tablesorter that the tables have been updated
        $("#new_notices").trigger("update");
        $("#sorted_notices").trigger("update");
    });

/**
 * Polls from notice controller, asks if any new notices have beed added. If
 * new notices have been added, fetches them and adds them to new notices table
 */
