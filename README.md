# dbus

A block that provides dbus allowing communication among services. Unlike the hostOS dbus in balenaOS, you can use this block as base and provide custom dbus configurations.

## How to use

Add the dbus block as a service in your docker-compose file to start a single bus. The default is to start a bus with the "session" bus config on TCP port 55884.

```yml
version: "2"
services:
  dbus:
    image: balenablocks/dbus
    restart: always
```

You can also start a bus with the "system" config by overriding the `DBUS_CONFIG` environment variable.

```yml
version: "2"
services:
  dbus-session:
    image: balenablocks/dbus
    restart: always
    environment:
      DBUS_CONFIG: session.conf
  dbus-system:
    image: balenablocks/dbus
    restart: always
    environment:
      DBUS_CONFIG: system.conf
```

Configure your services requiring access to dbus to use the TCP addresses of the containers providing the busses

Example:

```bash
export DBUS_SESSION_BUS_ADDRESS=tcp:host=dbus-session,port=55884
export DBUS_SYSTEM_BUS_ADDRESS=tcp:host=dbus-system,port=55884
```

Alternatively, the server can listen on UNIX domain sockets. Your container can connect to this bus by sharing the socket through a named volume and specifying the appropriate environment variable:

```yml
version: "2"
volumes:
  dbus:
services:
  dbus-session:
    image: balenablocks/dbus
    environment:
      DBUS_ADDRESS: unix:path=/run/dbus/session.sock
    volumes:
      - dbus:/run/dbus
  my-app:
    build: ./app
    volumes:
      - dbus:/run/dbus
    environment:
      DBUS_SESSION_BUS_ADDRESS: unix:path=/run/dbus/session.sock
```


## Customization

### Extend image configuration

You can extend the `dbus` block to include custom configuration as you would with any other Dockerfile. Just make sure you don't override the `ENTRYPOINT` as it contains important system configuration.

Example:

```dockerfile
FROM balenablocks/dbus

COPY example.conf /etc/dbus-1/system.d/

COPY mystartscript.sh /usr/src/

CMD [ "/bin/bash", "/usr/src/mystartscript.sh" ]

```

### Environment variables

| Environment variable | Description                                                         | Default      | Options |
| -------------------- | ------------------------------------------------------------------- | -------      | ------- |
| `DBUS_PORT`          | The port on which the bus listens, only for TCP sockets             | 55884        | -       |
| `DBUS_CONFIG`        | The config file to use for the bus, relative to /usr/src/app        | session.conf | -       |
| `DBUS_ADDRESS`       | The address to listen on, allows using UNIX domain sockets          | -            | -
