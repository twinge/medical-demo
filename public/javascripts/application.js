$(function() {
	$('input:checkbox:not([safari])').checkbox();
	$('input[safari]:checkbox').checkbox({cls:'jquery-safari-checkbox'});
	$('input:radio').checkbox();

	$( "#or10" ).click(function() {
		$( "#dialog" ).dialog( "open" );
		return false;
	});
	$( "#dialog-confirm" ).dialog({
		resizable: false,
		height:140,
		modal: true,
		buttons: {
			"Delete all items": function() {
				$( this ).dialog( "close" );
			},
			Cancel: function() {
				$( this ).dialog( "close" );
			}
		}
	});
	$('.disabled').click(function() {return false})
});

displayForm = function (elementId)
{
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