 
function loadPublications() {
    // based on example at http://jqueryui.com/autocomplete/#remote-jsonp
    $(function() {
        function split( val ) {
            return val.split( /,\s*/ );
        }
        function extractLast( term ) {
            return split( term ).pop();
        }

        $( ".js-publications" )
        // don't navigate away from the field on tab when selecting an item
            .bind( "keydown", function( event ) {
                if ( event.keyCode === $.ui.keyCode.TAB &&
                    $( this ).autocomplete( "instance" ).menu.active ) {
                    event.preventDefault();
                }
            })
            .autocomplete({
		// when page is loaded, IF the dataset has been filled in already,
		// internal_datum_publication will have an ISSN (for a controlled value),
		// or internal_datum_publication_name will have a text value, so use one of 
		// these values to fill in the journal title
		create: function(a) {
		    if(document.getElementById("internal_datum_publication_issn").value){
			$.ajax({
                            url: "/stash_datacite/publications/issn/"+ document.getElementById("internal_datum_publication_issn").value,
                            dataType: "json",
                            success: function( data ) {
				document.getElementById("internal_datum_publication").value = ""
				if (data.fullName != null) {
				    document.getElementById("internal_datum_publication").value = data.fullName;
				}
			    }
			});
		    } else if(document.getElementById("internal_datum_publication_name").value){
			document.getElementById("internal_datum_publication").value = document.getElementById("internal_datum_publication_name").value
		    }
		},
                source: function (request, response) {
		    // save the user's typed request in the database with an asterisk, in case they don't click on an autocomplete result
		    document.getElementById("internal_datum_publication_name").value = request.term + "*";
		    var form = $(this.form);
                    $(form).trigger('submit.rails');
		    $.ajax({
			url: "/stash_datacite/publications/autocomplete",
                        dataType: "json",
			data: {
			    term: request.term
			},
                        success: function (data) {
                            var arr = jQuery.map( data, function( a ) {
                                return [[ a.issn, a.fullName ]];
                            });
                            var labels = [];
                            $.each(arr, function(index, value) {
                                if (value[0] != null) {
                                    labels.push({value: value[0], label: value[1]});
                                }
                            });
                            response(labels);
                        }
                    });
                },
                minLength: 3,
                select: function( event, ui ) {
                    new_value = ui.item.value;
                    new_label = ui.item.label;
                    document.getElementById("internal_datum_publication_issn").value = new_value;
                    document.getElementById("internal_datum_publication_name").value = new_label;
                    ui.item.value = ui.item.label;
                    var form = $(this.form);
                    $(form).trigger('submit.rails');
                    previous_value = new_value;
                    previous_label = new_label;
                },
                change: function( event, ui ) {
		    // do nothing
		},
                focus: function() {
                    // prevent value inserted on focus		    
                    return false;
                },
            });
    });

    // moving focus saves
    $( '.js-msid, .js-doi, .js-publications' ).on('focus', function () {
        previous_value = this.value;
    }).change(function() {
        new_value = this.value;
        // Save when the new value is different from the previous value
        if(new_value != previous_value) {
            var form = $(this.form);
            $(form).trigger('submit.rails');
        }
    });

    // trap the submit button, change hidden 'do_import' = 'true' and then submit when this button is clicked
    $('.js-populate-submit').click(function(e){
        e.preventDefault();
        $('#internal_datum_do_import').val('true');
        $(this).closest("form").submit();
    });

    // trigger different options for auto-filling data when clicking radio buttons
    $('.js-import-choice input[type=radio]').change(function() {
        setPublicationChoiceDisplay(this.value);
    });
};

// show and hide things for clicking by user for pretty form making
function setPublicationChoiceDisplay(chosen){
    switch(chosen) {
    case 'published':
        $(".js-ms-section").hide();
        $(".js-doi-section").show()
        $(".c-import__form-section").show();
        $(".js-other-info").hide();
        $(".js-populate-submit").val("Import Article Metadata");
        $("#choose_published").prop("checked", true);
        break;
    case 'manuscript':
        $(".js-doi-section").hide();
        $(".js-ms-section").show();
        $(".c-import__form-section").show();
        $(".js-other-info").hide();
        $(".js-populate-submit").val("Import Manuscript Metadata");
        $("#choose_manuscript").prop("checked", true);
        break;
    default:
        $(".c-import__form-section").hide();
        $(".js-other-info").show();
        $("#choose_other").prop("checked", true);
    }
}

