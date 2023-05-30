# Happtiks - Dart (Flutter) edition

Demo application to use with the MappEMG pipeline.

The application is in active development and is still incomplete.

## Debug

The current version of the application displays a Star icon at the top left. By clicking that icon, a debug screen appears. A few debug screens can be accessed, by clicking the icon next to the Star, it will rotate through the different debug screens.

## How to use

To run the Happtiks application, we need to send commands directly to the application. There are 2 means to send commands:

- By receiving OSC messages (the [OSC Command Channel](#osc-command-channel))
- By using the reverse TCP connect (the [Reverse TCP Command Channel](#reverse-tcp-command-channel))

### OSC Command Channel

#### OSC Command Channel with the Manager

First, make sure we are on a network that allows multicast DNS (mDNS) service discovery.

Start the manager from [https://gitlab.artificiel.org/projets/121_nodes](https://gitlab.artificiel.org/projets/121_nodes).

Launch the application on a phone using the VSCode debugger, or as a standalone application.

Test the flutter application through the Manager UI controls.

To get an overview of the OSC messages sent between the Manager and Happtiks, see [OSC_MANAGER](/OSC_MANAGER.md)

#### OSC Command Channel without the Manager

To run the Happtiks application without the manager, we need to send commands directly to the application.

See the files `scripts/send-*` for bash tools to send commands. Most of the scripts use a cli tool named `send_osc`, which only send to localhost. This works well when running the Happtiks application on the localhost. But when the application is running on a phone, the OSC messages need to be routed to the phone. This can be done by using the `scripts/run-proxy-socat-udp.sh` bash script, which uses `socat` to serve a local UDP proxy that will forward packets to the phone.

### Reverse TCP Command Channel

The Reverse TCP Command Channel is a mean to have a "prompt" from the phone and launch commands manually. If enabled (see application configuration), the application will, on start, initiate a TCP connection to a specific port and address. When the manager address changes, the TCP connection is reinitiated.

To receive this connection, we need to open a raw TCP listening socket. This can be done using `netcat`, or `telnet`. The script in `scripts/run-listen-tcp-netcat-server.sh` takes care of it.

Once the phone has connected to the listening TCP socket, a prompt will appear that looks like this: `happtiks> `. We can then run commands. Try the `help` command to see what is available.

## Known issues

- not all messages from the Manager are handled
- not all properties of the `/state` Manager message are honored
- dart OSC library dependency points to a github fork, since we need types not implemented in the official library: T (True), F (False), h (int64)
- brightness does not reset when application closes, which can leave the phone on low brightness
- some names (ex: build name, device name...) are hardcoded and need to be implemented

### Vibration

- The current behaviour is to keep vibrating for 300ms and stop if there is no more requests. The iOS application has a different behaviour
- The [https://pub.dev/packages/vibration](https://pub.dev/packages/vibration) vibration package from Flutter does not have the same fine control and feeling as the iOS implementation. **Platform specific code should be implemented to honor the both "sharpness" and "frequency" parameters that can be used**

#### Physical properties of vibrator

See https://developer.android.com/develop/ui/views/haptics/actuators

Why the vibration is "crispy":

- because of active braking features?
- because of overshoot?

## Dependencies for scripts

Command line tools require the following linux packages

- pyliblo-utils
- socat
- netcat

## Performance of live data processing

On a Linux desktop

- Not on step: ~0.002 milliseconds
- On step ~0.02 milliseconds

Note: at first, the processing is a bit slower (~0.01ms) until all the circular buffers are filled. Then, there is no more memory allocation when calling `addNow()` and it gets much faster

## Vibration on Android

- maybe because of brake
- have to use the same curves that are sent to the iPhone app (eigher intensity or sharpness)

## For documentation

- why we have a "manager out" (backward compatibility)
