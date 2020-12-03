FROM mcr.microsoft.com/dotnet/sdk:5.0 as build

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs
RUN npm install -g npm
RUN npm install typescript

WORKDIR /build/
COPY . /build/

# Opt out of .NET Core's telemetry collection
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV NODE_ENV production

RUN dotnet restore
RUN dotnet build payments.web -c Release -o /app
RUN dotnet test

FROM build as publish
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
# set node to production
ENV NODE_ENV production
RUN dotnet publish payments.web -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/runtime:5.0-alpine as run
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

COPY --from=publish /app /app
WORKDIR /app

RUN mkdir -p /ASP.NET/DataProtection-Keys
RUN chown -R 1001:0 /ASP.NET/DataProtection-Keys

# don't run as root
RUN chown 1001:0 payments.web.dll
RUN chmod g+rwx payments.web.dll
USER 1001

EXPOSE 8080/tcp
ENV ASPNETCORE_URLS http://*:8080

ENTRYPOINT ["dotnet", "payments.web.dll"]
