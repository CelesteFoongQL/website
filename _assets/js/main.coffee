$ ->
  $('#scroll-indicator').addClass('animated bounce').removeClass 'hidden'
  menu = $('.sidebar')
  menulink = $('.menu-toggle')
  $(menulink).click ->
    $(menulink).toggleClass 'active'
    $(menu).toggleClass 'active'
    $('#page-content-wrapper').toggleClass 'active'
    false
  return
