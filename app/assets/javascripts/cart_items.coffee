$(document).on 'click', '.js-quantity-up', ->
  input = $(this).closest('.input-group').find('input[type=number]')
  input[0].stepUp()
  input.closest('form').submit()

$(document).on 'click', '.js-quantity-down', ->
  input = $(this).closest('.input-group').find('input[type=number]')
  input[0].stepDown()
  input.closest('form').submit()

$(document).on 'change', '.js-quantity-input', ->
  $(this).closest('form').submit()