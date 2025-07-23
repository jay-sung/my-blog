---
title: "C++ Memory Management (4) - C++ Memory helper class"
author: "Jay645"
date: "2025-07-22"
summary: "C++에서 제공하는 Memory helper class에 대해서 알아봅니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["cpp", "cpp-memory-management"]
showTags: false
hideBackToTop: false
---

필요 사전 지식: C++, Smart Pointer

## 개요

오늘 알아볼 Memory helper class는 정말 특수한 경우에만 활용되는 클래스입니다. 그래서 교양 느낌으로 읽으시면 좋을 거 같습니다.

## `owner_less`(C++11), `owner_hash`(C++26), `owner_equal`(C++26)

`owner_less`, `owner_hash`, `owner_equal`이 세 helper class는 `shared_ptr`와 `weak_ptr`를 사용할 때 `std::set` 혹은 `std::map`의 키를 소유 기반으로 비교하기 위해 사용됩니다.

기본적으로 `shared_ptr`와 `weak_ptr`는 포인터 주소 기반으로 비교됩니다. 하지만 소유자를 기반으로 비교하고 싶다면 그때 사용됩니다. 그러면 각각의 클래스들을 비교해보겠습니다.

- `owner_less`(C++11) : std::map, std::set 등 정렬 기반 컨테이너의 비교 함수로 사용
- `owner_hash`(C++26) : std::unordered_map, std::unordered_set 등 해시 기반 컨테이너에서 키 해시용
- `owner_equal`(C++26) : 위 해시 컨테이너에서 key_equal에 사용

```cpp
using K = std::shared_ptr<MyClass>;
using V = std::owner_less<std::shared_ptr<MyClass>;
std::set<K, V> mySet;
```

```cpp
using K = std::shared_ptr<MyClass>;
using V = std::owner_hash<std::shared_ptr<MyClass>;
std::unordered_set<K, V> mySet;
```

## `enable_shared_from_this` (C++11)

`enable_shared_from_this`은 자기 자신을 가리키는 `shared_ptr`를 생성할 수 있게 해주는 베이스 클래스입니다. 이를 통해 안전하게 `shared_ptr`의 자기 자신의 포인터를 호출할 수 있게 됩니다.

```cpp
struct MyClass : std::enable_shared_from_this<MyClass> {
    std::shared_ptr<MyClass> getPtr() {
        return shared_from_this(); // 자신을 shared_ptr로 반환
    }
};
```

### 만약 `enable_shared_from_this` 없이 자기 자신의 this를 참조하면 어떻게 되나요?

결론부터 말하면 이중 소유자가 생길 수 있습니다.

```cpp
struct MyClass {
    std::shared_ptr<MyClass> getShared() {
        return std::shared_ptr<MyClass>(this);  // <-- 위험!
    }
};
```

위에서 `std::shared_ptr<MyClass>(this)` 코드를 호출하면 우리가 원하는 기존 소유자의 `shared_ptr`가 반환되기를 바라지만 마치 생성자 함수처럼 젼혀 새로운 소유자가 만들어집니다. 이러면 두 개의 `shared_ptr`가 소유되며 `double-free` 혹은 `free invalid pointer` 될 수도 있습니다.

```cpp
#include <memory>

struct MyClass {
    std::shared_ptr<MyClass> getShared() {
        return std::shared_ptr<MyClass>(this);  // <-- 위험!
    }
};

int main()
{
    MyClass myObj;
    auto shared = myObj.getShared(); // 여기서 이상한 동작을 함. 같은 포인터를 둘 다 소유하게 됨.
    return 0;
} // <-- 결국 이미 free된 포인터를 또 free하게 되고 프로그램은 죽어버립니다.
```

```
malloc: *** error for object 0x16fbfb4bb: pointer being freed was not allocated
malloc: *** set a breakpoint in malloc_error_break to debug
```

이렇게 죽어버립니다. 엉뚱한 포인터를 free 해버려 죽어버리는거죠.

## `bad_weak_ptr` (C++11)

`bad_weak_ptr`는 `weak_ptr`가 참조한 개체가 소멸된 상태에서 `lock()`등을 호출할 때 던져질 때 예외입니다. 참고로 `std::exception`의 파생 클래스입니다.

```cpp
std::weak_ptr<int> wp;
try {
    std::shared_ptr<int> sp = wp.lock();
    if (!sp) throw std::bad_weak_ptr(); // 또는 lock() 없이 직접 생성 시 예외 발생
} catch (const std::bad_weak_ptr& e) {
    std::cerr << "Invalid weak_ptr!" << std::endl;
}
```

## `default_delete` (C++11)

`unique_ptr`가 개체를 소멸할 때 기본으로 사용하는 삭제자(Deleter)입니다. `unique_ptr`의 Deleter를 만들고 싶을 때 사용합니다.

```cpp
auto deleter = [](FILE* f) { if (f) fclose(f); };
std::unique_ptr<FILE, decltype(deleter)> file(fopen("data.txt", "r"), deleter);
```

물론 `default_delete`를 거의 쓸 일은 없습니다.

> 참고: https://cppreference.com/w/cpp/memory.html