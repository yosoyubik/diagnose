/-  spider
/+  strandio, ethereum, dice
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
|^
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=+  [our=(scot %p our.bowl) now=(scot %da now.bowl)]
=+  path=/dbug/subscriptions/noun
::
=+  .^(dudes=(set [dude:gall ?]) %ge our %base now /$)
=+  .^([eth-out=boat:gall eth-in=bitt:gall] %gx our %eth-watcher now path)
=+  .^([azi-out=boat:gall azi-in=bitt:gall] %gx our %azimuth now path)
=+  .^(logs=(list event-log:rpc:ethereum) %gx our %azimuth now /logs/noun)
=+  .^(last-d-block=@ud %gx our %eth-watcher now /block/azimuth/noun)
=+  .^(timers=(list [@da duct]) %bx our %$ now /debug/timers)
::
=/  last-p-block=@  number:(last-block-id:dice logs)
;<  d-block-date=(unit @da)  bind:m
  ?:  =(0 last-d-block)
    (pure:(strand:strandio ,(unit @da)) ~)
  =/  jon=json  (numb:enjs:format last-d-block)
  (fetch-block ?>(?=([%n *] jon) (trip p.jon)))
;<  ~  bind:m  (sleep:strandio ~s5)
;<  p-block-date=(unit @da)  bind:m
  ?:  =(0 last-p-block)
    (pure:(strand:strandio ,(unit @da)) ~)
  =/  jon=json  (numb:enjs:format last-p-block)
  (fetch-block ?>(?=([%n *] jon) (trip p.jon)))
::
=/  running-eth=?  (~(has in dudes) [%eth-watcher &])
=/  installed-eth=?
  |(running-eth (~(has in dudes) [%eth-watcher |]))
=/  running-azi=?  (~(has in dudes) [%azimuth &])
=/  installed-azi=?
  |(running-azi (~(has in dudes) [%azimuth |]))
::
=/  eth-has-subscription=?
  %+  roll  ~(tap by eth-in)
  |=  [[=duct [=ship =^path]] has=_|]
  ::~&  duct^ship^path
  ?|  has
      ?&  ?|  ?=([[%gall %use %azimuth @ @ @ %eth-watcher @ %eth-watcher ~] *] duct)
              ?=([[%gall %use %azimuth @ @ @ %eth-watcher %eth-watcher ~] *] duct)
          ==
          =(path /logs/azimuth)
  ==  ==
=/  azi-is-subscribed=?
  %+  roll  ~(tap by azi-out)
  |=  [[[=wire =ship =term] [acked=? =^path]] is=_|]
  ?|  is
      ?&  =(wire /eth-watcher)
          =(term %eth-watcher)
          acked
          =(path /logs/azimuth)
  ==  ==
::
=/  has-eth-watcher-timer=?
  %+  lien  timers
  |=  [@da =duct]
  ?=([[%gall %use %eth-watcher @ @ %timer %azimuth ~] *] duct)
::
=/  d-date=tape  ?~(d-block-date "unknown" "{<u.d-block-date>}")
=/  p-date=tape  ?~(p-block-date "unknown" "{<u.p-block-date>}")
::
%-  %-  slog
  :~  leaf+"last downloaded %azimuth block: #{<last-d-block>} on {d-date}"
      leaf+"last processed %azimuth block: #{<last-p-block>} on {p-date}"
      leaf+"installed %eth-watcher? {<installed-eth>}"
      leaf+"running %eth-watcher? {<running-eth>}"
      leaf+"installed %azimuth? {<installed-azi>}"
      leaf+"has %eth-watcher an %azimuth subscription? {<eth-has-subscription>}"
      leaf+"has %eth-watcher a %behn timer? {<has-eth-watcher-timer>}"
      leaf+"is %azimuth subscribed to %eth-watcher? {<azi-is-subscribed>}"
      leaf+"..."
      leaf+"(wait 5s. to run the thread again)"
  ==
(pure:m !>(~))
::
++  fetch-block
  |=  block=tape
  =/  m  (strand:strandio ,(unit @da))
  ^-  form:m
  =/  url=@t  %-  crip
    "https://api.etherscan.io/api?module=block&action=getblockreward&blockno={block}"
  =/  =request:http
    :*  method=%'GET'
        url
        header-list=~
        ~
    ==
  ;<  ~  bind:m
    (send-request:strandio request)
  ;<  rep=(unit client-response:iris)  bind:m
    take-maybe-response:strandio
  %-  pure:m
  ?.  ?&  ?=([~ %finished *] rep)
          ?=(^ full-file.u.rep)
      ==
    ~
  ?~  jon=(de:json:html q.data.u.full-file.u.rep)
    ~
  %.  u.jon
  =,  dejs-soft:format
  (ot 'result'^(ot 'timeStamp'^(cu from-unix:chrono:userlib (su dem)) ~) ~)
--

