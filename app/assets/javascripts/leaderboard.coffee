window.populateProfile = (json) ->
  $profile = $('#profile')

  # Balance
  text = (json['balance'] * 0.00000001).toFixed() + " BTC"
  $profile.find('.balance').text(text)

  # Addresses
  $ul = $profile.find('ul.addresses')
  $ul.empty()
  for address in json['addresses']
    $('<li>').text(address.address).appendTo($ul)

  $profile.find('.validation-address').text(json['validation_address'])

  $profile.find('img.qr-code').attr(
      'src', "/qr_codes/#{json['validation_address']}")

  twitterHandle = json['name']

  $twitter = $profile.find('.twitter')
  $twitter.find('img').attr('src',
      "https://api.twitter.com/1/users/profile_image?screen_name=#{twitterHandle}&size=bigger")

  $twitter.find('a')
    .attr('href', "http://www.twitter.com/#{twitterHandle}")
    .text('@' + twitterHandle)


  undefined

#    
# Setup behaviors
#
jQuery ->
  $leaderboard = $('ul.leaderboard')

  # Populate the profile with the selected row
  id = $leaderboard.find('.selected').data('id')
  $.getJSON "/identities/#{id}.json", (json) ->
    populateProfile(json)

  $leaderboard.on 'click', 'li', ->
    $leaderboard.find('li').removeClass('selected')

    id = $(this).addClass('selected').data('id')
    if id
      $('#profile').show()
      $.getJSON "/identities/#{id}.json", (json) ->
        populateProfile(json)
    else
      $('#profile').hide()

  $('#profile .refresh').click ->
    id = $leaderboard.find('.selected').data('id')
    $.post "/identities/#{id}/refresh", (json) ->
      populateProfile(json)
