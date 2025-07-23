---
title: "C++ Memory Management (2) - Allocator"
author: "Jay645"
date: "2025-07-21"
summary: "`Allocator`는 대부분에 경우에는 기본으로 제공하는 `Allocator`를 사용하는 것이 일반적입니다. 하지만 정교하게 표준 컨테이너들의 메모리 관리를 제어해야하는 경우 사용자가 직접 지정할 수 있게 해줍니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["cpp", "cpp-memory-management"]
showTags: false
hideBackToTop: false
---

필요 사전 지식: C++, STL Container에 대한 간단한 지식

## 개요

`Allocator`란 메모리 관리(할당, 해제, 생성, 소멸)을 위한 캡슐화 전략 개체입니다. 모든 표준 라이브러리 컴포넌트들의 메모리 관리는 `Allocator`를 통해서 이뤄집니다.

`Allocator`는 대부분에 경우에는 기본으로 제공하는 `Allocator`를 사용하는 것이 일반적입니다. 하지만 정교하게 표준 컨테이너들의 메모리 관리를 제어해야하는 경우 사용자가 직접 지정할 수 있게 해줍니다.

## Allocator의 동작 방식

`Allocator`는 다음과 같은 네 가지 책임을 갖습니다.
1. 메모리 할당 (`allocate`)
2. 메모리 해제 (`deallocate`)

그외.
- 개체 생성 (`construct`) C++20에서 제거되었습니다..
- 개체 파괴 (`destroy`) C++20까지 제거되었습니다.

```cpp
template <typename T>
struct MyAllocator {
    using value_type = T;

    T* allocate(std::size_t n);
    void deallocate(T* p, std::size_t n);
};
```
> 기본적인 인터페이스 구조입니다. `value_type`을 명시적으로 선언해야 합니다.

```cpp
std::vector<int, std::allocator<int>> vec;
```
> `vector`의 `allocator`를 명시하려면 두번째 템플릿 인자에 명시하면 됩니다.

```cpp
#include <cstdlib>
#include <memory>
#include <vector>

template <typename T>
class MallocAllocator {
public:
    using value_type = T;

    MallocAllocator() = default;

    T* allocate(std::size_t n) {
        if (auto ptr = static_cast<T*>(std::malloc(n * sizeof(T)))) {
            return ptr;
        }
        throw std::bad_alloc();
    }

    void deallocate(T* ptr, std::size_t) {
        std::free(ptr);
    }
};

template<typename T>
using MallocVector = std::vector<T, MallocAllocator<T>>;
```
> 간단한 `malloc` 기반 `Allocator` 예제입니다.

## allocator_traits

`allocator_traits`는 맴버 함수들을 보완해주는 `중간 인터페이스 레이어`입니다. 이를 통해 다양한 `allocator` 버전에 대응할 수 있는 유연한 구조를 제공합니다.

```cpp
template<typename T, typename Alloc = std::allocator<T>>
class MyContainer {
    Alloc alloc;
public:
    void foo() {
        T* p = std::allocator_traits<Alloc>::allocate(alloc, 1);
    }
};
```
> `allocator`의 `allocate()` 대신 `std::allocator_traits<Alloc>::allocate()`를 호출하게 됩니다.

## rebind

`rebind`는 `Allocator`가 원래 타입이 아닌 다른 타입에 대해서도 동작할 수 있도록 만드는 구조입니다. 

테이너는 내부 하나의 타입만 사용하는 게 아니라, 노드, 링크드 리스트 등 다양한 내부 타입에 대해 메모리를 할당해야 합니다. 하지만 `std::allocator<T>`는 오직 `T`만 다룰 수 있고 그래서 `U`에 대해 재정의된 할당자가 필요하고, 그걸 만들어주는 게 `rebind<U>::other`입니다.

```cpp
template<typename T>
struct MyAllocator {
    using value_type = T;

    template<typename U>
    struct rebind {
        using other = MyAllocator<U>;
    };
};
```
> 위와 같은 정의가 있을 때

```cpp
typename MyAllocator<int>::rebind<double>::other
```
> MyAllocator<int>는 자동으로 MyAllocator<double> 타입이 됩니다.

`rebind`는 STL 내부에서 다양한 타입의 메모리를 할당해야 할 때 적절한 타입의 할당자를 꺼내 사용합니다.

기존(C++20이전)에는 `rebind`를 직접 정의해야 했지만, `allocator_traits`을 통해 `rebind`를 정의합니다. `allocator_traits`의 `rebind` 템플릿 별칭 맴버는 다음과 같습니다.

- `rebind_alloc<T>` : 컨테이너 내부에서 `Node`, `T`, `Pair<K, V>` 등 다른 타입 할당자가 필요할 때 사용합니다.
- `rebind_traits<T>` : 라이브러리 구현자가 traits 연산을 반복적으로 쓰고 싶을 때 상요합니다. (`std::allocator_traits<rebind_alloc<T>>`)

`Allocator`에 대한 더 많은 내용들은 `Memory resources`에서 더 알아보겠습니다.

> 참고 자료: https://cppreference.com/w/cpp/memory.html#Memory_resources