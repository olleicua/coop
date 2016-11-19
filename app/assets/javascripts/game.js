(function() {

  $(function() {

    $('.instructions').html('select a color');

    var currentColor = null;

    $('.palette').find('.color').click(function() {
      currentColor = $(this).data('color');
      $('.palette').css({visibility: 'hidden'})
      $('.instructions').html('paint');

      $('.game')
        .css({cursor: 'none'})
        .on('mouseover mousemove', function(e) {
          $('.cursor').css({
            backgroundColor: currentColor,
            left: e.pageX - 4,
            top: e.pageY - 4,
            display: 'block'
          });
        })
        .on('mouseleave', function() {
          $('.cursor').hide();
        });

      $('.pixel')
        .on('mouseenter', function() {
          $(this).css({opacity: 0.2});
        })
        .on('mouseleave', function() {
          $(this).css({opacity: 1});
        })
        .click(function() {
          var gameData = $('.game').data();
          var pixelData = $(this).data();

          $.ajax({
            url: '/games/' + gameData.id + '/move.json',
            method: 'patch',
            data: { move: {
              row: pixelData.row,
              column: pixelData.column,
              color: currentColor
            } },
            success: function(data) {
              if (data.update) {
                location.reload();
              } else {
                $('.cursor').remove();
                $('.game').css({cursor: 'default'})
                $('.instructions').html('move locked in');
              }
            }
          });
        });
    });

    var poll = function() {
      var gameData = $('.game').data();

      $.ajax({
        url: '/games/' + gameData.id + '/poll.json',
        method: 'get',
        success: function(data) {
          if (data.updated > gameData.updated) {
            location.reload();
          } else {
            setTimeout(poll, 1500);
          }
        }
      });
    };

    poll()

  });

})();
