
$(document).ready(function(){
   setup_non_map_stuff();
});

function setup_non_map_stuff() {
	setup_searchbox();
	run_get_message_loop();
}

var latest_search_message_id;
function setup_searchbox() {
	$('#search_field').focus();
	$('#search_field').bind('keypress', function(e) {
		if(e.keyCode==13){
			search_result_element = $('#search-results');
			message_id = send_search_message($('#search_field').val(), function(msg) {
				if (message_id == latest_search_message_id) {
					var onclick = function() {
						goto(msg.boundingbox);
					};
					var a = $("<a></a>").append(msg.name + " - " + msg.source).attr('href','#').click(onclick);
					var li = $("<li></li>").append(a);
					search_result_element.append(li);
				}
			});
			latest_search_message_id = message_id;
			search_result_element.empty();
		}
	});
}