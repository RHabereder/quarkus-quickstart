# Quarkus Quickstart

This Project is a little demo on how to build a quarkus native image in docker. 
The source is just a simple JAX-RS Webservice that says hello. 

Build, compile and run a Quarkus Native Image with the following commands

```
 docker build -t quarkus .
 docker run -p 8080:8080 quarkus
```

Once it's up, which shouldn't take long at all, you can test the service with
```
 curl localhost:8080/hello
```

It should say hello :)
