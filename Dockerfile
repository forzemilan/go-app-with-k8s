# Start from the latest golang base image
FROM golang:latest as builder
# Add maintainer info
LABEL maintainer="Tiiiim Wong<spookw@foxmail.com>"
# Set the current working folder inside the container
WORKDIR /app
# change golang env: enable gomod and change goproxy to goproxy.cn
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn
# Copy the go mad and sum files
COPY  go.mod go.sum ./
# Download all dependancies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download
# Copy the source from the current directory to the working directory inside the container
COPY . .
# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

###### start a new stage from scratch ######
FROM alpine:latest

RUN apk --no-cache add ca-certificates
# change timezont from UTC to CST
ENV TZ="Asia/Shanghai"
RUN apk --no-cache add tzdata && cp /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo ${TZ} > /etc/timezone 
# && apk del tzdata
RUN date

WORKDIR /root/
# Build Args
ARG LOG_DIR=/app/logs
# Create Log direcotry
RUN mkdir -p ${LOG_DIR}
# Add Environment variable of logfile
ENV LOG_FILE_LOCATION=${LOG_DIR}/app.log

# Copy the pre-built binary file from the previous stage
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]