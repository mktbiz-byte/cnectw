# Taiwan 버전 화폐 단위 수정 완료

## 수정 내용

Taiwan 버전에서 화폐 표기를 일관되게 **NT$** (New Taiwan Dollar)로 수정했습니다.

---

## 수정된 파일

### 1. HomePageTW.jsx
**위치**: `/home/ubuntu/cnectw/src/components/HomePageTW.jsx`

**변경 전**:
```javascript
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'TWD',
    minimumFractionDigits: 0
  }).format(amount)
}
// 출력 예: TWD 200
```

**변경 후**:
```javascript
const formatCurrency = (amount) => {
  if (!amount) return 'NT$0'
  return `NT$${amount.toLocaleString('zh-TW')}`
}
// 출력 예: NT$200
```

### 2. CampaignApplicationUpdated.jsx
**위치**: `/home/ubuntu/cnectw/src/components/CampaignApplicationUpdated.jsx`

**변경 전**:
```javascript
const formatCurrency = (amount) => {
  if (!amount) return '$0'
  return `$${amount.toLocaleString()}`
}
// 출력 예: $200
```

**변경 후**:
```javascript
const formatCurrency = (amount) => {
  if (!amount) return 'NT$0'
  return `NT$${amount.toLocaleString('zh-TW')}`
}
// 출력 예: NT$200
```

### 3. CampaignCreationWithTranslator.jsx (Admin)
**위치**: `/home/ubuntu/cnectw/src/components/admin/CampaignCreationWithTranslator.jsx`

**변경 전**:
```jsx
<label>보상금액</label>
<input type="number" placeholder="0" />
```

**변경 후**:
```jsx
<label>보상금액 (NT$)</label>
<div className="relative">
  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">NT$</span>
  <input type="number" placeholder="0" className="pl-12" />
</div>
```

이제 입력 필드에 **NT$** 프리픽스가 표시됩니다.

---

## 화폐 단위 설명

### NT$ (New Taiwan Dollar)
- **정식 명칭**: 新臺幣 (신대만달러)
- **국제 코드**: TWD
- **일반 표기**: NT$ 또는 元
- **사용 지역**: 대만 (Taiwan)

### 표기 방법
1. **NT$200** - 가장 일반적이고 명확한 표기 (권장)
2. **TWD 200** - 국제 통화 코드 사용
3. **200元** - 중국어 표기
4. **$200** - 맥락상 대만 달러임이 명확할 때만 사용

---

## 포인트 시스템

Taiwan 버전에서는 **포인트(P)**와 **화폐(NT$)**를 구분하여 사용합니다:

### 포인트 (P)
- **표기**: `1,000P` 또는 `1,000 포인트`
- **용도**: 사용자가 캠페인 참여로 획득하는 가상 포인트
- **위치**: MyPage, 포인트 내역, 출금 신청

### 화폐 (NT$)
- **표기**: `NT$200`
- **용도**: 실제 금액 표시
- **위치**: 캠페인 보상금액, 출금 금액

### 변환 관계
- 일반적으로 **1P = NT$1**로 설정
- 출금 시 포인트를 실제 화폐로 전환

---

## 현재 상태

### ✅ 수정 완료
- [x] HomePageTW.jsx - 캠페인 목록의 보상금액 표시
- [x] CampaignApplicationUpdated.jsx - 캠페인 지원 페이지의 보상금액 표시
- [x] CampaignCreationWithTranslator.jsx - Admin 캠페인 생성 시 입력 필드

### ⚠️ 확인 필요
- [ ] MyPageWithWithdrawal.jsx - 포인트 표기는 `P`로 유지 (화폐 아님)
- [ ] Admin 다른 페이지들 - 필요시 추가 수정

---

## 테스트 방법

### 1. 홈페이지 확인
```bash
cd /home/ubuntu/cnectw
npm run dev
```

브라우저에서 http://localhost:5173 접속
- 캠페인 카드의 보상금액이 **NT$200** 형식으로 표시되는지 확인

### 2. 캠페인 지원 페이지 확인
- 캠페인 클릭 → 상세 페이지
- 보상금액이 **NT$200** 형식으로 표시되는지 확인

### 3. Admin 캠페인 생성 확인
- Admin Dashboard → Campaigns → Create New Campaign
- 보상금액 입력 필드에 **NT$** 프리픽스가 표시되는지 확인
- 숫자 입력 시 **NT$200** 형식으로 보이는지 확인

---

## 추가 수정이 필요한 경우

다른 페이지에서도 화폐 표기를 수정하려면:

### 패턴 1: formatCurrency 함수 사용
```javascript
const formatCurrency = (amount) => {
  if (!amount) return 'NT$0'
  return `NT$${amount.toLocaleString('zh-TW')}`
}
```

### 패턴 2: 직접 표시
```jsx
<span>NT${amount.toLocaleString('zh-TW')}</span>
```

### 패턴 3: 입력 필드에 프리픽스
```jsx
<div className="relative">
  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">NT$</span>
  <input 
    type="number" 
    className="pl-12"
    placeholder="0"
  />
</div>
```

---

## 참고사항

### 대만 화폐 문화
- 대만에서는 일상적으로 **元** (위안)을 많이 사용하지만, 온라인에서는 **NT$**가 더 명확합니다
- 국제 사용자를 고려하면 **NT$**가 가장 적합합니다
- 중국 위안(CNY)과 혼동을 피하기 위해 **NT$** 사용을 권장합니다

### 숫자 포맷
- `toLocaleString('zh-TW')` 사용으로 대만 로케일에 맞는 숫자 포맷 적용
- 천 단위 구분자: 쉼표 (,)
- 예: 1,000 / 10,000 / 100,000

### US 버전과의 차이
- **US 버전**: `$200` (USD)
- **Taiwan 버전**: `NT$200` (TWD)
- 각 버전이 독립적으로 작동하므로 혼동 없음

---

**수정일**: 2025-10-16  
**수정자**: Manus AI  
**상태**: ✅ 완료  
**다음 작업**: 로컬 테스트 후 배포

