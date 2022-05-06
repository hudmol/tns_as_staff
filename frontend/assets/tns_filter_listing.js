(function() {

  function toggleListing($toggle, $ul) {
    if ($toggle.data('more')) {
      $ul.find('li:gt(10)').slideUp(() => {
        $toggle.text('Show more ' + '(' + $ul.find('li:hidden').length + ')')
      });
    } else {
      $ul.find('li').slideDown(() => {
        $toggle.text('Show less');
      });
    }

    $toggle.data('more', !$toggle.data('more'));
  }

  function setupFilterListing($ul) {
    $ul.find('li:gt(10)').hide();

    const $toggle = $('<a>').attr('href', 'javscript:void(0)')
                            .addClass('btn').addClass('btn-default').addClass('btn-xs')
                            .css('marginLeft', '40px')
                            .text('Show more ' + '(' + $ul.find('li:hidden').length + ')');
    $toggle.data('more', false);
    $toggle.on('click', () => toggleListing($toggle, $ul));

    $ul.after($('<p>').append($toggle));
  }

  $('.search-listing-filter ul').each((_, ul) => {
    const $ul = $(ul);
    if ($ul.find('> li').length > 10) {
      setupFilterListing($ul);
    }
  });

})();