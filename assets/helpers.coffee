# read cookie
readCookie = (name) ->
  nameEQ = escape(name) + "="
  ca = document.cookie.split(";")
  i = 0
  while i < ca.length
    c = ca[i]
    c = c.substring(1, c.length)  while c.charAt(0) is " "
    return unescape(c.substring(nameEQ.length, c.length).replace(/"/g, ''))  if c.indexOf(nameEQ) is 0
    i++
  return

# set cookie
setCookie = (cookieName, cookieValue, expire = null) ->
  if not expire
    expire = new Date()
    expire.setDate(expire.getDate() + 365 * 30)
  document.cookie = escape(cookieName) + "=" + escape(cookieValue) + ";expires=" + expire.toGMTString() + ";domain=." + location.hostname + ";path=/";

variant = false

abTest = (usableVariants, fallbackVariant) ->
  maxI = usableVariants.length - 1
  minI = -1
  variant = readCookie('ab_testing_variant')

  if (!!variant) or (variant is '0') or (variant is '-1')
    variant = parseInt(variant, 10)
    if variant < 0
      window.ab_variant = fallbackVariant
      return
    if variant > maxI
      variant = false
  else
    variant = false

  if variant is false
    variant = Math.floor(Math.random() * (maxI - minI + 1) + minI)
    setCookie 'ab_testing_variant', variant, new Date(1*new Date() + 3600*1000)

  if variant > -1
    window.ab_variant = usableVariants[variant][0]
    return usableVariants[variant]

abTestWrite = (klass, usableVariants, fallbackVariant) ->
  chosenVariant = abTest usableVariants, fallbackVariant
  if not chosenVariant
    return
  s  = "#{unescape('%3Cspan')} class=\"#{klass}\"#{unescape("%3E")}"
  s += chosenVariant[1]
  s += unescape("%3C/span%3E")
  document.write s

initDots = ->
  $els = [].slice.call(document.querySelectorAll('.anim__item'), 0)
  $els.forEach (dot, ind) ->
    i = parseInt dot.getAttribute('data-dots'), 10
    frg = document.createElement 'span'
    frg.setAttribute 'class', "anim__dots__all anim__len__#{i} anim__delay__#{ind}"
    dot.style.width = frg.style.width = i * 12 + 'px'
    s = ''
    while (i)
      s += '<span class="anim--dot"></span>'
      i--
    frg.innerHTML = s
    dot.insertBefore(frg, dot.lastChild)
