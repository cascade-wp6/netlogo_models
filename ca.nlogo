;===========================================================
; CA: A framework for cellular-automata
; by Jon Pearce (www.cs.sjsu.edu/faculty/pearce/pearce.html)s
;===========================================================

;==================================
;=====      Declarations      =====
;==================================

patches-own [ 
   state      
]

globals [ ]

;==================================
;===== Initializing the Model =====
;==================================
to init-model
   ca ; clear all
   random-seed new-seed ; randomly seed random number generator
   init-globals
   init-patches
end

to init-patches
   ask patches [init-patch]
end

;=====Initialization overridables =====

to init-globals

end

to init-patch
   set state random num-states
   color-patch
end

;==================================
;=====   Updating the Model   =====
;==================================

to update-model
   if finished?
   [ 
      print "Simulation halted"
      stop 
   ]
   tick ; increment the tick counter
   update-globals
   update-patches
   
end

to update-patches
   ask patches [update-patch]
end

; ===== Update overridables =====

to update-globals
   ; To do: update values of globals.
end

to-report finished?
   ; To do: report model halting condition.
   report false ; for now
end

to update-patch
   let my-neighbors other patches with [distance myself <= radius]
   let nbhd-state [state] of my-neighbors
   set state one-of modes nbhd-state
   color-patch
end

to color-patch
   let macro-state-size ceiling (num-states / 14)       
   let macro-state ceiling (state / macro-state-size)       
   let named-color 10 * macro-state + 5       
   set pcolor named-color     
end



@#$#@#$#@
GRAPHICS-WINDOW
205
10
644
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks

CC-WINDOW
5
484
653
579
Command Center
0

BUTTON
9
35
90
68
INIT
init-model
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
105
35
190
68
UPDATE
update-model
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
39
81
163
114
radius
radius
1
10
1
1
1
NIL
HORIZONTAL

SLIDER
13
135
185
168
num-states
num-states
0
20
15
1
1
NIL
HORIZONTAL

@#$#@#$#@
WHAT IS IT?
-----------
CA is a framework for creating 2-dimensional cellular automata models (2D-CA) in NetLogo.

HOW IT WORKS
------------

An NetLogo 2D-CA model consists of a two-dimensional array of cells (patches). Each cell has a state, which can be any value taken from some state space, and a neighborhood. The neighborhood of a cell, c, are all of those cells n such that:

|   n != c
|   distance c n <= radius

In otherwords, n is in c's neighborhood, or n is a neighbor of c, if the shortest path from c to n traverses at most radius cells.

For simplicity, the state spcace can be taken as all integers in the interval:

|   [0, num-states)

In addition, a 2D-CA has:

|   1. a procedure for initializing the state of a cell: init-patch
|   2. a procedure for updating the state of a cell: update-patch
|   3. a test that determines if the simulation should halt (finished?)

A simulation (i.e., running the model) is a run of the following control loop:

|   init-model
|   while [not finished?] [ update-model ]

The init-model and update-model procedures simply ask each cell to execute the init-patch and update-patch procedures, respectively.

To update a patch, c, the states of all of c's neighbors are collected into a set. Next, the neighborhood state is computed. This is the list of states of every patch in c's neighborhood. The built-in modes function reports a list of the most commonly occuring states in the neighborhood state. For example, if the neighborhood state is:

|   [1 2 3 4 2 3 2 3]

Then the modes will be the list:

|  [2 3]

One of these commonly occuring states is chosed at random using the built-in one-of function. Finally, the patch is colored. Here's the complete code:

|   to update-patch
|      let my-neighbors other patches with [distance myself <= radius]
|      let nbhd-state [state] of my-neighbors
|      set state one-of modes nbhd-state
|      color-patch
|   end

The update-patch procedure is overridable. Possible implementations include averaging the neighbor's states, choosing the maximum or minimum neighbor state, etc.

For example:

|   to update-patch
|      let my-neighbors other patches with [distance myself <= radius]
|      let nbhd-state [state] of my-neighbors
|      set state mean nbhd-state
|      color-patch
|   end

MAPPING STATE TO COLOR
-------------------

What is the ideal mapping of the state space, [0, num-states), into the NetLogo color space, [0, 140)?  If the state space is large, then different states can map to indistinguishable colors, "close" states can map to "distant" colors, and distant states can map to close colors.

To partially remedy this problem, we observe that the named colors in the NetLogo color space (excluding black and white) are encoded by the numbers 5, 15, 25, ..., 135. Let's call the set of these numbers the named-color-space:

|   named-color-space = {5, 15, 25, ..., 135}

Note that there are 14 members in the named-color-space. 

We can partition the state space into 14 macro states by integer division:

|   set macro-state state / macro-state-size

where 

|   macro-state-size = num-states / 14

We map the macro-state onto a named color as follows:

|   set named-color 10 * macro-state + 5

Here's the complete procedure:

|   to color-patch
|      let macro-state-size ceiling (num-states / 14)
|      let macro-state ceiling (state / macro-state-size)
|      let named-color 10 * macro-state + 5
|      set pcolor named-color
|    end

For example, if num-states is 70, then macro-state-size will be 70/14 = 5. We can think of the macro states as the 14 length 5 intervals:
  
|   [0, 5), [5, 10), [10, 15), ..., [65, 70)

If the state of a given cell, c, is 50, then its macro-state will be 50/5 = 10. This corresponds to the 10th interval: [50, 55). In this case the color of c will be 10 * 10 + 5 = 105 = blue. 

If the state of c is 63, then its macro-state will be 12 (= ceiling of 12.6) and its color will be 125 = magenta.

What colors do states 0 and 69 map onto?

As another example, if num-states is 14, then macro-state-size will be 14/14 = 1. If the state of cell c is 12, then its micro-state will also be 12 and its color will be 125. 

If num-states is 2, then macro-state-size will again be ceiling 2/14 = 1. If the state of cell c is 1, then its color will be 15 (red) otherwise its color will be 5 (grey).

With this in place we can add a slider to allow the user to adjust num-states.

HOW TO USE IT
-------------

If the control loop (described above) is running, pressing the UPDATE button pauses it. Otherwise the control-loop starts or resumes.

Pressing the INIT button initializes the 2D-CA.

The radius slider allows the user to experiment with different values for the radius variable described above.

THINGS TO NOTICE
----------------

Notice the evolving color patterns as the simulation runs. 

Do all of the patches eventually have the same color or are their "islands" of patches with a different color from their surroundings? How could this happen?

HOW MANY UPDATE-PATCH PROCEDURES ARE THERE?
-------------------
It's easy to see that the number of possible neighborhood states is: 

|   num-nbhd-states = num-states ^ (length nbrhd-state)

Our update-patch procedure maps each of these neighborhood states into a state. This means the number of update procedures is:

|   num-update-rules = num-states ^ num-nbrhd-states

We can therefore list all of these update procedures:

|   update-0, update-1, ..., update-k

where

|   k = num-update-rules - 1

For example, if radius = 1, then cell c has 8 neighbors. If num-states = 2, then there are 2^8 = 256 neighborhood states:

|   (0, 0, 0, ..., 0)
|   (0, 0, 0, ..., 1)
|   ...
|   (1, 1, 1, ..., 1)

This means there are 2 ^ 256 possible update rules. This is a huge number!

AGGREGATE STATE AND COMPLEXITY
-------------------
The aggregate state of the model, or the model state, is simply the list of states of all of the cells in the model:

|   set model-state [state] of patches

The update-patch procedure can be arbitrarily complex, but it doesn't need to be in order to generate complex or interesting patterns of change in the model-state. In such cases it might be difficult to predict patterns in the model state by studying how individual cells update themselves. 

The system (model) is more than the sum of its parts (cells). It has its own behavioral patterns that can't be explained by the behavior of its parts. It creates the impression that the system has an identity distinct from its identity as a collection of parts. Many natural and social systems have this property. Examples include societies, economies, ecosystems, brains, and corporations. Such systems are difficult to study using top-down or reductionist methods.

APPLICATIONS TO SOCIOLOGY
-------------------
The economist Thomas Schelling first applied this idea to sociology when he speculated that people who lived in segragated neighborhoods weren't necessarily racists. In this case we might think of patches as homes. The state of a patch is the race of the occupant. The update-patch procedure can be interpreted to say that the occupant of a home simply wants the majority of his neighbors to be of the same race. In other words, the occupant will tolerate neighbors of different races. Never the less, when we randomly assign occupants to homes, then run the simulation, we notice that segragated neighborhoods develop. 

Instead of race, the state of a patch can be the political party affiliation of the occupant. In this case the update-patch procedure can be interpreted as expressing the truism that we vote like our neighbors vote (despite the feeling that our political opinions are purely rational.) Perhaps this explains the red-state-blue-state phenomenon in US presidential elections. 

See http://www.theatlantic.com/doc/200204/rauch for more background on this.


PROJECT: MODELING CORRUPTION
-------------------
In the corruption model patches are individuals. The state of a patch is one of the strings: "corrupt", "honest", or "jailed". Initially no one is in jail, but a slider allows the user to control the initial number of corrupt individuals.

The update-patches procedure has two phases. In phase one it asks all unjailed patches to interact with their neighbors. In phase two it asks all patches to update themselves.

During the interaction phase each unjailed patch, p, selects a random set of its unjailed neighbors. For each such neighbor, n, if p is honest but n is corrupt, then p files a complaint against n. If n is honest but p is corrupt, then n files a complaint against p.

During the update phase each unjailed patch, p, computes the percentage of its neighbors that are jailed. If this ratio is below the crime-pays threshold, then p will change its state from honest to corrupt. If this ratio is above the too-risky threshold, then p will change its state from corrupt to honest. However, if p is corrupt, and the number of complaints against p exceeds the crime-tolerance threshold, then p will change its state from corrupt to jailed.

If p is a jailed patch, an if the number of ticks since p was jailed exceeds the jail-time, then p changes its state from jailed to honest.

Provide users with sliders to control the initial number of corrupt patches, the crime-pays threshold, the too-risky threshold, the crime-tolerance threshold, and jail-time. Also provide a plotter that plots the percentage of patches that are honest, corrupt, or jailed at tick t.

What can this model tell policy makers about the effectiveness of increasing sentences versus putting more police on the street? 

We can improve the model by giving each patch an influence attribute. For most patches the value of this attribute is 1, but for some the value can be higher. When an unjailed patch updates its state, it computes three ratios: honest-neighbors, corrupt-neighbors, and jailed-neighbors. Influential neighbors have greater weight in the computation of each of these ratios. The new state of p is based on some sensible combination of these ratios. For example, if most of p's neighbors are corrupt, and if few are in jail, then p becomes corrupt. If most are honest and if many are in jail, the p becomes honest. etc. We this in place we can study the policy of targeting influential individuals.

This model is based on a 1D-CA model developed by Ross Hammond. The model is dicussed in the article posted at http://www.theatlantic.com/doc/200204/rauch

PROJECT: 1D-CA
-------------------

As we have seen, the number of update procedures in a 2D-CA is huge. We can reduce the number of rules without losing expressiveness by considering one-dimensional cellular automata (1D-CA). These models were shown by Wolfram [Wolf] to be universal in the sense that any Turing machine can be encoded by the computation generated by some 1D-CA. 

A 1D-CA is a row of cells. Assume each cell can be in one of two states: 0 or 1. Each cell has two neighbors, three including itself. Therefore there are 8 possible neighborhood states. Each of these states can map to one of two new states by the update function. Therefore there are 2^8 = 256 possible update rules. 

How can an update rule be encoded as an integer between 0 and 256?

Assume the cells in row i of the NetLogo world represent some 1D-CA at time i. Since the default world consists of 32 x 32 cells, we can model 32 updates of a 1D-CA consisting of 32 cells. Is it possible to "wrap" time?

Provide a control that will allow the user to specify one of 256 rules.

Hint: 

You might want to define a global called world that is simply a shuffled list of 32 bits (i.e., 0's and 1's). 

Also define globals called clock and row with initial values 0 and 32, respectively.

The update-globals procedure updates world, clock, and row. Clock is incremented. World is updated according to the selected 1D-CA update rule. 

If the value of clock is divisible by k, for some suitable value of k (e.g., k = 10), then row is decremented and (patch i row) is colored red or blue according to the value of (item i world).

PROJECT: DISSEMINATING CULTURE
-------------------
In this project we use a NetLogo 2D-CA to study the dissemination of culture. The model is based on Robert Axelrod's paper: Disseminating Culture, which can be found in [Axelrod].

Assume each patch represents an ethnic region. Assume the state of a patch, called its culture, is a list consisting of N cultural features. For example:

|   position 0 = religion
|   position 1 = technology
|   position 2 = political organization
|   position 3 = economic system
|   position 4 = language
|   etc.

Assume the value of a cultural feature, called a trait, is an integer, t such that:

|   0 <= t < M

For example, the trait at position 0 might indicate the type of religion:

|   0 = Animism
|   1 = Hinduism
|   2 = Buddhism
|   3 = Christianity
|   4 = Judaism
|   5 = Islam
|   etc.

How many cultures are there in our model?

Let's assume the absolute value of the difference between two traits corresponds to their cultural distance. For example, if stone age technology is 0 then information age technology might be 8 indicating that the difference is very large. (Of course not all traits can be ordered in a linear way.) How can the color of a patch reflect its state in such a way that similar cultures have similar colors and dissimilar cultures have noticably different colors?

Initially the state of each patch is random.

To update the model:

|   1. For each patch, p1, pick a random neighbor, p2. 
|   2. Compute s = the percentage of features that p1 and p2 have in common.
|   3. Pick a random number n < 100. If n < s, then p1 borrows a trait from p2

Ideally, p1 borrows a trait from p2 other than one they already have in common.

Hint: In the RGB color space there are 256^3 = 2^24 colors. Since 24 = 6 * 4, this suggests we can take N = 4 and M = 6. Of course there are only 140 colors in the NetLogo color space. This might suggest choosing N = 5 and M = 3.

PROJECT: FOREST FIRE
-------------
Imagine each patch is a patch of ground in a forest. The state of a patch has three possible values: "has-tree" (pcolor = green), "burned" (pcolor = black), and "empty" (pcolor = brown). A patch also has a fertility attribute, which is a number between 0 and 1. Initially the state of a patch is empty and its fertility is set to a constant, init-fertility, which the user can adjust with a slider.

Every spring (cycles = an even number), each patch grows a tree with probability = fertility. Each summer (cycles = an odd number) lightening strikes a patch with probability = burn-probability, which the user can control with a slider.

If a patch has a tree and is struck by lightening, then its state changes to "burned". The fire spreads: all neighboring patches with trees burn. Their treed neighbors burn, and so on until the fire reaches a fire break of some sort. 

A plotter plots the percentage of the patches that are in the have-tree state.

A histogram shows the frequency of fires according to their sizes: at least 50 trees burned, at least 100, at least 150, etc. This histogram should follow a power law.

Will fire breaks naturally grow? Will the percentage of patches in the have-tree state stabalize under certain settings for fertility? Will the forest naturally find the optimal tree covering?

We can add adaptation to our patches as follows: when a patch is updated it firts counts the number of burned neighbors. If this number is above some critical number, for example, if more than four neighbors are in the burned state, then the patch decreases its fertility by some adjustable fertility-adaptation-factor. Otherwise the patch increases its fertility by this factor. Be careful. The fertility of a patch should always be a number between 0 and 1. After updating its fertility, the patch either grows a tree, burns, or does nothing as before.

What setting for the fertility-adaptation-factor produces the largest number of trees?

PROJECT: AVALANCHE!
--------------
Assume the state of each patch represents the number of grains of sand located on that patch. The color of a patch should be a shade of brown that reflects its state. A darker shade indicates more sand.

In addition to its usual duties, the update-model procedure drops a single grain of sand on 10 randomly chosen patches. (There's nothing magic about 10.)

If the state of a patch exceeds num-states, it distributes one grain of sand to each patch in my-neighborhood. (Of course this may cause these patches to go over the limit.) 

Use the histogram function to create a histogram showing the numbers of patches with 0, 1, 2, ..., num-states grains of sand.

Note that the histogram indicates an exponential growth in large patches. This is an example of the power law.

RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
Created by Jon Pearce (http://www.cs.sjsu.edu/faculty/pearce/pearce.html)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
