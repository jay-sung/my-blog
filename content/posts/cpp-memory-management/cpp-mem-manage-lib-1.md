---
title: "C++ Memory Management (1) - Smart Pointer"
author: "Jay645"
date: "2025-07-18"
summary: "C++에서 포인터를 쓰는 경우 웬만하면 `Smart Pointer`를 사용하는 것을 강력하게 권장합니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["cpp", "cpp-memory-management"]
showTags: false
hideBackToTop: false
---

필요 사전 지식: C++, Raw Pointer를 다뤄본 경험

**TL;DR**

> C++에서 포인터를 쓰는 경우 웬만하면 `Smart Pointer`를 사용하는 것을 강력하게 권장합니다.

## 개요

Raw Pointer를 사용하면 `Double-Free`, `Null-Pointer` 등의 문제가 발생할 수 있어 사용에 신중함이 요구되었습니다.

```cpp
// Double-Free 예제

int* ip = new int;
// ... (3천줄 이상의 코드라고 가정)
delete ip;
// ... (2천줄 이상의 코드라고 가정)
delete ip; // 이 한줄로 프로세스는 죽는다.
```

그렇다면 Raw Pointer를 대신할 `Smart Pointer`는 과연 무엇일까요?

## Smart Pointer

`C++11`부터 추가된 `Smart Pointer`는 기존 Raw Pointer 관리에 대한 기능들을 추가한 클래스들을 말합니다.

스마트 포인터는 다음과 같은 클래스들을 말합니다.

```text
- unique_ptr
- shared_ptr
- weak_ptr
- auto_ptr (c++17에서 제거되었고 사용하지 않습니다)
```

### 소유권

`Smart Pointer`의 핵심은 `소유권`입니다. 즉, 포인터를 누가 관리하느냐에 대한 하나의 방법론입니다. 예제를 통해 `Smart Pointer`의 핵심 개념을 설명하겠습니다.

소유권은 자원에 대한 접근을 관리하는 방법론입니다. 이를 통해 모두가 자원에 함부로 접근하지 않고 미리 규명된 방식을 통해서 자원을 관리하는 것이 핵심입니다.

`Smart Pointer`에서 소유권을 활용하는 방식은 다음과 같습니다.

- `unique ownership` : 하나의 개체는 하나의 소유권만 가집니다.
- `shared ownership` : 각각의 개체들은 하나의 같은 소유권을 가집니다.

그러면 차근차근 알아보겠습니다. 저 두가지의 개념을 이해하면 대부분의 `Smart Pointer`를 이해했다고 볼 수 있습니다.

### Unique Ownership (unique_ptr)

> 하나의 개체는 하나의 소유권만 가집니다.

위 문장은 `unique_ptr`의 핵심입니다. `unique_ptr`는 하나의 개체만 소유하다 스코프 바깥으로 나갈 경우에 자동으로 release 됩니다.

```cpp
{
    std::unique_ptr<int> iptr { new int(645) }; // 첫 리소스 획득
} // 범위를 벗어나면 해제
```

`unique_ptr`에 포인터를 다른 곳으로 옮기면 기존 `unique_ptr`는 해당 포인터 접근할 수 없습니다 — 리소스의 소유권은 하나만 존재 —. 

포인터는 `Deleter`를 따로 설정하지 않았다면 스코프 바깥으로 나갈 경우 자동으로 release 됩니다. 
> 여기서 `Deleter`는 `unique_ptr`의 두 번째 인자로 설정한 타입을 의미하며 기본적으로 `default_deleter`로 설정되어 있습니다. 자신이 직접 `Deleter`를 설정하여 스코프 바깥으로 나갈 경우 호출되는 함수를 정의할 수도 있습니다. 보통 특수한 소멸자가 필요한 경우에 활용됩니다 (Linked List, Tree Structure 등)

#### Ownership Transfer

> `Move Semantics(이동 시멘틱)`에 대해서 간단히 설명하겠습니다. C++에서 임시 개체 값은 rvalue로 분류됩니다. std::move는 일반 값을 rvalue로 전달하는 캐스팅 함수입니다 — 여기선 xvalue로 전달하는 목적이지만 크게는 중요하지 않습니다 —.

`unique_ptr`를 다른 곳으로 전달하려면 `std::move`를 사용하여 소유권을 전달합니다.

```cpp
void foo(std::unique_ptr<int> param) // 소유권 획득
{

} // 이 스코프를 벗어나면 해제된다.

int main()
{
    std::unique_ptr<int> iptr { new int(645) };
    foo(std::move(iptr)); // 소유권 이동
    // iptr의 소유권은 없어짐
} // iptr의 소유권이 없으므로 해제하지 않는다.
```

위 코드는 `foo` 함수의 인자로 `iptr`의 소유권을 이동하고 `foo` 함수의 스코프를 넘어서면 해당 포인터가 해제되는 코드입니다.

그 다음으로 `Shared Ownership`에 대해서 알아보겠습니다.

### Shared Ownership (shared_ptr)

> 각각의 개체들은 하나의 같은 소유권을 가집니다.

`shared_ptr`는 참조 카운팅(reference counting)을 기반으로 동작합니다. 즉, 몇 개의 `shared_ptr` 인스턴스가 동일한 리소스를 참조하고 있는지를 내부적으로 추적합니다.

```cpp

void foo(std::shared_ptr<int> ptr)
{
    // 함수 내용
}

int main()
{
    std::shared_ptr<int> sp1 { new int(645) }; // use_count = 1
    std::shared_ptr<int> sp2 = sp1; // use_count = 2
    foo(sp1); // use_count = 3
}
```

`shared_ptr`는 `use_count`를 통해서 참조 횟수를 측정합니다. 다른 개체가 참조하면 `use_count`의 횟수가 증가하고 — 이때 증감 연산은 atomic하게 동작합니다 — 해당 참조 개체가 해제되면 `use_count` 횟수가 감소합니다.
- `use_count`가 만약 0이면 해당 포인터는 비어있고 관리되지 않는 개체로 간주되며  자동으로 해제됩니다.
- `use_count`가 만약 1이면 해당 포인터는 다른 개체에 참조되지 않는 개체로 간주합니다.

하지만 이때 한가지 문제가 발생합니다. 바로 `순환참조(Cyclic Reference)` 문제입니다. 이는 개체 서로가 서로를 참조하여 영원히 메모리를 해제하지 못하는 상황을 의미합니다.

```cpp
struct B;

struct A {
    std::shared_ptr<B> b_ptr;
};

struct B {
    std::shared_ptr<A> a_ptr;
};

int main() {
    auto a = std::make_shared<A>();
    auto b = std::make_shared<B>();
    a->b_ptr = b;
    b->a_ptr = a;
}
```

![](/images/shared-ptr-circlic-exapmle-code.jpg)

> 서로를 참조하여 메모리를 해제하지 못한다.

이 문제를 해결하기 위해서 나온 `Smart Pointer`가 `weak_ptr`입니다.

### weak_ptr

`weak_ptr`는 `shared_ptr`의 순환참조(Cyclic Reference)를 해결하기 위한 `Smart Pointer`입니다. `weak_ptr`로 참조한 개체는 `use_count`에 영향을 주지 않으며 `lock()` 메서드를 통해 `shared_ptr`로 바꿔서 사용해야 합니다.

```cpp
std::shared_ptr<int> sp = std::make_shared<int>(645);
std::weak_ptr<int> wp = sp;

if (auto temp = wp.lock()) {
    std::cout << *temp << std::endl; // sp가 살아있다면 사용 가능
} else {
    std::cout << "Object expired\n";
}
```

## 정리

지금까지 `Smart Pointer`에 대해서 알아보았습니다. 알아본 `Smart Pointer`에 대한 정보를 요약하면 다음과 같습니다.

- `unique_ptr` : 단 하나의 소유권만 필요할 때 유용합니다
- `shared_ptr` : 여러 개체에 공유해야 할 때 유용합니다.
- `weak_ptr` : `shared_ptr`에서 발생하는 순환참조를 해결해야 할 때 사용합니다.

`Raw Poiner`의 문제점을 해결하고 싶을 때 `Smart Pointer`는 꽤 휼륭한 선택지로 권장드립니다.