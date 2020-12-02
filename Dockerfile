FROM mcr.microsoft.com/dotnet/sdk:5.0 as build

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs

WORKDIR /build/
COPY . /build/

RUN dotnet restore
RUN dotnet build payments.web -c Release -o /app
RUN dotnet test

FROM build as publish
RUN dotnet publish payments.web -c Release -o /app

FROM mcr.microsoft.com/dotnet/sdk:5.0 as final
COPY --from=publish /app .

ENTRYPOINT ["dotnet", "payments.web.dll"]
