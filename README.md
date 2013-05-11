# What is it?

A Hubot script for controlling Minecraft servers over RCON.

# Installation

1. Install this module into an existing Hubot:

    % npm i -S hubot-mcrcon

1. List this module in your Hubot's `external-scripts.json`.  e.g.:

    ["hubot-mcrcon"]

# Set up

Your Minecraft must have RCON enabled and be reachable from
the Hubot server hosting this script.

The following environment variables must be set to properly
start up:

    # minecraft host or ip
    % export HUBOT_MCRCON_HOST=minecraft.example.com
    # minecraft rcon port
    % export HUBOT_MCRCON_PORT=25575
    # minecraft rcon password
    % export HUBOT_MCRCON_PASS=********
    # mention_name of a user allowed to execute minecraft op commands
    % export HUBOT_MCRCON_BOSS=FooBar

# TODO

* Support multiple Minecraft servers per Hubot
* Map XMPP usernames to Minecraft usernames for 'say'
* Grant XMPP users op command privileges
