---
title: "Linux에서 Nginx + ASP.NET Core로 웹서비스 돌리기"
cover: "sunset-2173918_1920.jpg"
date: "2020-05-15"
category: ""
tags:
    - .netcore
    - react
    - Nginx
---


# Linux에서 Nginx + ASP.NET Core로 웹서비스 돌리기

켜져있어서 돌아가는 서비스를 돌리다보면 새로운 시스템을 도입할 일도 있다. 신규 시스템을 도입은 두렵고 행복하다. 지금까지 터졌던 이슈들을 한번씩 다시 다 잡아야된다는 의미일수도 있지만, 우리가 겪었던 문제를 동일하게 겪은 시장이 그 문제를 해결하고자 출시한 많은 시스템들 위에서 새로 시스템을 쌓아가는 것은 참 가슴 뛰는 일이다.
시작할 때 잘 잡아두면 완전히 자동화된 운영/배포 환경을 가지고 다양한 장애에서도 꺼지지 않는 시스템을 운영할 수 있을 것이라는 희망, 개발자와 운영자를 위해 세계의 개발자들이 만들어 둔 다양한 툴 중에 프로젝트에 필요한 도구만 쏙쏙 뽑아쓰는 재미, 조금의 아쉬운 점을 개선해서 PR을 날리고 머지가 되고, 대단한 아이디어와 코드 품질로 유명한 프로젝트 메인테이너가 되고, 이름이 높아져 고액 연봉 계약, 정치권 진출, 대통령 엔딩...!
쓸때없는 소리는 잠시 내려두고 팀이 현재 가지고 있는 기술 스택은 MS계열(C#, ASP.NET, classic ASP, Razor, etc...)의 스택이므로 백엔드를 자연스럽게 .NET Core로 가기로 하였다. MS가 GitHub을 인수하고, 윈도우에서 WSL로 리눅스를 바로 돌리고, .NET Core를 Linux에서 빌드하고 서비스할 수 있는 세상. 바쁘다 바뻐 현대사회 알쏭달쏭 인터넷 세상.

# 사전 구성

1. 리눅스 배포버전 : CentOS. RHEL의 가호 아래 CentOS를 쓰자.
1. .NET Core 버전 : .NET Core 3.1. 글을 작성하는 2020년 5월 15일 기준 LTS 버전.
1. Nginx : 리버스프록시로 Nginx를 도입한다.



# .Net Core
## 저장소 추가
우선 저장소를 추가한다.
```
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
```

## .NET Core SDK 설치
저장소가 추가되었으므로 SDK를 우선 설치한다. 
```sh
sudo yum install dotnet-sdk-3.1
```

## ASP.NET Core 런타임 설치
SDK가 설치되었으면 ASP.NET Core 런타임을 설치한다.
```sh
sudo yum install aspnetcore-runtime-3.1
```

## .NET Core 런타임 설치
.NET Core 런타임도 함께 설치한다. 차이점이 뭐지?
```sh
sudo yum install aspnetcore-runtime-3.1
```

## 방화벽 오픈
테스트 프로그램에서는 웹서버(Nginx)와 애플리케이션 서버를 동일 서버에 설치한다. 각 프로그램에서 서비스를 위해 공개되어야 하는 포트를 개방해야 하는데 개방해야 하는 포트 목록은 다음과 같다.

- Nginx : HTTP(80), HTTPS(443)
- .NetCore(Kestrel) : 8080

웹 서비스를 담당할 Nginx에서는 HTTP, HTTPS 서비스를 처리하며, 애플리케이션 처리를 담당할 Kestrel에서는 유저가 정의한 포트를 오픈하도록 하자. Kestrel은 .NetCore에 탑재된 작업 웹서버이며, 여기서는 8080포트를 사용하도록 하자. 기본 포트는 5000이다.
포트와 서버 구성에 따라 분리하여 룰은 변경하면 된다.

```sh 
#/etc/firewalld/zones/public.xml에 오픈할 포트 추가
vim /etc/firewalld/zones/public.xml
...
<port protocol="tcp" port="80">
<port protocol="tcp" port="443">
<port protocol="tcp" port="8080">
...

#방화벽 룰 수정 후 reload
firewall-cmd --reload

```

# 프로젝트 생성 및 실행
## 프로젝트 생성(new)(테스트할 프로젝트가 있으면 넘어가기)
기능 수행을 위한 테스트 프로젝트를 생성한다. .NetCore에서는 각 프로젝트의 템플릿을 생성하는 **new**라는 명령을 가지고 있다. 여러 **웹** 프로젝트 중 익숙한 템플릿을 사용하면 되며 이 글에서는 **mvc**프로젝트를 선택하기로 한다.

```sh
dotnet new mvc
```

참고로 dotnet new를 입력하면 생성가능한 템플릿의 목록이 나온다.

![alt text](/static/assets/20200515/dotnet-new.png "dotnet new로 만들 수 있는 템플릿들")

## 프로젝트 게시(publish)
실제 프로젝트를 게시하기 위해서는 **publish**라는 명령을 사용한다. 프로젝트의 게시를 위한 dll 빌드 및 정적 파일을 지정된 경로에 생성하는 명령이다. 릴리즈 게시는 다음과 같이 수행할 수 있다.

```sh
dotnet publish --configuration Release
```


주요 기본 옵션에 대한 코멘트를 추가해 보자면
- debug/release : publish의 기본 build 옵션은 debug이다. release용으로 생성하려면 **--configuration Release** 옵션을 추가하도록 하자.
- build : 기본 옵션으로 프로젝트를 신규 빌드하는데, **--no-build**옵션을 걸어 build하지 않고 게시파일만 생성할 수 있다.
  (일반적인 경우라면 프로덕트 서버에서 직접 빌드 및 게시를 진행할 일은 없겠지만...)
![alt text](/static/assets/20200515/build_nobuild.png "--no-build 옵션 설정에 따른 빌드 파일")


## 프로젝트 실행(run)
dotnet run을 이용하여 게시된 앱을 실행하고, 웹 브라우저로 접속해보자.
방화벽을 열어두었으므로 개발PC 밖에서도 잘 접속되야 된다.


```sh
dotnet run bin/Release/netcoreapp3.1/publish #dotnet run으로 경로를 입력하여 실행
or
bin/Release/netcoreapp3.1/publish/testapp #실행파일 바로 실행
```
![alt text](/static/assets/20200515/welcome.png "Welcome")

애플리케이션이 잘 동작하는 것을 확인하였으니 리버스 프록시를 설정하자.


# Nginx
## 개요
Kestrel은 API 서버 등 로직 서버로 충분한 기능을 제공하지만 웹서버만큼 다양한 기능을 제공하지 않는다(캐싱, 정적 컨텐츠 지원, 압축 등). 이를 위해 리버스 프록시(Reverse Proxy, 역방향 프록시)를 앞에 두고 필요한 요청만 Kestrel로 던지도록 구성하자.

## 설치
저장소를 추가하고 설치하면 된다. 물론 root권한이 필요하다.
저장소 추가는 아래오 같이 진행한다.

```sh
$ vim /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```

저장소 추가 후 메인 라인(nginx-mainline)을 기본 저장소로 잡고 설치를 진행한다.
설치가 완료되면 service를 enable시켜서 부팅되면 켜지도록 만들어 둔다.

```sh 
sudo yum-config-manager --enable nginx-mainline #저장소를 설정하고
sudo yum install nginx                          #nginx 설치 후,
sudo systemctl enable nginx.service             #서비스로 등록하고
sudo systemctl start nginx.service              #실행한다.
```
실행 후 웹 사이트에 접속보면 기본 인덱스 페이지가 잘 출력된다.

[!alt text](/static/asset/20200515/welcome_nginx.png "Welcome to nginx!")

## Nginx 설정
Nginx를 웹서버로 사용하면서 역방향 프록시를 이용하려면 다음과 같은 설정을 하여야 한다.

```sh
$ vim /etc/nginx/conf.d/default.conf
# 다음과 같이 수정하자.
server {
    listen        80;
    server_name   localhost *.localhost;
    location / {
        proxy_pass         http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
$ sudo systemctl restart nginx
```
X-Forwarded시리즈는 .NetCore관점에서 클라이언트의 진짜 요청 파악하기 위한 산업표준 헤더이다. 클라이언트가 웹으로 접속하면 리버스 프록시가 해당 요청을 웹 애플리케이션으로 던지게 되는데, 애플리케이션 서버에서 클라이언트 IP를 가져와보면 바로 직전의 노드인 리버스 프록시의 IP를 가져오게 된다. 이를 방지하기 위하여, 즉 진짜 클라이언트 아이피를 백단에서 확인하기 위하여 아이피를 **X-Forwarded-For**에 넣어둔다. 리버스 프록시와 와스 사이 통신은 HTTPS 요청을 오프로딩을 해서 평문으로 던지게 되므로, 원래 프로토콜도 **X-Forwarded-Proto**에 넣어둔다.

설정 후 HTTP로 접근해보면 nginx 웰컴페이지가 아니라 .netcore 웰컴페이지가 출력되는 것을 확인할 수 있다.

![alt text](/static/assets/20200515/welcome.png "Welcome")

## .Net Core에서 X-Forwarded-헤더 사용
http 헤더에 넣었다고 바로 값을 땡겨올 수 있는 것은 아니다. .Net Core에서는 이를 처리하기 위한 미들웨어를 제공하는데 Startup.cs(MVC 템플릿 기준)에 다음 코드를 추가하자. 

```C#
using Microsoft.AspNetCore.HttpOverrides;   
...

public void Configure(IApplicationBuilder app, IHostingEnvironment env)
{
    app.UseForwardedHeaders(new ForwardedHeadersOptions{
        ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
    });
}
```

## 만일 안된다면!
뭔가 안된다면 selinux 관련 이슈일 확률이 높다. nginx 쪽 에러 로그를 우션 살펴보자.

```sh
$ vim /var/log/nginx/error.log
```

Nginx 에러로그에 아래와 같이 권한이 없다는 로그가 확인될 수도 있다.

![alt text](/static/assets/20200515/nginx_permissiondenied.png "Nginx connect() permission denied")

위 로그는 connect()에서 localhost:8080(.NetCore)으로 연결을 할 권한이 없다는 것이다. 리눅스는 보안 이슈로 웹 통신을 연결하지 못하도록 기본 세팅이 되어 있는데 해당 설정을 SELinux에서 담당한다. 다음과 같이 설정하여 httpd에서 네트워크 커낵트가 가능하도록 수정하자.

```sh
$ setsebool -P httpd_can_network_connect 1
```

위 명령을 수행 후 재접속을 해보면 정상 동작하는 것을 확인할 수 있다.


# 애플리케이션 서비스 관리
## 서비스 추가
.NetCore로 개발된 프로그램을 서비스로 등록해두자. 등록해두지 않으면 시스템을 리셋할 때마다 손으로 다시 실행해야 한다.
서비스 파일을 추가하고, enable 한 뒤 상태를 확인해보자
```sh
$ sudo vim /etc/systemd/system/dotnet-first.service

[Unit]
Description=Dotnet First Example

[Service]
WorkingDirectory=/var/www/helloapp                          # 워킹 디렉토리 = .NetCore 앱 배포 폴더
ExecStart=/usr/bin/dotnet /var/www/helloapp/testapp.dll     # 서비스 실행 명령. 
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=hello-dotnet-first
User=www-data                                               # 프로그램 수행 유저
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target

```

위와 같이 서비스를 등록하고 서비스를 돌리기 위해서 서비스를 수행할 유저를 생성하여야 한다. 해당 유저는 애플리케이션 실행을 위한 유저이므로 쉘 접속 권한을 빼고 생성한다. 귀찮다고 루트로는 절대 돌리지 말고 별도 유저를 추가하자!

```sh
useradd --shell /sbin/nologin www-data
```

실행을 위한 유저까지 정상 등록을 하였으면 서비스를 등록하고 실행한다. 
정상 수행되고 있는지 확인까지 해보자.

```
$ sudo systemctl enable dotnet-first
$ sudo systemctl start dotnet-first
$ sudo systemctl status dotnet-first
```

해당 서비스의 **Active** 상태가 **active (runniung)**이면 정상 동작하고 있는 것이다.

![alt text](/static/assets/20200515/dotnet-service-status.png "서비스 등록 후 상태 체크")





# 결론 : 추가로 공부해볼 것들
.Net Core프로젝트를 위한 .Net Core설정과 Nginx를 이용한 리버스 프록시 설정 방법을 알아보았다. 
서비스를 정상적으로 운영하기 위하여 로깅과 HTTPS 설정에 대해 알아보도록 하자.



# 참조
1. Nginx를 사용하여 Linux에서 ASP.NET Core 호스트 : https://docs.microsoft.com/ko-kr/aspnet/core/host-and-deploy/linux-Nginx?view=aspnetcore-3.1
1. CentOS 7 패키지 관리자 - .NET Core 설치: https://docs.microsoft.com/ko-kr/dotnet/core/install/linux-package-manager-centos7
1. RHEL/CentOS 7 에서 방화벽(firewalld) 설정하기 - https://www.lesstif.com/system-admin/rhel-centos-7-firewalld-22053128.html
1. dotnet new - https://docs.microsoft.com/ko-kr/dotnet/core/tools/dotnet-new
1. dotnet publish - https://docs.microsoft.com/ko-kr/dotnet/core/tools/dotnet-publish
1. dotnet build - https://docs.microsoft.com/ko-kr/dotnet/core/tools/dotnet-build
1. https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-plus/#installing-nginx-plus-on-amazon-linux-centos-oracle-linux-and-rhel - https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-plus/#installing-nginx-plus-on-amazon-linux-centos-oracle-linux-and-rhel
1. (13: Permission denied) while connecting to upstream:[nginx] - https://stackoverflow.com/questions/23948527/13-permission-denied-while-connecting-to-upstreamnginx