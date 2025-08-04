---
title: ".NET GC Deep Dive (2) - LOH(Large Object) Heap"
author: "Jay645"
date: "2025-08-04"
summary: ".NET GC에서 LOH가 성능에 미치는 영향에 대해서 알아봅니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["csharp", "dotnet-gc"]
showTags: false
hideBackToTop: false
---

필요 사전 지식: .NET, Windows

> 이전 .NET GC Deep Dive (1) - .NET GC Introduction를 보고 오시는 것을 추천합니다.

> OS 환경은 Windows를 기준으로 설명합니다.

## 개요

개체의 크기가 85,000 바이트보다 크거나 같으면 LOH(Large Object Heap) 개체라고 부릅니다.

## LOH가 성능에 미치는 영향

LOH의 할당은 다음과 같은 부분에서 성능에 영향을 줍니다.

### 할당 비용

CLR은 새 개체를 할당할 때마다 해당 메모리가 초기화되도록 보장합니다. 큰 개체의 할당 비용은 메모리 지우기(GC에 트리거하지 않는 한)에 의해 좌우됩니다.(1바이트에 두 주기가 걸리는 것에 비해 큰 개체는 170,000 주기가 걸림)

### 수집 비용

LOH와 2세대가 함께 수집되기 때문에 하나의 임계값을 초과하면 2세대 컬렉션이 트리거됩니다. 2세대가 LOH보다 큰 경우 많은 큰 개체가 일시적으로 할당되고 GC가 느려질 수 있습니다.

### 참조 형식이 있는 배열 요소인 경우

```csharp
class Node
{
    Data d;
    Node left;
    Node right;
}

Node[] binTree = new Node [num_nodes];
```

`Node[]`는 요소 하나하나가 `Node`라는 참조 타입을 가리킵니다. 그리고 이 `Node` 클래스 안에서 `left`, `right` 같은 또 다른 참조가 들어있습니다. GC는 이 배열을 수집할 때 모든 Node를 순회하며 그 안의 참조를 따라가야 하고, 그로인해 GC 비용이 커집니다.

위 세 가지 요인 중에서 처음 두 가지는 일반적으로 세 번째 요소보다 중요한 문제입니다. 따라서 임시 개체를 할당하는 대신 다시 사용하는 큰 개체 풀을 할당하는 것이 좋습니다.

## LOH 최적화

LOH를 최적화 하기 위해서 제시되는 방법들은 다음과 같습니다.

1. 큰 개체 재사용: 풀링 기법을 통해 재사용하여 LOH의 할당을 줄입니다. (Ex. ArrayPool<T>)
2. 메모리 사용 모니터링 : dotnet-trace, PerfView 등과 같은 도구로 LOH 사용량을 추적합니다.
3. 큰 개체를 나눠 SOH(Small Object Heap)으로 분리하기 : 구조적으로 쪼갤 수 있는 LOH라면 SOH에서 관리되도록 설계. (Ex. 참조형 맴버를 인덱스를 통해서 관리 하도록 분리)


> 자료 : https://learn.microsoft.com/ko-kr/dotnet/standard/garbage-collection/large-object-heap