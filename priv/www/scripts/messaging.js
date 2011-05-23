var message_id = 0;
var messages_waiting = {};

function run_get_message_loop() {
    var success = function(data) {
        $.each(data.messages, function(index, value){
            callback = messages_waiting[value.msgId];
            $.each(value.messages, function(index, msg){
                callback(msg);
            });
        });
		run_get_message_loop();
	};
    var error = function(error1, error2) {
        alert("Error: " + error1 + " " + error2);
        run_get_message_loop();
    };
	get_messages(success, error);
}

function get_messages(success_function, error_function) {
	$.ajax({
		url: 'getmessages', 
		type: 'POST',
		data: 	'{"clientId":"client1"}',
		contentType: 'application/json',
		//dataType: 'json',
		success: success_function,
        error: error_function
	});
}

function send_search_message(search_string, callback) {
	var jsonString = '{"search": "' + search_string + '"}';
	return send_message(jsonString, callback);
}

function send_message(jsonString, callback) {
	my_message_id = message_id++;
    $.ajax({
		url: 'messages', 
		type: 'POST',
		data: 	'{'+ 
			'"clientId":"client1",'+
			'"startMessageId": ' + my_message_id + ','+
			'"messages": [' + jsonString + ']'+
			'}',
		contentType: 'application/json',
		dataType: 'json'
	});
    messages_waiting[my_message_id] = callback;
    return my_message_id;
}