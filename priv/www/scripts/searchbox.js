var latest_search_message_id;

function setup_searchbox() {
    search_result_element = $('#search-results');
    search_result_element.append($("<li class='marker' id='lonelyplanet'/>"));
    search_result_element.append($("<li class='marker' id='google'/>"));
    search_result_element.append($("<li class='marker' id='yahoo'/>"));
    
    search_result_element.append()
    search_field = $('#search_field');
	search_field.focus();
	search_field.bind('keypress', function(e) {
		if(e.keyCode==13){
			message_id = send_search_message($('#search_field').val(), function(msg) {
				if (message_id == latest_search_message_id) {
					var onclick = function() {
						goto(msg.boundingbox);
					};
					var a = $("<a></a>").append(msg.name + " - " + msg.source).attr('href','#').click(onclick);
					var li = $("<li id='" + msg.source + "' class='result'></li>").append(a);
                    
                    last_from_source = search_result_element.children("#" + msg.source + ":last");
					last_from_source.after(li);
				}
			});
			latest_search_message_id = message_id;
            search_result_element.children("li.result").remove();
		}
	});
}