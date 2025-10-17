# RLS 문제 해결 가이드 (Taiwan Platform)

## 문제 상황
Taiwan Supabase에서 admin 사용자(mkt_biz@cnec.co.kr)가 캠페인을 생성하려고 할 때 RLS 정책 위반 오류가 발생합니다.

## 근본 원인
사용자에게 admin 역할을 부여했지만, **JWT 토큰이 갱신되지 않아** RLS 정책이 여전히 이전 토큰(admin 역할 없음)을 참조하고 있습니다.

## 해결 방법

### 1단계: SQL 스크립트 실행
Taiwan Supabase SQL Editor에서 다음 파일을 실행하세요:

```bash
FIX_RLS_ADMIN_ACCESS.sql
```

이 스크립트는:
- Admin 역할이 제대로 설정되었는지 확인
- 더 유연한 RLS 정책 생성 (JWT와 user_profiles 테이블 모두 확인)
- 정책 검증

### 2단계: 완전한 로그아웃
**중요**: 단순히 로그아웃 버튼을 누르는 것만으로는 부족합니다.

다음 중 하나를 수행하세요:

**옵션 A: 브라우저 캐시 완전 삭제**
1. 브라우저 설정 → 개인정보 보호
2. 쿠키 및 사이트 데이터 삭제
3. 캐시된 이미지 및 파일 삭제
4. Taiwan 플랫폼 사이트 재접속

**옵션 B: 시크릿/인코그니토 모드 사용**
1. 새 시크릿 창 열기
2. Taiwan 플랫폼 사이트 접속
3. 로그인

**옵션 C: 다른 브라우저 사용**
1. Chrome 사용 중이면 Firefox로 전환
2. 새 브라우저에서 로그인

### 3단계: 재로그인
1. 이메일: mkt_biz@cnec.co.kr
2. 비밀번호 입력
3. 로그인 후 Admin Dashboard로 이동

### 4단계: 캠페인 생성 테스트
1. Admin Dashboard → Campaigns 탭
2. "Create New Campaign" 버튼 클릭
3. 캠페인 정보 입력 후 저장
4. 오류 없이 저장되는지 확인

## JWT 토큰 확인 방법

브라우저 개발자 도구에서 JWT 토큰을 확인할 수 있습니다:

```javascript
// 브라우저 콘솔에서 실행
const { data } = await supabase.auth.getSession();
console.log(data.session.user.user_metadata);
// 출력: { role: 'admin' } 이 포함되어야 함
```

또는 Application 탭에서:
1. F12 → Application 탭
2. Local Storage → 해당 도메인
3. `sb-[project-ref]-auth-token` 항목 확인
4. JWT 토큰을 jwt.io에서 디코딩
5. `user_metadata.role`이 `admin`인지 확인

## 여전히 작동하지 않는 경우

### 디버깅 체크리스트

1. **auth.users 테이블 확인**
```sql
SELECT 
  id,
  email,
  raw_user_meta_data->>'role' as role
FROM auth.users
WHERE email = 'mkt_biz@cnec.co.kr';
```
→ role이 'admin'이어야 함

2. **user_profiles 테이블 확인**
```sql
SELECT 
  user_id,
  email,
  role
FROM user_profiles
WHERE email = 'mkt_biz@cnec.co.kr';
```
→ role이 'admin'이어야 함

3. **RLS 정책 확인**
```sql
SELECT 
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'campaigns'
  AND policyname LIKE '%admin%';
```
→ campaigns_insert_admin, campaigns_update_admin, campaigns_delete_admin이 존재해야 함

4. **임시 RLS 비활성화 테스트**
```sql
-- 테스트용으로만 사용!
ALTER TABLE campaigns DISABLE ROW LEVEL SECURITY;

-- 캠페인 생성 테스트 후 다시 활성화
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
```

### 대안: 새 Admin 계정 생성

기존 계정에 문제가 있다면 새 admin 계정을 생성하세요:

```sql
-- 1. 웹사이트에서 새 계정 가입 (예: admin@cnectw.com)
-- 2. SQL Editor에서 admin 역할 부여

UPDATE auth.users
SET raw_user_meta_data = 
  jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{role}',
    '"admin"'
  )
WHERE email = 'admin@cnectw.com';

UPDATE user_profiles
SET role = 'admin'
WHERE email = 'admin@cnectw.com';
```

3. 새 계정으로 로그인 (처음부터 admin 역할이 JWT에 포함됨)

## RLS 정책 구조 이해

현재 campaigns 테이블의 RLS 정책:

```sql
-- INSERT: admin만 가능
CREATE POLICY "campaigns_insert_admin"
ON campaigns FOR INSERT
TO authenticated
WITH CHECK (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  OR
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE user_profiles.user_id = auth.uid()
    AND user_profiles.role = 'admin'
  )
);
```

이 정책은:
1. JWT 토큰의 user_metadata.role이 'admin'이거나
2. user_profiles 테이블의 role이 'admin'이면
3. 캠페인 생성을 허용합니다

## 추가 참고사항

### JWT 토큰 갱신 주기
- Supabase는 기본적으로 1시간마다 JWT 토큰을 갱신합니다
- 하지만 user_metadata 변경사항은 **재로그인해야만** 반영됩니다
- 이것이 로그아웃/로그인이 필수인 이유입니다

### RLS vs 애플리케이션 레벨 권한
- RLS는 데이터베이스 레벨 보안입니다
- 프론트엔드 코드에서 admin 체크를 해도 RLS는 별도로 작동합니다
- 양쪽 모두 admin 권한을 인식해야 합니다

### Storage 정책
캠페인 이미지 업로드도 Storage 정책의 영향을 받습니다:

```sql
-- campaign-images 버킷 정책 확인
SELECT * FROM storage.policies
WHERE bucket_id = 'campaign-images';
```

필요시 `CREATE_STORAGE_POLICIES.sql` 재실행

## 문제 해결 완료 확인

다음 작업이 모두 가능하면 문제가 해결된 것입니다:

- ✅ Admin Dashboard 접속
- ✅ 캠페인 생성
- ✅ 캠페인 이미지 업로드
- ✅ 캠페인 수정
- ✅ 캠페인 삭제
- ✅ 지원자 목록 조회
- ✅ 지원자 상태 변경

## 다음 단계

RLS 문제가 해결되면:

1. ✅ US 버전도 동일한 방식으로 확인
2. ✅ Google OAuth 설정
3. ✅ Netlify 배포
4. ✅ 도메인 연결
5. ✅ 전체 기능 테스트

---

**작성일**: 2025-10-16  
**대상 플랫폼**: CNEC Taiwan (cnec-taiwan Supabase project)  
**관련 파일**: FIX_RLS_ADMIN_ACCESS.sql, GRANT_ADMIN_ROLE.sql

