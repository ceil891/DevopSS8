# SS8 — Docker Socket, Multi-stage Build và GHCR

## Trạng thái

**Đã kiểm chứng bổ sung:** cả hai service build JAR thành công, chạy được trên máy và trả health UP cùng API mẫu. Xem VERIFICATION.md. Docker image, GHCR và Actions chưa được xác minh.

Đã chuẩn bị cấu hình, lệnh và tự tạo hai service mẫu theo yêu cầu. Cart dùng Java 17, payment dùng Java 21; Spring Boot 3.3.5 và Gradle Wrapper 8.10 theo dự án học hiện có. Hai service có Actuator /actuator/health, không cần database. Đây là demo CI/Docker, không phải ứng dụng thanh toán thực tế. Chưa build/push image hoặc chạy GitHub Actions: lần kiểm tra đầu Docker CLI không kết nối được daemon, chưa có repository SS8 đích. Không có ảnh minh chứng hoặc số liệu đo giả.

Lấy **ss8 làm gốc repository riêng** khi push. Hai workflow đã nằm ở `.github/workflows/` tại gốc này; GitHub không nhận workflow trong thư mục con của repo. Không push ss8 vào ss7 rồi mong workflow được nhận tự động.

## Bài 1 — Chia sẻ socket

Lỗi `Cannot connect ...` nghĩa là Docker CLI không liên lạc được daemon tại endpoint đó; có thể do thiếu mount, daemon host chưa chạy hoặc endpoint sai. `permission denied` là lỗi quyền truy cập socket, cần phân biệt khi đọc log. DooD dùng daemon host; các container do job tạo chạy trên host, không nằm trong runner.

Compose trong exercise_01 bind-mount `/var/run/docker.sock` vào đúng đường dẫn trong runner, đặt DOCKER_HOST tương ứng. `create_host_path: false` tránh tạo nhầm thư mục khi socket chưa tồn tại. Image runner cộng đồng myoung34 có Docker CLI. Cấu hình dành cho Linux x64, Docker rootful. Rootless Docker dùng socket khác, phải xác định bằng docker context inspect rồi sửa source.

Trên Linux host, từ exercise_01:

```bash
docker info
test -S /var/run/docker.sock
ls -l /var/run/docker.sock
cp .env.example .env
chmod 600 .env
nano .env
# Điền repository URL và token đăng ký runner, rồi:
docker compose config --quiet
docker compose up -d --force-recreate
docker compose exec runner docker info
```

ACCESS_TOKEN của runner dùng quyền quản trị runner repository (fine-grained PAT với Administration read/write), khác PAT classic dùng GHCR ở Bài 3. Không commit .env. Compose dùng root để truy cập socket rootful; không cần privileged hoặc chmod 666 socket. Quyền socket cho phép điều khiển host, chỉ chạy code tin cậy.

Sau khi Settings → Actions → Runners hiện Idle và label quickbite-dood, mở Actions → Verify Docker Socket → Run workflow. Chụp log `Verify host Docker daemon` (có Server) hoặc bước hello-world thành công. Nộp ảnh và exercise_01/docker-compose.yml. Sửa mount cần recreate; `docker compose restart` đơn thuần không áp dụng cấu hình mount mới.

## Bài 2 — Build và so sánh

Hai chỗ khuyết cơ bản là `eclipse-temurin:17-jre-alpine` và `COPY --from=builder /app/build/libs/*.jar app.jar` nếu chỉ có một JAR. File đã chuẩn bị chọn một JAR không có hậu tố -plain, kiểm tra đúng một file và chuẩn hóa tên trước khi copy để tránh lỗi nhiều JAR. Stage cuối chỉ có JRE và JAR.

Source mẫu đã có ở `exercise_02/cart-service/`, chứa gradlew, build.gradle và .dockerignore. Trong PowerShell, từ ss8:

```powershell
docker info
docker build -f exercise_02/Dockerfile.single-stage -t cart-service:single exercise_02/cart-service
# Chỉ tiếp tục nếu build thành công.
docker build -f exercise_02/Dockerfile -t cart-service:multi exercise_02/cart-service
docker images cart-service
docker image inspect cart-service:single cart-service:multi --format '{{index .RepoTags 0}} {{.Size}} bytes'
```

Chụp terminal có cả hai tag và SIZE, nộp cùng Dockerfile. Tỷ lệ giảm = (size single - size multi) / size single * 100%. Không cam kết dưới 150 MB: phụ thuộc JRE, dependencies và cách đo (local image khác compressed registry size). Không có số đo cho đến khi build thành công.

## Bài 3 — GHCR

Thực hiện theo exercise_03/commands.md. Source mẫu payment-service Java 21 đã có ở exercise_03/payment-service. Tag thống nhất là ghcr.io/ceil891/payment-service:1.0.0. Nộp file lệnh sau khi cập nhật kết quả thực tế và link package/ảnh Packages.

## Bài 4 — Pull và verify

File nộp là `.github/workflows/ci.yml`. Workflow có `packages: read`, đăng nhập bằng github.actor và secrets.GITHUB_TOKEN, lowercase image reference, pull rồi docker run -d. PACKAGE_NAME cố định payment-service để khớp Bài 3, không lấy tên repo bài tập làm tên image. Nếu tự đổi sang tên repository, cần lowercase toàn bộ reference và push đúng tag tương ứng.

Với package private được push bằng PAT: vào package → Package settings → Manage Actions access, thêm repository SS8 với quyền Read. Chỉ khai báo packages: read không tự cấp quyền đọc một package chưa cho repo truy cập.

Service mẫu có HTTP GET /actuator/health trên cổng 8080, trả status UP khi sẵn sàng, không cần database. Nếu thay source, cần đối chiếu endpoint và biến môi trường. Docker run -d thành công chưa đủ: workflow kiểm tra container còn chạy và chờ HTTP healthy, in log rồi dọn container ngay cả khi thất bại.

Sau khi Bài 3 push thành công và cấp quyền package, Actions → Pull and Verify Payment Image → Run workflow. Chụp/log và nộp URL run thành công. Không build lại trong workflow này. Thời gian dưới 20 giây chỉ là mục tiêu; cold pull, tải runner và startup Java có thể lâu hơn. Không bỏ kiểm tra readiness để làm đẹp thời gian.

## Tài liệu

- [Docker bind mounts](https://docs.docker.com/engine/storage/bind-mounts/)
- [Docker multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Container Registry: PAT, token và quyền package](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Image runner cộng đồng](https://github.com/myoung34/docker-github-actions-runner/wiki/Usage)
