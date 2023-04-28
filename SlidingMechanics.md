# Sliding Mechanics

## Design choices to make

There is a variety of ways how sliding can work in game.
From the small stuff to the big stuff.

Let's list everything we've settled for with sliding for now:

- Sliding is initiated when a player presses a crouch button while running
- Jumping while sliding is allowed and keeps the player sliding

Other things were not decided upon yet, but I, the micromechanics enthusiast, will provide some ideas in this document.

## Slide direction

Pretty much the most sensible thing to do with sliding direction is to make it follow the direction of the player's velocity.
Let's develop this idea, to prevent silly problems.

### Player's input is very different from player's velocity when initiating a slide

Imagine the following:
Player holds forward and moves currently at max speed.
Player lets go of the forward key and presses some other direction.
Player presses the crouch button.

What should happen?

It'd be pretty silly imo that after pressing the backwards key for example, the player would still slide forward, so let's think this through.

The most reasonable solution is to simply check whether is input direction is too different than movement direction
(that is done with the dot product, if the dot product of the two vectors is less than zero, that would mean
that the input direction is different by at least 90 degrees from the velocity vector) and if that's the case, the player crouches instead.

The other possible solution is to make slides independent from velocity direction, but that'd be weird I think.

## Slide direction 2

I didn't like the first idea after thinking about it, so I think I came up with a more sensible way to slide.

Slide direction is determined only by the player input.
You can only slide forward, forward-right, forward-left, otherwise you crouch.
You can't slide if you face the direction opposite of your movement, you crouch instead.

As shrimple as that.

That does allow for weird slides from a physics standpoint
(turning your camera by a bit less than 90 degrees to the left and sliding to the forward left 
would result in initating a slide that goes in almost the opposite direction of your velocity), 
but from a gameplay standpoint the player would move exactly how'd they want to move.
And that what matters.

## Influencing a slide direction

I think influencing a slide direction with camera is tricky.
I'd say the best option would be that the camera direction gently nudges the slide direction, 
but if the player turns like 180 degrees the slide should end (otherwise chronic back pains).

Considering influencing a slide direction with movement keys,
I see two options:
1) Player can freely change their slide direction by alternating forward, forward+right, forward+left
   Letting go of the movement keys would simply keep the slide forward.
	 Pressing any other combination of movement keys would end the slide.
2) Movement keys do not influence the current slide.

I like the first option more because it's silly.

## Speed of the slide

Here it does feel actually simple:
- if a player holds an allowed movement key combination, slide is initiated at max speed
- if a player does not hold a movement key, slide is initiated at the current speed
- if a player holds a FORBIDDEN (yikes!) movement key combination, player crouches instead

A slide has two deceleration values:
- deceleration value for when the player holds a movement key combo
- deceleration value for when the player does not hold any movement key button

Slide deceleration is **not applied** when the player is in the air because funy.
For titanfall 2-esque experience every slide jump should add a little bit to the player speed and the speed cap in the air during a slide should not exist.

This way a player has a pretty fine control over player's speed during a slide.

## Ending a slide

A slide ends when:
- The player's velocity hits a critical point
- The player does not want to slide anymore

The first way of ending a slide is selfexplanatory.

The second is up for discussion, I propose the following conditions for ending a slide:
- Player presses a non-slide-y movement key combo
- Player turns by more than 200 degrees from the slide direction
- Player hits a wall face-on (the angle between the slide direction and the wall is within the 180±45 degrees range)
- Player presses crouch during a slide (i think the crouch button shouldn't be held during a slide because pinky would hurt)

## Conclusion
The fog is coming. The fog is coming. The fog is coming. The fog is coming. The fog is coming. The fog is coming. The fog is coming. The fog is coming.