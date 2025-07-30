---
title: "Unity 언데드 서바이벌 포트폴리오"
author: "Jay645"
date: "2025-07-30"
summary: "Unity 언데드 서바이벌 포트폴리오 입니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["portfolio", "unity"]
showTags: false
hideBackToTop: false
---

[![](/images/undead-servivor-image.png)](/images/undead-servivor-video.mp4)

> 안녕하세요 Unity 캐주얼 게임 Undead Servivor입니다.

> 기술 스택: Unity, C#, Git

## 소개

Undead Survivor는 Unity 기반으로 개발한 탑다운 형식의 서바이벌 캐주얼 게임입니다.
플레이어는 몰려오는 언데드 무리 속에서 다양한 무기를 조합하고 강화하여 최대한 오래 생존하는 것을 목표로 합니다.

이 프로젝트는 Object Pooling, ScriptableObject 기반 데이터 구조화, 랜덤 스폰 알고리즘, UI 동기화, 무기 레벨 업 시스템 등 게임 개발의 핵심 시스템을 구현했습니다.

## 기능

### 무기 시스템
- Melee / Range 타입 무기 구분
- ScriptableObject 기반의 무기 데이터(ItemData)를 통해 다양한 무기를 유연하게 생성/관리
- 레벨업 시 데미지 및 발사 개수 증가, MaxCount 제한 로직 포함

### 적 타겟팅 및 발사 로직
- 가장 가까운 적을 `Scanner.nearestTarget`으로 추적 (RayCasting 기반)
- 일정 주기로 타겟 방향으로 투사체 발사 (직선 방향 기반)
- Bullet은 충돌 시 Per(관통 수) 소모 및 제거 처리

### 스폰 시스템
- 원형(Random Circle) 기반 스폰 알고리즘 구현
- 플레이어 주변 반지름 내에서 적이 균일하게 스폰되도록 설계
- `Spawner.SpawnEnemy()` 메서드에서 Object Pooling 적용

### 오브젝트 풀링
- Bullet, Enemy, Effect 등 반복 생성 오브젝트에 풀링 적용
- `PoolManager.GetObject(prefabId)`로 재사용
- 성능 최적화 및 메모리 할당 최소화

### 아이템 및 강화 시스템
- 무기 / 장비 / 힐 아이템 구분 및 레벨별 효과 적용
- 버튼 클릭 시 `Item.OnClick()`을 통해 무기/장비 생성 또는 강화
- `ItemData` 기반의 설명과 아이콘 표시

### UI 시스템
- 무기/아이템 이름, 설명, 레벨 등을 실시간으로 UI 반영
- `Awake`, `OnEnable`, `LateUpdate`에서 UI 생명주기 조절

### 플레이어 이동 및 조작
- `PlayerMovement.cs`에서 Input 기반 이동 구현
- Rigidbody2D 물리 기반의 부드러운 이동 처리
- 회피나 넉백 등 확장을 고려한 구조 설계

## 이슈

### Object Pooling

- 이슈: Instantiate/Destroy 반복으로 인한 GC 발생 및 프레임 드랍.

- 해결: PoolManager를 구현하여 재사용 가능한 구조를 만들고, 각 무기 및 적 오브젝트의 활성화/비활성화로 처리.

- 성과: 프레임 안정성 확보. 손쉬운 개체 관리

### Spawner 생성 알고리즘

- 이슈: Point 배열 기반 랜덤 스폰은 확장성과 유지 보수성이 떨어짐.

- 해결: GetRandomPointOnCircle 함수 도입으로 원형 반경 내 균등 분포 스폰 구현 (원주 기반 랜덤).

- 성과: 코드 간결화, 동적 레벨 디자인 가능성 확보. 유지 보수성 증가

### Weapon/Item 구조화 (ScriptableObject + Component 기반)

- 이슈: 무기와 아이템 업그레이드 구조가 하드코딩되어 확장 어려움.

- 해결: ItemData ScriptableObject 도입 → 데이터 기반 설계. Weapon과 Gear 클래스가 이를 기반으로 동작.

- 성과: 신규 아이템 추가 시 코드 수정 최소화. 레벨 업 기능과 UI 연동 용이.

### UI/UX 디버깅

- 이슈: 아이템 레벨 UI 미갱신 문제, null 예외 발생.

- 해결: OnEnable 시점에서 UI 갱신 및 null 체크 강화. 버튼 비활성화 타이밍 명확히 분리.

- 성과: 사용자 경험 안정화, UI 동기화 정확도 개선.

## 회고

이번 프로젝트는 Unity를 활용해 처음으로 게임을 제작해본 경험이었습니다.

Bullet이나 Weapon 시스템에서 Rigidbody 누락, Count 미반영, UI 비동기 업데이트 문제 등 다양한 버그를 겪었고, 이를 통해 Unity의 생명주기 함수들(Awake, Start, OnEnable)의 차이를 이해하게 되었습니다.

또한 ScriptableObject를 통해 데이터 중심 개발 방식의 장점을 체감했고, Object Pooling을 직접 구현하면서 Unity의 메모리 관리에 대한 실질적인 감각도 익힐 수 있었습니다.

게임을 확장한다면 더 체계화된 구조로 더 발전하고 싶은 생각이 들었습니다. 예를 들어 각 개체의 인덱스 기반의 관리에서 열거형을 통해 더 직관적인 이름으로 실수를 줄이는 방법처럼 버그를 발생시키더라도 빠르게 문제점을 찾아내기 좋은 구조에 대해서 고민하게 되었습니다.
전반적으로 작은 규모라도 `제대로 게임을 혼자서 끝까지 만든 경험`이 게임 개발자로서의 자신감을 높이는 계기가 되었습니다.