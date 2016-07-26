function loadSubjects() {

  $('#js-keywords__container').click(function(){
    $('.js-keywords__input').focus();
  });

  $('.js-keywords__input').focus(function(){
    $('#js-keywords__container').addClass('c-keywords__container--has-focus').removeClass('c-keywords__container--has-blur');
    $('.saving_text').show();
    $('.saved_text').hide();
  });

  $('#keyword').keydown(function(event) {
    if (event.keyCode == 13 || event.keyCode == 9) {
      var self = $(this);
      var form = self.parents('form');
      $(form).trigger('submit.rails');
      $('.saved_text').show();
      $('.saving_text').hide();
      event.preventDefault();
    }
  });

  $('.js-keywords__input').blur(function(){
    $('#js-keywords__container').removeClass('c-keywords__container--has-focus').addClass('c-keywords__container--has-blur');
    $('.saved_text').show();
    $('.saving_text').hide();
  });
};