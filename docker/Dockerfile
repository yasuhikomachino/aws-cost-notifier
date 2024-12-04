# build stage
FROM golang:1.22 AS build

WORKDIR /app

COPY ./src/go.mod ./src/go.sum ./
RUN go mod download

COPY ./src .
RUN go build -tags lambda.norpc -o main main.go

# run stage
FROM public.ecr.aws/lambda/provided:al2023

COPY --from=build /app/main ./main
ENTRYPOINT [ "./main" ]

