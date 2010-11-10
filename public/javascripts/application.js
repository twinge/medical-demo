$(function() {
	$('#snapshot_link').click(function() {
		$('#spinner_snapshot').show();
	});
	$('.squarebutton').click(function() {
		$(this).removeClass('on');
		$(this).addClass('on');
	});
	$('#save_clip').click(function() {
		var form = $(this).closest('form');
		$('#spinner_save').show();
  	$.ajax({
       url: form.attr('action'),
       data: form.serializeArray(),
       dataType: 'script',
       type: 'PUT'
    });
		return false
	});
	$('input:checkbox:not([safari])').checkbox();
	$('input[safari]:checkbox').checkbox({cls:'jquery-safari-checkbox'});
	$('input:radio').checkbox();

	// $( "#or10" ).click(function() {
	// 	$( "#dialog" ).dialog( "open" );
	// 	return false;
	// });
	$('.disabled').click(function() {return false});
	$('body#detail #record').click(function() {
		$('#recording_form').submit();
		return false
	});
	$('#or11').click(function() {
		setMessage('Waiting for permission from OR-11 to connect');
		setTimeout(function() {
								$('.controlblock.or11').show();
								setMessage('You are now connected to OR-11');
							}, 2000)
		$('.on').removeClass('on');
		$(this).addClass('on');
		return false
	});
  // $('#screenshots').bxSlider({
  //   displaySlideQty: 8
  // });
   $('#footertab').click(function() {
     $(this).toggleClass("close");
   }); 
	
	$('.snapshot').live('hover', function() {
		$('.delete', this).show();
	}, function() {
		$('.delete', this).hide();
	});
	$("#shots").animate({"height": "toggle"}, { duration: 0 });
});

var bindAjaxAfter = function() {
	$('#snapshot .delete').bind('ajax:before', function() {
		$(this).closet('li').fadeOut();
	})
}

var showSlidingDiv = function() {
  $("#shots").animate({"height": "toggle"}, { duration: 250 });
}

var displayForm = function (elementId) {
	var content = [];
	$('#' + elementId + ' input').each(function(){
		var el = $(this);
		if ( (el.attr('type').toLowerCase() == 'radio'))
		{
			if ( this.checked )
				content.push([
					'"', el.attr('name'), '": ',
					'value="', ( this.value ), '"',
					( this.disabled ? ', disabled' : '' )
				].join(''));
		}
		else
			content.push([
				'"', el.attr('name'), '": ',
				( this.checked ? 'checked' : 'not checked' ), 
				( this.disabled ? ', disabled' : '' )
			].join(''));
	});
	alert(content.join('\n'));
}

changeStyle = function(skin)
{
	jQuery('#myform :checkbox').checkbox((skin ? {cls: skin} : {}));
}