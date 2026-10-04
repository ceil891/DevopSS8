# Bài 3 — Các lệnh để chạy và ghi nhận kết quả

Đây là hướng dẫn lệnh, **chưa phải biên bản đã chạy thành công**. Sau khi thực hiện, ghi ngày chạy và URL package thật ở cuối file; không ghi PAT.

## Chuẩn bị

Mở Docker Desktop, dùng Linux containers. `docker info` phải trả về thông tin Server.
Tạo Personal access token **classic**, hạn dùng ngắn, quyền `write:packages` (bao gồm đọc package); không cần `delete:packages`. Có thể dùng https://github.com/settings/tokens/new?scopes=write:packages để tránh tự chọn thêm quyền repo. Nếu tổ chức yêu cầu SSO, authorize token.

Đã tạo mã nguồn payment-service mẫu ở `ss8/exercise_03/payment-service` với Java 21, Gradle 8.10 và endpoint /actuator/health. Dockerfile bên dưới tương ứng Java 21.

## PowerShell — chạy từ ss8

```powershell
cd E:\BaiTapDeVop\ss8
docker info
# Dừng ở đây nếu docker info báo lỗi.
$ghcrUser = 'ceil891'
$imageRef = "ghcr.io/${ghcrUser}/payment-service:1.0.0".ToLowerInvariant()
$securePat = Read-Host 'Nhap PAT classic (khong hien thi)' -AsSecureString
$patCredential = [System.Management.Automation.PSCredential]::new($ghcrUser, $securePat)
$patCredential.GetNetworkCredential().Password | docker login ghcr.io -u $ghcrUser --password-stdin
if ($LASTEXITCODE -ne 0) { throw 'Dang nhap GHCR that bai' }
Remove-Variable securePat,patCredential

docker build -f exercise_03/Dockerfile -t $imageRef exercise_03/payment-service
if ($LASTEXITCODE -ne 0) { throw 'Build image that bai' }
docker push $imageRef
if ($LASTEXITCODE -ne 0) { throw 'Push image that bai' }
docker image inspect $imageRef --format '{{json .RepoDigests}}'
docker logout ghcr.io
```

Chép `.dockerignore` từ exercise_02 vào gốc source payment-service trước khi build, để loại cache, file build cũ và .env khỏi build context.

Nếu `denied`: kiểm tra đúng tài khoản sở hữu namespace, PAT classic còn hạn/có write:packages, SSO và quyền Write nếu package đã tồn tại. Login thành công chưa chứng minh có quyền push mọi namespace.

Mở https://github.com/ceil891?tab=packages, chọn payment-service và kiểm tra phiên bản 1.0.0. Copy URL package từ trình duyệt; không coi URL dự kiến là bằng chứng đã push.

## Kết quả thực tế (điền sau khi chạy)

- Ngày chạy: chưa chạy
- Digest sau push: chưa có
- URL package: chưa có
- Ảnh Packages: chưa có
