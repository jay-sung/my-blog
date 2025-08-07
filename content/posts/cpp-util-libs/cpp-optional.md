---
title: "C++ Utilities library (1) - optional"
author: "Jay645"
date: "2025-08-06"
summary: "Optional을 통해 값이 존재할 수도, 존재할 수도 있음을 표현할 수 있습니다."
toc: true
readTime: true
autonumber: true
math: false
tags: ["cpp"]
showTags: false
hideBackToTop: false
---

필요 사전 지식: C++

## optional

C++17에서 새롭게 추가된 `std::optional`은 값의 유무를 더욱 명시적으로 표현할 수 있어 유용하게 활용될 수 있습니다.

`optional`은 `operator*()`, `operator->()`, `value()`, 또는 `value_or()`을 통해 안전하게 값에 접근합니다.

- `value()` : 값을 반환하며, 값이 없다면 `std::bad_optional_access` 예외를 발생시킵니다.
- `value_or(default)` : 값을 반환하며, 만약 값이 없다면 지정한 기본값으로 반환합니다.

### 생성 및 초기화

기본적으로 `optional`은 값이 없는 상태입니다. 직접 값 또는 다른 `optional`로 초기화할 수 있으며, `std::nullopt`으로도 명시적으로 설정할 수도 있습니다.

유틸리티 함수 `std::make_optional(...)`을 통해서 `T` 인자를 통해 직접 `optional<T>`를 생성 할 수도 있습니다.

```cpp
auto opt_value = std::make_optional<int>(10);
```

### Modifiers

`optional`을 유용하게 활용할 수 있는 수정자들을 소개합니다.

- `reset()` : 포함된 값을 제거하여 empty 상태로 전환.
- `swap()` : 두 `optional` 간 내용 교환.
- `emplace()` : in-place 생성 및 기존 값을 제거합니다.

### Monadic 연산자

C++23부터 `optional`을 모나딕하게 사용하게 도와주는 연산자들을 소개합니다. 이를 함수형 프로그래밍의 모나드의 개념을 활용할 수 있습니다.

- `and_then` : 값이 있으면 함수를 적용하고 결과를 반환합니다. (flatMap)
- `transform` : 값이 있으면 함수를 적용하고 변환된 값을 감싼 `optional`을 반환합니다. (map)
- `or_else` : 값이 없으면 대체 값을 생성하거나 변환합니다. (fallback)

```cpp
#include <iostream>
#include <string>
#include <optional>

std::optional<std::string> get_username(int id) {
    if (id == 1) return "alice";
    return std::nullopt;
}

std::optional<std::string> get_email(const std::string& username) {
    if (username == "alice") return "alice@example.com";
    return std::nullopt;
}

std::optional<std::string> extract_domain(const std::string& email) {
    auto pos = email.find('@');
    if (pos != std::string::npos)
        return email.substr(pos + 1);
    return std::nullopt;
}

int main() {
    int user_id = 1;

    std::optional<std::string> domain = get_username(user_id)
        .and_then(get_email)
        .and_then(extract_domain)
        .or_else([] {
            return std::optional<std::string>{"unknown.com"};
        });

    std::cout << "Domain: " << *domain << "\n";
}
```
> 중간 단계에서 실패하면 "unknown.com"으로 대체되는 이메일 추출 프로그램 예제입니다.