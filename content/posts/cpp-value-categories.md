---
title: "C++ Value Categories"
author: "Jay645"
date: "2025-08-05"
summary: "C++ 값 카테고리에 대해서 알아봅니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["cpp"]
showTags: false
hideBackToTop: false
---

필요 사전 지식: C++

## 개요

C++에서는 표현식의 값 범주(value category)를 정확히 이해하지 않으면 다음과 같은 코드의 의미를 파악하기 어렵습니다.

- `std::move`는 왜 있어야 할까?
- 왜 `int&&`와 `int&` 오버로딩이 다르게 불릴까?
- 템플릿에서 `T&&`는 무엇을 의미할까?

이러한 질문에 답하려면 value category를 정확히 알아야 합니다.

C++에서 값의 범주는 복사, 이동, 참조 여부 등 다양한 동작에 영향을 주며 `perfect forwarding`, `move semantics` 등을 이해 할 때 핵심적인 개념입니다.

## Value Category

```text
              Expression
                 |
               Value
              /     \
        Glvalue     Rvalue
        /     \      /   \
   Lvalue   Xvalue   Prvalue
```

C++의 표현식(Expressions)의 범주는 다음과 같습니다.

### `Glvalue` (Generalized Lvalue)

`Lvalue`와 `Xvalue`를 포함하는 범주입니다.

### `Lvalue` (Locator Value)

이름이 있는 개체로, 메모리에 존재합니다.

### `Xvalue` (eXpiring Value)

더 이상 사용되지 않을 "소유권이 끝나가는" 값입니다. 임시 게체를 의미하며, `std::move`를 통해서 개체의 복사없이 참조하는 경우에 활용됩니다.

### `Rvalue` (Right Value)

`Xvalue`와 `Prvalue`를 포함하는 범주로, 소멸해도 괜찮은 값을 의미합니다. 기본적인 리터럴 값들과 `std::move`한 임시 개체들을 말합니다.

### `Prvalue` (Pure Rvalue)

계산 결과로 나오는 임시 값으로 대부분의 리터럴 값 타입들을 말합니다.

## 예시

```cpp

int x = 10; // Lvalue x에 Prvalue 10을 assign
10 = x;     // ERROR! 리터럴은 Prvalue → 좌변에 올 수 없음

std::string s1 = "hi";              // "hi"는 Prvalue → s1은 Lvalue
std::string s2 = std::move(s1);     // std::move(s1)는 Xvalue → 이동 생성자 호출
```

## 대표적인 규칙들

| 표현식                | Value Category | 설명            |
| ------------------ | -------------- | ------------- |
| `x`                | Lvalue         | 변수는 이름이 있음    |
| `10`               | Prvalue        | 리터럴은 임시 값     |
| `x + y`            | Prvalue        | 계산 결과는 임시 값   |
| `std::move(x)`     | Xvalue         | 이동을 위한 캐스팅    |
| `func()` (값 반환)    | Prvalue        | 값으로 반환한 함수    |
| `func()` (`T&` 반환) | Lvalue         | 참조 반환 함수      |
| `*ptr`             | Lvalue         | 포인터 해제는 주소 있음 |