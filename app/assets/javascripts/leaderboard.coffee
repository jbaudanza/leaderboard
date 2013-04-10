jQuery ->
  $leaderboard = $('ul.leaderboard')
  $profile = $('#profile')
  $dialog = $('#receive-address-dialog')

  populateProfile = (json) ->
    # Balance
    text = (json['balance'] * 0.00000001).toFixed(2) + " BTC"
    $profile.find('.balance').text(text)

    # Addresses
    $ul = $profile.find('ul.addresses')
    $ul.empty()

    addLi = (text, className) ->
      $('<li>').text(text).addClass(className).appendTo($ul)

    if json['addresses'].length > 0
      for address in json['addresses']
        addLi(address.address, 'address')
    else
      addLi("This user hasn't verified any wallet addresses.", 'empty')

    $dialog.find('.validation-address').text(json['validation_address'])

    $dialog.find('img.qr-code').attr(
        'src', "/qr_codes/#{json['validation_address']}")

    twitterHandle = json['name']

    $twitter = $profile.find('.twitter')
    $twitter.find('img').attr('src',
        "https://api.twitter.com/1/users/profile_image?screen_name=#{twitterHandle}&size=bigger")

    $twitter.find('a')
        .attr('href', "http://www.twitter.com/#{twitterHandle}")
    $twitter.find('.handle')
        .text('@' + twitterHandle)


  undefined

  # Populate the profile with the selected row
  id = $leaderboard.find('.selected').data('id')
  $.getJSON "/identities/#{id}.json", (json) ->
    populateProfile(json)

  #
  # Setup behaviors
  #
  $leaderboard.on 'click', 'li', ->
    $leaderboard.find('li').removeClass('selected')

    id = $(this).addClass('selected').data('id')
    if id
      $profile.show()
      $.getJSON "/identities/#{id}.json", (json) ->
        populateProfile(json)
    else
      $profile.hide()

  $profile.on 'click', '.refresh', ->
    id = $leaderboard.find('.selected').data('id')
    $.post "/identities/#{id}/refresh", (json) ->
      populateProfile(json)
    false

  $profile.on 'click', '.add-address', ->
     $dialog.dialog('open')
    false

  $dialog.dialog(
      autoOpen: false
      modal: true
      width: 500)
