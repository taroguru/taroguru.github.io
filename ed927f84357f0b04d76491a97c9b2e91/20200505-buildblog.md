---
title: "Gatsby로 블로그 만들어 Github Pages에 배포하기"
cover: "sunset-2173918_1920.jpg"
date: "2020-05-05"
path: "blog-with-gatsby"
category: "tech"
tags:
    - gatsby
    - blog
    - deploy
    - github pages
---


Gatsby로 블로그를 만들어 배포하기
===================================
다음과 같다.

1. npm, yarn, Gatsby 설치
1. 스타터로 기본 틀 잡기
1. 플러그인
1. 마크다운으로 글 생성
1. 빌드
1. 배포

# 플러그인
## Disqus
## Google Analytics

# 배포
Github Pages에 바로 파일을 배포할 수 있는 라이브러리가 있다. 
배포 순서는 다음과 같다.
1. gh-pages설치
1. packages.json에 deploy 스크립트 추가
1. yarn run deploy 배포 스크립트 수행
1. netlify와 github pages에 같이 배포하는 것이 의미가 있을까?

개발 저장소와 운영/배포 저장소를 별도로 관리해야 할 필요가 잇을 것 같아서 아래와 같이 설정하였다.

- 개발 저장소 : https://github.com/taroguru/blog
- 운영 저장소 : https://github.com/taroguru/taroguru.github.io
- 운영 페이지 : https://taroguru.github.com
- 글 작성 및 배포 스크립트 : 블로그로 글을 작성할 때 gatsby develop을 걸어두고 md파일을 작성/수정한 후 빌드 및 배포를 한번에 진행하려고 deploy에 빌드 소스를 같이 포함시켰다.

```javascript
"scripts": {
    ...
    "deploy": "gatsby build && gh-pages -d public -b master --repo https://github.com/taroguru/taroguru.github.io",
    ...
  },
```

(공부가 더 필요한 부분)Github Pages의 경우 저장소의 루트 인덱스 파일(/index.html)을 바로 웹서비스하는 느낌으로 착각하고 있었는데 사실 저장소를 바로 웹서비스하는건 말이 안되는 구조기는 하다. 훅을 걸어 push가 들어오면 Pages쪽으로 파일을 자동 배포하는 방식인 듯. gh-pages로 파일을 올려도 저장소에 커밋이 남긴 하는데 정적 페이지쪽이 먼저 변경 반영이 되고 저장소에 반영되는것같기도하고... 

# 참조

- 배포 : https://musma.github.io/2019/08/09/gatsby-js.html
- GitHub Pages : gh-pages 패키지로 무료 웹 호스팅하기 : https://velog.io/@gwak2837/GitHub-Pages-gh-pages%EB%A1%9C-%EB%AC%B4%EB%A3%8C-%EC%9B%B9-%ED%98%B8%EC%8A%A4%ED%8C%85%ED%95%98%EA%B8%B0
- gh-pages에서 remote repository 배포 설정 : 
https://github.com/tschaub/gh-pages/issues/290
- https://medium.com/swlh/deploying-react-apps-to-github-pages-on-master-branch-creating-a-user-site-bc96c2a37dc8