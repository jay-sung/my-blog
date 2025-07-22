---
title: "C++ Memory Management (3) - Memory resources"
author: "Jay645"
date: "2025-07-22"
summary: "`Allocator`는 대부분에 경우에는 기본으로 제공하는 `Allocator`를 사용하는 것이 일반적입니다. 하지만 정교하게 표준 컨테이너들의 메모리 관리를 제어해야하는 경우 사용자가 직접 지정할 수 있게 해줍니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["cpp", "cpp-memory-management"]
showTags: false
hideBackToTop: false
---

> `C++ Memory Management (2) - Allocator` 부분을 읽고 오시면 더 이해하기 좋습니다.

필요 사전 지식: C++, STL Container에 대한 간단한 지식

## 개요

템플릿 기반 `Allocator`로는 런타임에 메모리 전략을 바꾸는 것이 어려워 C++17에서 `Polymorphic Memory Resource (PMR)`이 나왔습니다.

Memory resources는 `Allocator`의 전략 패턴으로 봐도 무방합니다. `memory_resouce` 추상 클래스를 상속 받아 런타임에 메모리 할당 전략을 유연하게 수정할 수 있습니다.
> 전략 패턴: 개체의 행위를 추상화한 패턴. 이를 통해 개체의 행위를 유연하게 수정 및 변경할 수 있다.

- `Allocator` : 템플릿 기반 컴파일 타임.
- `PMR` : 클래스 기반 런타임.

이렇게 정리 할 수 있으며, `PMR`기반 코드들은 std::pmr 네임스페이스 하위로 구성되어 있습니다.

```cpp
std::pmr::vector<int> v { std::pmr::new_delete_resource() };
```

## memory_resouce

위에서 설명한 `memory_resource`에 대해서 자세하게 살펴보겠습니다. 이 추상 클래스는 다음 세 가지 순수 가상 함수로 구성되어 있습니다.

```cpp
class memory_resource
{
public:
    void* allocate(size_t bytes, size_t alignment = alignof(std::max_align_t));
    void deallocate(void* p, size_t bytes, size_t alignment = alignof(std::max_align_t));
    bool is_equal(const memory_resource& other) const noexcept;

protected:
    virtual void* do_allocate(size_t bytes, size_t alignment) = 0;
    virtual void do_deallocate(void* p, size_t bytes, size_t alignment) = 0;
    virtual bool do_is_equal(const memory_resource& other) const noexcept = 0;
};
```

물론 이 클래스를 직접 사용할 일은 없고, 보통 이를 상속한 다양한 메모리 전략 개체를 통해 사용됩니다.

## 기본 제공 memory_resource

`PMR`에서 제공하는 기본적인 `memory_resource`를 알아보겠습니다.

- `new_delete_resoucrce` : 전통적인 `new` / `delete` 기반 전략입니다. global `opeartor new`/`operator delete`을 통해 할당 및 해제합니다.
- `null_memory_resource` : 메모리 할당이 항상 실패(std::bad_alloc)하는 `memory_resource`입니다. 메모리 할당에 대한 테스트를 위해 사용됩니다.
- `monotonic_buffer_resource` : 해제를 리소스가 소멸될 때 한번에 해제합니다. 임시 개체를 관리할 때 유용합니다.
- `synchronized_pool_resource` : `thread-safe`한 풀 기반 할당입니다.
- `unsynchronized_pool_resource` : `thread-safe`하지 않은 풀 기반 할당입니다.

## get/set resource

이 기본 리소스는 `set_default_resource()`를 통해 변경할 수 있습니다. 변경 시 `전역(static)`으로 적용되며, 이후 생성되는 컨테이너들에 영향을 줍니다.

`std::pmr`에서는 별도의 `memory_resource`를 명시하지 않으면 내부적으로 `get_default_resource()`로 변환되는 리소스를 사용합니다. 이 기본 리소스는 `set_default_resource()`를 통해 변경할 수 있습니다 — `set_default_resource()`와 `get_default_resource`는 `thread-safe`하게 동작합니다. — 

## Custom `memory_resource` 예제

간단한 로깅용 `memory_resource`를 만들어보겠습니다. 이 전략은 할당/해제 시마다 로그를 출력합니다.

```cpp
class LoggingResource : public std::pmr::memory_resource
{
public:
    LoggingResource(std::pmr::memory_resource* upstream = std::pmr::new_delete_resource())
        : m_upstream(upstream) {}

protected:
    void* do_allocate(size_t bytes, size_t alignment) override {
        std::cout << "[alloc] " << bytes << " bytes\n";
        return m_upstream->allocate(bytes, alignment);
    }
    void do_deallocate(void* p, size_t bytes, size_t alignment) override {
        std::cout << "[dealloc] " << bytes << " bytes\n";
        m_upstream->deallocate(p, bytes, alignment);
    }
    bool do_is_equal(const memory_resource& other) const noexcept override {
        return this == &other;
    }

private:
    std::pmr::memory_resource* m_upstream;
};
```

```cpp
LoggingResource logger;
std::pmr::vector<int> v(&logger);
v.push_back(10); // 할당 로그 출력
```

## 정리

그러면 정리해보겠습니다. `PMR`은 다음과 같은 경우에 유용합니다.

- 많은 소규모 할당을 빠르게 처리해야 할 때 (e.g. 게임 프레임 버퍼)
- 메모리 해제를 수동으로 관리하기 어려운 경우
- 특정 영역 안에서만 동작하는 파서, 트랜잭션, 요청 처리 등
- 메모리 추적, 디버깅, 로깅이 필요한 경우

템플릿 기반 `Allocator`는 여전히 대부분의 경우 충분합니다. 하지만 복잡한 메모리 정책이 필요하거나 런타임에 정책을 바꿔야 한다면 `PMR`은 훌륭한 대안이 됩니다.


> 참고 자료: https://cppreference.com/w/cpp/memory.html#Memory_resources