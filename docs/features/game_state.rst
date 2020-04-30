Game state
==========

GOAT offers a simple way of storing the state of the game. The state consists
of variables, and each variable has a name and a value. To add a variable to
the game state, use the ``register_variable`` method:

::

   goat_state.register_variable(variable_name, initial_value)

This will create a new variable and set its initial value. A variable cannot be
used if it was not registered first. The variable can be acccessed later like
this:

::

   goat_state.get_value(variable_name)

It is also possible to change its value:

::

   goat_state.set_value(variable_name, value)

This will emit a signal: ``changed (variable_name, from_value, to value)``,
which can be used to react to game state changes in different scenes.

Before each new game, the state should be reset:

::

   goat_state.reset()

This will set the initial values to all registered variables.
