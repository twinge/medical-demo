/**
 * Message Block JavaScript Interface
 * 
 * Allows for updating a message block with JSON errors
 **/

var setMessage = function(msg, timeout, msg_type) {
	if(msg_type == null) msg_type = 'notice';
	if(timeout == null) timeout = 3000;
	var message_block = $('#message_block');
	if (message_block[0] == null) {
		message_block = $('<div id="message_block" class="message_block"></div>');
		$('body').append(message_block);
	}
	message_block.show();
	message_block.html('<ul class="' + msg_type + '"><li>' + msg + '</li></ul>');
	window.setTimeout ( function() {$('#message_block').fadeOut();}, timeout )
}