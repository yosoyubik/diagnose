::  +stale-flows: prints number of ames flows that can be closed
::
::    |stale-flows, =veb %1  :: flows from nacking initial subscriptions
::    |stale-flows, =veb %2  :: stale flows that keep (re)trying to connect
::    |stale-flows, =veb %21 :: ... per app (only forward)
::    |stale-flows, =veb %3  :: stale resubscriptions
::    |stale-flows, =veb %4  :: print live naxplanation flows
::    |stale-flows, =veb %5  :: print corked flows
::
=>  |%
    +$  subs  (jar path [ship bone @ close=?])
    +$  pags  (jar app=term [dst=term =ship =path])  ::  per-agent
    +$  naks  (set [ship bone])
    ::  verbosity
    ::
    +$  veb  ?(%0 %1 %2 %21 %3 %31 %4 %5 %x)
    ::
    ++  resubs
      |=  [=subs =veb]
      ^-  @
      ::=/  sorted
      ::  %+  sort  ~(tap by subs)
      ::  |=([[* a=(list *)] [* b=(list *)]] (lte (lent a) (lent b)))
      %+  roll  ~(tap by subs)  ::sorted
      |=  [[k=path v=(list [ship bone @ close=?])] num=@]
      =/  in-close=@
        (roll v |=([[@ @ @ c=?] n=@] ?:(c +(n) n)))
      ~?  &(=(%3 veb) (gth (lent v) 1))
        %+  weld  ?:  =(in-close 0)  ""
          "[#{<in-close>} %close] "
        "#{<(dec (lent v))>} stale resubs on {<k>}"
      ?.  (gth (lent v) 1)  num
      (add (dec (lent v)) num)
    --
::
:-  %say
|=  $:  [now=@da eny=@uvJ bec=beak]
        [arg=~ peer=(unit @p) dry=? =veb]
    ==
::
=/  peers-map
  .^((map ship ?(%alien %known)) %ax /(scot %p p.bec)//(scot %da now)/peers)
::
=/  peers=(list ship)
  %+  murn  ~(tap by peers-map)
  |=  [=ship val=?(%alien %known)]
  ?:  =(ship p.bec)
    ~  ::  this is weird, but we saw it
  ?-  val
    %alien  ~
    %known  (some ship)
  ==
::
=;  [[=subs =pags close=@ corked=@ incoming=@ outgoing=@ nax=@] =naks]
  :-  %tang  %-  flop
  %+  weld
    :~  leaf+"#{<~(wyt in naks)>} flows from %nacking %watches"
        leaf+"#{<incoming>} live backward flows"
        leaf+"#{<outgoing>} live forward flows"
        leaf+"#{<nax>} live naxplanations"
        leaf+"#{<close>} flows in closing"
        leaf+"#{<corked>} flows corked"
        leaf+"#{<(resubs subs veb)>} stale resubscriptions"
    ==
  ?.  =(%21 veb)  ~
  :-  leaf+"----------------------------------"
  %+  turn  %+  sort  ~(tap by pags)
            |=  [[* v=(list)] [* w=(list)]]
            (gth (lent v) (lent w))
  |=  [app=term v=(list [dst=term =ship =path])]
  :-  %leaf
  %+  weld  "#{<(lent v)>} flows for {<app>}"
  ?.  =(1 (lent v))  ~
  ?>  ?=(^ v)
  " on {<ship.i.v>} to {<dst.i.v>} at {<path.i.v>}"
::
%+  roll  peers
|=  [=ship [=subs p=pags cl=@ cr=@ in=@ ou=@ na=@] =naks]
?:  ?&  ?=(^ peer)      
        !=(u.peer ship)  
    ==
  +<+ 
=+  .^  =ship-state:ames
        %ax  /(scot %p p.bec)//(scot %da now)/peers/(scot %p ship)
    ==
=/  =peer-state:ames  ?>(?=(%known -.ship-state) +.ship-state)
::
|^  [stale nacks]
::
++  stale
  %+  roll  ~(tap by snd.peer-state)
  |=  $:  [=bone message-pump-state:ames]
          subs=_subs   pags=_p
          close=_cl  corked=_cr
          incoming=_in  outgoing=_ou  nax=_na
      ==
  =,  packet-pump-state
  =+  closing=(~(has ^in closing.peer-state) bone)
  =+  is-corked=(~(has ^in corked.peer-state) bone)
  ~?  &(is-corked =(%5 veb))  "bone {<bone>} is corked"
  =?  corked  is-corked  +(corked)
  :-  ?~  duct=(~(get by by-bone.ossuary.peer-state) bone)  subs
      ::?.  ?=([* [%gall %use sub=@ @ %out @ @ nonce=@ pub=@ *] *] u.duct)
      ?.  ?=([* [%gall %use sub=@ @ %out @ @ *] *] u.duct)
        subs
      =/  =wire  i.t.u.duct
      =/  nonce=(unit @ud)  
        ?~  (slag 7 wire)  ~  
        (slaw %ud &8.wire)
      %-  ~(add ja subs)
      :_  [ship bone ?~(nonce 0 u.nonce) closing]  :: 0, 1?
      ?~  nonce
        wire
      ::  don't include the sub-nonce in the key
      ::
      (weld (scag 7 wire) (slag 8 wire))
  ?~  live  [pags close corked incoming outgoing nax]
  ::%+  roll  ~(tap ^in live)
  ::|=  $:  [[msg=@ frag=@] [packet-state:ames *]]
  ::        pags=_pags
  ::        out=[c=_close co=_corked i=_incoming o=_outgoing n=_nax]
  ::    ==
  ::
  ::  only forward flows
  ::
  =?  pags  =(%0 (mod bone 4))
    ?~  duct=(~(get by by-bone.ossuary.peer-state) bone)
      pags
            ::  0     1    2    3  4   5 6   7      8
    ::?.  ?=([* [%gall %use sub=@ @ %out @ @ nonce=@ pub=@ *] *] u.duct)
    ?.  ?=([* [%gall %use sub=@ @ %out @ @ *] *] u.duct)
      pags
    =/  =wire  i.t.u.duct
    (~(add ja pags) (snag 2 wire) (snag 6 wire) ship (slag 7 wire))
  ::
  =?  close  closing  +(close)
  ~?  =(%2 veb)
    =/  arrow=tape
      ?+  (mod bone 4)  ~|([%odd-bone bone] !!)
        %0  "<-"
        %1  "->"
        %3  "<-"
      ==
    "{arrow} ({(cite:title ship)}) bone=#{<bone>} closing={<closing>}"
  ::
  ~?  &(=(%4 veb) =(%3 (mod bone 4)))
    "nax: ({(cite:title ship)}) bone=#{<bone>} closing={<closing>}"
  :^  pags  close  corked
  ?+  (mod bone 4)  ~|([%odd-bone bone] !!)
    %0  [incoming +(outgoing) nax]
    %1  [+(incoming) outgoing nax]
    %3  [incoming outgoing +(nax)]
  ==
::
++  nacks
  %+  roll  ~(tap by rcv.peer-state)
  |=  [[=bone *] n=_naks]
  ?.  &(=(0 (end 0 bone)) =(1 (end 0 (rsh 0 bone))))
    ::  not a naxplanation ack bone
    ::
    n
  ::  by only corking forward flows that have received
  ::  a nack we avoid corking the current subscription
  ::
  =+  target=(mix 0b10 bone)
  ::  make sure that the nack bone has a forward flow
  ::
  ?~  duct=(~(get by by-bone.ossuary.peer-state) target)
    n
  ?.  ?=([* [%gall %use sub=@ @ %out @ @ nonce=@ pub=@ *] *] u.duct)
    n
  =/  =wire      i.t.u.duct
  =+  closing=(~(has ^in closing.peer-state) bone)
  ?>  ?=([%gall %use sub=@ @ %out @ @ nonce=@ pub=@ *] wire)
  =/  app=term   i.t.t.wire
  =/  nonce=@
    =-  ?~(- 0 u.-)
    (slaw %ud &8.wire)
  =/  =path  |8.wire
  ~?  =(%1 veb)  
    "[bone={<target>} nonce={<nonce>} agent={<app>} close={<closing>}] {<path>}"
  (~(put ^in n) [ship target])
--




