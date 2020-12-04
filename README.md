# Payments

### Docker Local Build

```sh
# Takes a bit
docker build --build-arg PORT=8080 . -t payments:local
```

### Run

```
docker run -p 8080:8080 payments:local
```

Open a browser and hit localhost:8080, if you need a different port change 8080:8080 to <your-port>:8080
