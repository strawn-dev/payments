FROM mcr.microsoft.com/dotnet/sdk:5.0 as build

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs
RUN npm install -g npm


WORKDIR /build/
COPY . /build/

RUN cd payments.web/ClientApp && npm install && cd ../..
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

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine as run
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

COPY --from=publish /app /app
WORKDIR /app

RUN mkdir -p /ASP.NET/DataProtection-Keys
RUN chown -R 1001:0 /ASP.NET/DataProtection-Keys

# don't run as root
RUN chown 1001:0 payments.web.dll
RUN chmod g+rwx payments.web.dll
USER 1001

CMD ASPNETCORE_URLS=http://*:$PORT dotnet payments.web.dll
