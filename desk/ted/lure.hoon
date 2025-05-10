/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<([~ group-id=@t] arg)
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  id=@t  (crip +:(spud /[(scot %p our.bowl)]/[group-id]))
=/  =cage  [%reel-describe !>([id fields=[%groups-0 ~]])]
;<  ~      bind:m  (poke-our:strandio %reel cage)
=/  =path
  /v1/id-link/[(scot %p our.bowl)]/[group-id]
;<  ~      bind:m  (watch-our:strandio /reel %reel path)
;<  =^cage  bind:m  (take-fact:strandio /reel)
=+  !<(=json q.cage)
?>  ?=(%s -.json)
(pure:m !>(p.json))

