# WorkTrack API Documentation

## Base URL
```
http://localhost:8080/api/v1
```

## API Overview
WorkTrack là hệ thống quản lý chấm công và nhân viên với các tính năng:
- Quản lý thông tin nhân viên
- Chấm công đa phương thức (vân tay, khuôn mặt, NFC, thủ công)
- Tự động tạo báo cáo lương
- Cấu hình mức lương
- Quản lý vai trò

---

## 1. Nhân Viên (Employees)

### 1.1 Lấy danh sách tất cả nhân viên
```http
GET /api/v1/nhanvien
```

**Response:**
```json
[
  {
    "maNV": 1,
    "hoTen": "Nguyễn Văn A",
    "email": "nguyenvana@example.com",
    "soDienThoai": "0123456789",
    "diaChi": "123 Đường ABC, TP.HCM",
    "maVaiTro": 1,
    "vaiTro": {
      "maVaiTro": 1,
      "tenVaiTro": "Admin",
      "moTa": "Quản trị viên hệ thống",
      "ngayTao": "2025-12-19T10:00:00"
    },
    "maNFC": "NFC001",
    "ngayTao": "2025-12-19T10:00:00",
    "ngayCapNhat": "2025-12-19T10:00:00"
  }
]
```

### 1.2 Lấy thông tin nhân viên theo ID
```http
GET /api/v1/nhanvien/{id}
```

**Parameters:**
- `id` (path): Mã nhân viên

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 1.3 Tạo nhân viên mới
```http
POST /api/v1/nhanvien
```

**Request Body:**
```json
{
  "hoTen": "Trần Thị B",
  "email": "tranthib@example.com",
  "soDienThoai": "0987654321",
  "diaChi": "456 Đường XYZ, Hà Nội",
  "maVaiTro": 2,
  "maNFC": "NFC002",
  "vanTay": "base64_encoded_fingerprint_data",
  "khuonMat": "base64_encoded_face_data"
}
```

**Response:** Status 201 (Created)

**Note:** 
- `maNV`, `ngayTao`, `ngayCapNhat` được tự động tạo
- `vanTay` và `khuonMat` là dữ liệu nhị phân được encode base64

### 1.4 Cập nhật thông tin nhân viên
```http
PUT /api/v1/nhanvien/{id}
```

**Parameters:**
- `id` (path): Mã nhân viên

**Request Body:** Giống như tạo mới

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 1.5 Xóa nhân viên
```http
DELETE /api/v1/nhanvien/{id}
```

**Parameters:**
- `id` (path): Mã nhân viên

**Response:** Status 204 (No Content)

### 1.6 Tìm nhân viên theo email
```http
GET /api/v1/nhanvien/email/{email}
```

**Parameters:**
- `email` (path): Email nhân viên

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 1.7 Tìm nhân viên theo mã NFC
```http
GET /api/v1/nhanvien/nfc/{maNFC}
```

**Parameters:**
- `maNFC` (path): Mã NFC

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 1.8 Lấy danh sách nhân viên theo vai trò
```http
GET /api/v1/nhanvien/vaitro/{maVaiTro}
```

**Parameters:**
- `maVaiTro` (path): Mã vai trò

**Response:** Danh sách nhân viên có vai trò tương ứng

---

## 2. Vai Trò (Roles)

### 2.1 Lấy danh sách tất cả vai trò
```http
GET /api/v1/vaitro
```

**Response:**
```json
[
  {
    "maVaiTro": 1,
    "tenVaiTro": "Admin",
    "moTa": "Quản trị viên hệ thống",
    "ngayTao": "2025-12-19T10:00:00"
  },
  {
    "maVaiTro": 2,
    "tenVaiTro": "NhanVien",
    "moTa": "Nhân viên thông thường",
    "ngayTao": "2025-12-19T10:00:00"
  }
]
```

### 2.2 Lấy thông tin vai trò theo ID
```http
GET /api/v1/vaitro/{id}
```

**Parameters:**
- `id` (path): Mã vai trò

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 2.3 Tạo vai trò mới
```http
POST /api/v1/vaitro
```

**Request Body:**
```json
{
  "tenVaiTro": "QuanLy",
  "moTa": "Quản lý phòng ban"
}
```

**Response:** Status 201 (Created)

**Note:** `tenVaiTro` phải là duy nhất

### 2.4 Cập nhật vai trò
```http
PUT /api/v1/vaitro/{id}
```

**Parameters:**
- `id` (path): Mã vai trò

**Request Body:** Giống như tạo mới

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 2.5 Xóa vai trò
```http
DELETE /api/v1/vaitro/{id}
```

**Parameters:**
- `id` (path): Mã vai trò

**Response:** Status 204 (No Content)

### 2.6 Kiểm tra tên vai trò đã tồn tại
```http
GET /api/v1/vaitro/check?tenVaiTro={name}
```

**Parameters:**
- `tenVaiTro` (query): Tên vai trò cần kiểm tra

**Response:**
```json
{
  "exists": true
}
```

---

## 3. Chấm Công (Attendance)

### 3.1 Lấy danh sách tất cả bản ghi chấm công
```http
GET /api/v1/chamcong
```

**Response:**
```json
[
  {
    "maChamCong": 1,
    "nhanVien": {
      "maNV": 1,
      "hoTen": "Nguyễn Văn A"
    },
    "gioVao": "2025-12-19T08:00:00",
    "gioRa": "2025-12-19T17:30:00",
    "ngayChamCong": "2025-12-19",
    "phuongThuc": "VanTay",
    "ghiChu": "Đúng giờ"
  }
]
```

### 3.2 Lấy bản ghi chấm công theo ID
```http
GET /api/v1/chamcong/{id}
```

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 3.3 Chấm công vào (Check-in)
```http
POST /api/v1/chamcong/checkin
```

**Request Body:**
```json
{
  "nhanVien": {
    "maNV": 1
  },
  "phuongThuc": "VanTay",
  "ghiChu": "Chấm công vào ca sáng"
}
```

**Phương thức hợp lệ:**
- `VanTay`: Vân tay
- `KhuonMat`: Khuôn mặt
- `NFC`: Thẻ NFC
- `ThuCong`: Thủ công

**Response:** Status 201 (Created)

**Note:** Không thể check-in nếu đã có phiên chấm công chưa check-out

### 3.4 Chấm công ra (Check-out)
```http
POST /api/v1/chamcong/checkout/{maNV}
```

**Parameters:**
- `maNV` (path): Mã nhân viên

**Response:** Status 200 (OK) hoặc 404 (Not Found)

**Note:** Tự động cập nhật `gioRa` và tính toán thời gian làm việc

### 3.5 Cập nhật bản ghi chấm công
```http
PUT /api/v1/chamcong/{id}
```

**Request Body:**
```json
{
  "nhanVien": {
    "maNV": 1
  },
  "gioVao": "2025-12-19T08:00:00",
  "gioRa": "2025-12-19T17:30:00",
  "phuongThuc": "VanTay",
  "ghiChu": "Đã chỉnh sửa"
}
```

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 3.6 Xóa bản ghi chấm công
```http
DELETE /api/v1/chamcong/{id}
```

**Response:** Status 204 (No Content)

### 3.7 Lấy bản ghi chấm công theo nhân viên
```http
GET /api/v1/chamcong/nhanvien/{maNV}
```

**Parameters:**
- `maNV` (path): Mã nhân viên

**Response:** Danh sách bản ghi chấm công

### 3.8 Lấy bản ghi chấm công theo ngày
```http
GET /api/v1/chamcong/ngay/{ngayChamCong}
```

**Parameters:**
- `ngayChamCong` (path): Ngày chấm công (format: yyyy-MM-dd)

**Example:** `/api/v1/chamcong/ngay/2025-12-19`

### 3.9 Lấy bản ghi chấm công theo khoảng thời gian
```http
GET /api/v1/chamcong/range?startDate={start}&endDate={end}
```

**Parameters:**
- `startDate` (query): Ngày bắt đầu (yyyy-MM-dd)
- `endDate` (query): Ngày kết thúc (yyyy-MM-dd)

**Example:** `/api/v1/chamcong/range?startDate=2025-12-01&endDate=2025-12-31`

### 3.10 Thống kê chấm công theo phương thức
```http
GET /api/v1/chamcong/statistics?startDate={start}&endDate={end}
```

**Response:**
```json
{
  "VanTay": 45,
  "KhuonMat": 30,
  "NFC": 20,
  "ThuCong": 5
}
```

---

## 4. Báo Cáo (Reports)

### 4.1 Lấy danh sách tất cả báo cáo
```http
GET /api/v1/baocao
```

**Response:**
```json
[
  {
    "maBaoCao": 1,
    "nhanVien": {
      "maNV": 1,
      "hoTen": "Nguyễn Văn A"
    },
    "thang": 12,
    "nam": 2025,
    "tongGio": 176.5,
    "soNgayDiTre": 2,
    "soNgayVeSom": 1,
    "gioLamThem": 8.5,
    "luong": 17650000.00,
    "ngayTao": "2025-12-19T10:00:00"
  }
]
```

### 4.2 Lấy báo cáo theo ID
```http
GET /api/v1/baocao/{id}
```

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 4.3 Tạo báo cáo mới
```http
POST /api/v1/baocao
```

**Request Body:**
```json
{
  "nhanVien": {
    "maNV": 1
  },
  "thang": 12,
  "nam": 2025,
  "tongGio": 176.5,
  "soNgayDiTre": 2,
  "soNgayVeSom": 1,
  "gioLamThem": 8.5,
  "luong": 17650000.00
}
```

**Response:** Status 201 (Created)

### 4.4 Tự động tạo báo cáo từ dữ liệu chấm công
```http
POST /api/v1/baocao/generate
```

**Request Body:**
```json
{
  "maNV": 1,
  "thang": 12,
  "nam": 2025
}
```

**Response:** Status 201 (Created)

**Note:** 
- Tự động tính toán từ bản ghi chấm công
- Tính tổng giờ làm việc, số ngày đi trễ, về sớm, giờ làm thêm
- Tự động tính lương dựa trên cấu hình lương hiện tại

**Quy tắc tính toán:**
- Đi trễ: Check-in sau 8:00 AM
- Về sớm: Check-out trước 5:00 PM
- Làm thêm: Tổng giờ làm việc trong ngày > 8 giờ

### 4.5 Cập nhật báo cáo
```http
PUT /api/v1/baocao/{id}
```

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 4.6 Xóa báo cáo
```http
DELETE /api/v1/baocao/{id}
```

**Response:** Status 204 (No Content)

### 4.7 Lấy báo cáo theo nhân viên
```http
GET /api/v1/baocao/nhanvien/{maNV}
```

**Response:** Danh sách báo cáo của nhân viên

### 4.8 Lấy báo cáo theo tháng/năm
```http
GET /api/v1/baocao/thang/{thang}/nam/{nam}
```

**Parameters:**
- `thang` (path): Tháng (1-12)
- `nam` (path): Năm

**Example:** `/api/v1/baocao/thang/12/nam/2025`

### 4.9 Tính lương cho báo cáo
```http
POST /api/v1/baocao/calculate-luong/{id}
```

**Parameters:**
- `id` (path): Mã báo cáo

**Response:**
```json
{
  "luong": 17650000.00
}
```

**Note:** Sử dụng cấu hình lương hiện tại để tính toán

### 4.10 Thống kê báo cáo theo khoảng thời gian
```http
GET /api/v1/baocao/statistics?startDate={start}&endDate={end}
```

**Response:**
```json
{
  "tongSoBaoCao": 150,
  "tongGioLamViec": 26400.0,
  "tongLuong": 2640000000.00,
  "trungBinhGioMoiNhanVien": 176.0,
  "trungBinhLuongMoiNhanVien": 17600000.00
}
```

---

## 5. Cấu Hình Lương (Salary Configuration)

### 5.1 Lấy danh sách tất cả cấu hình
```http
GET /api/v1/cauhinhluong
```

**Response:**
```json
[
  {
    "maCauHinh": 1,
    "luongGio": 100000.00,
    "luongLamThem": 150000.00,
    "ngayApDung": "2025-01-01",
    "ngayKetThuc": null,
    "moTa": "Mức lương năm 2025",
    "ngayTao": "2024-12-01T10:00:00"
  }
]
```

### 5.2 Lấy cấu hình theo ID
```http
GET /api/v1/cauhinhluong/{id}
```

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 5.3 Tạo cấu hình lương mới
```http
POST /api/v1/cauhinhluong
```

**Request Body:**
```json
{
  "luongGio": 100000.00,
  "luongLamThem": 150000.00,
  "ngayApDung": "2025-01-01",
  "moTa": "Mức lương năm 2025"
}
```

**Response:** Status 201 (Created)

**Note:** 
- `luongGio`: Lương theo giờ (tối thiểu > 0)
- `luongLamThem`: Lương làm thêm giờ (tối thiểu > 0)
- `ngayKetThuc`: Để null nếu đang áp dụng

### 5.4 Cập nhật cấu hình
```http
PUT /api/v1/cauhinhluong/{id}
```

**Response:** Status 200 (OK) hoặc 404 (Not Found)

### 5.5 Xóa cấu hình
```http
DELETE /api/v1/cauhinhluong/{id}
```

**Response:** Status 204 (No Content)

### 5.6 Lấy cấu hình đang áp dụng
```http
GET /api/v1/cauhinhluong/active
```

**Response:** Cấu hình có `ngayKetThuc = null`

---

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200  | OK - Yêu cầu thành công |
| 201  | Created - Tạo mới thành công |
| 204  | No Content - Xóa thành công |
| 400  | Bad Request - Dữ liệu không hợp lệ |
| 404  | Not Found - Không tìm thấy tài nguyên |
| 500  | Internal Server Error - Lỗi server |

---

## Error Response Format

```json
{
  "timestamp": "2025-12-19T10:00:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Email đã tồn tại",
  "path": "/api/v1/nhanvien"
}
```

---

## Authentication

**Current Status:** Development mode - No authentication required

**Future Implementation:** JWT-based authentication
- Login endpoint: `/api/v1/auth/login`
- Token format: `Bearer {token}`
- Header: `Authorization: Bearer eyJhbGc...`

---

## Swagger UI

Truy cập Swagger UI để test API trực tiếp:

```
http://localhost:8080/swagger-ui.html
```

hoặc

```
http://localhost:8080/swagger-ui/index.html
```

OpenAPI JSON:
```
http://localhost:8080/v3/api-docs
```

---

## Examples

### Quy trình chấm công hoàn chỉnh

1. **Tạo vai trò:**
```bash
POST /api/v1/vaitro
{
  "tenVaiTro": "NhanVien",
  "moTa": "Nhân viên thông thường"
}
```

2. **Tạo nhân viên:**
```bash
POST /api/v1/nhanvien
{
  "hoTen": "Nguyễn Văn A",
  "email": "nguyenvana@example.com",
  "soDienThoai": "0123456789",
  "maVaiTro": 1,
  "maNFC": "NFC001"
}
```

3. **Check-in:**
```bash
POST /api/v1/chamcong/checkin
{
  "nhanVien": {"maNV": 1},
  "phuongThuc": "NFC"
}
```

4. **Check-out:**
```bash
POST /api/v1/chamcong/checkout/1
```

5. **Tạo cấu hình lương:**
```bash
POST /api/v1/cauhinhluong
{
  "luongGio": 100000.00,
  "luongLamThem": 150000.00,
  "ngayApDung": "2025-01-01",
  "moTa": "Mức lương 2025"
}
```

6. **Tự động tạo báo cáo tháng:**
```bash
POST /api/v1/baocao/generate
{
  "maNV": 1,
  "thang": 12,
  "nam": 2025
}
```

---

## Notes

- Tất cả ngày giờ theo định dạng ISO 8601: `yyyy-MM-dd'T'HH:mm:ss`
- Dữ liệu nhị phân (vân tay, khuôn mặt) sử dụng Base64 encoding
- Mức lương sử dụng kiểu `BigDecimal` để đảm bảo độ chính xác
- Thời gian làm việc tiêu chuẩn: 8:00 - 17:00 (8 giờ/ngày)

---

**Version:** 1.0  
**Last Updated:** December 19, 2025  
**Contact:** support@worktrack.com
