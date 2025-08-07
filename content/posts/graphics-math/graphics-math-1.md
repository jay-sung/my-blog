---
title: "Math for Graphics (1) - Point, Vector"
author: "Jay645"
date: "2025-08-07"
summary: "Point와 Vector에 대해서 알아봅니다."
toc: true
readTime: true
autonumber: true
math: true
tags: ["cg", "math"]
showTags: false
hideBackToTop: false
---

## 개요

그래픽스 수학 중에서 기본적인 Point와 Vector에 대해서 간단하게 알아봅니다.

## Point와 Vector

- **Point (점)**: 공간상의 위치를 나타냅니다. 보통 `P = (x, y, z)`로 표현합니다.
- **Vector (벡터)**: 방향과 크기를 가진 존재입니다. 위치와는 무관하며, 이동이나 속도 등 '변화'를 나타낼 때 사용됩니다.

두 점 `P1`, `P2`의 차 `P2 - P1`은 **P1에서 P2로 향하는 벡터**를 의미합니다.  
또한, 점에 벡터를 더하면 그 방향만큼 이동한 새로운 점이 됩니다.

$$ \text{Point} + \text{Vector} = \text{Moved Point} $$

## Vector 연산

두 Vector를 더하면 방향과 크기가 합쳐집니다. Vector를 빼면 두 사이의 상대적인 방향이 계산됩니다.

$$ \vec{a} + \vec{b} = (a_x + b_x,\ a_y + b_y,\ a_z + b_z) $$

### 스칼라 곱 (Scalar Multiplication)

Vector에 스칼라(순수 값)을 곱하면 크기만 변화하고 방향은 그대로 유지됩니다. 세기만 변하는 느낌입니다.

$$ k⋅\vec{a} = (k⋅a_x, k⋅a_y, k⋅a_z) $$

### 벡터의 크기 (Length)

벡터의 크기는 피타고라스 정리를 이용해 계산합니다. 두 지점 간의 거리 혹은 충돌 판정에서 활용합니다.

$$ |\vec{a}| = \sqrt{a^2_x + a^2_y + a^2_z} $$

### 정규화 (Nomalization)

정규화란 크기가 1인 단위 벡터를 의미하며, 방향만을 나타낼 때 사용합니다. 벡터의 크기를 제외한 순수 방향이 필요할 때 자주 사용합니다.

$$ \hat{a} = \frac{\vec{a}}{|\vec{a}|} $$

### 내적 (Dot Product)

두 벡터의 내적이란 두 백터 사이의 방향의 유사도를 판단할 때 사용합니다. 조명처럼 두 직선의 상대적인 방향을 측정해야 할 때 활용됩니다.

- 두 벡터가 같은 방향이면 결과는 > 0 (유사한 방향)
- 서로 수직이면 결과는 = 0 (직교)
- 반대 방향이면 결과 < 0 (반대 방향)

$$ \vec{a}⋅\vec{b} = |\vec{a}||\vec{b}|cos\phi $$ 

### 외적 (Cross Product)

두 벡터의 외적은, 그 벡터들과 수직인 벡터를 계산합니다. 표면 법선 벡터를 계산하거나, 회전축 계산에서 활용합니다.

$$ \vec{a} × \vec{b} = \vec{n} $$

외적의 결과는 a, b를 이루는 평면에 수직인 백터 n이 나옵니다. 외적의 결과는 두 벡터 모두와 직교합니다.