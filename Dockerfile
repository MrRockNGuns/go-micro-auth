#FROM docker.io/library/golang AS builder
FROM registry.access.redhat.com/codeready-workspaces/stacks-golang    as builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go install github.com/air-verse/air@latest
RUN go install github.com/gin-gonic/gin
RUN go mod download

COPY . . 

RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/main ./cmd/api 

COPY . . 

#FROM docker.io/library/golang
FROM registry.access.redhat.com/codeready-workspaces/stacks-golang   

WORKDIR /app

COPY --from=builder . .
COPY --from=builder /app/main .
COPY --from=builder /app/go.mod .
COPY --from=builder /app/go.sum .
COPY --from=builder /app/.air.toml .


RUN go install github.com/air-verse/air@latest
RUN go install github.com/gin-gonic/gin

RUN chmod 666 /app/.air.toml

EXPOSE 3001

ENTRYPOINT [ "air", "-c", ".air.toml" ]
