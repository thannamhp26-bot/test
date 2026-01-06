# Coolify Deployment Guide

## Sau khi deploy thành công

### 1. Kiểm tra containers đang chạy
Trong Coolify Dashboard, đảm bảo 3 containers healthy:
- ✅ languagehub_db (PostgreSQL)
- ✅ languagehub_redis (Redis)  
- ✅ languagehub_web (Django)

### 2. Vào Container Shell (languagehub_web)

Click vào **Terminal/Shell** icon của container `languagehub_web`

### 3. Chạy các lệnh sau:

```bash
# Chạy migrations (nếu chưa tự động chạy)
python manage.py migrate

# Tạo sample data
python manage.py load_sample_data

# Kiểm tra data đã có chưa
python manage.py shell -c "from resources.models import Resource; print(f'Resources: {Resource.objects.count()}')"
```

### 4. Tạo superuser (nếu cần)

```bash
python manage.py createsuperuser
# Username: admin
# Email: admin@languagehub.com  
# Password: (tự đặt)
```

### 5. Kiểm tra website

- Frontend: https://unstressvn.com
- API: https://unstressvn.com/api/v1/resources/
- Admin: https://unstressvn.com/admin

## Nếu gặp lỗi 500

1. **Xem logs:**
   - Coolify Dashboard → Logs
   - Tìm lỗi trong Django traceback

2. **Kiểm tra database connection:**
```bash
python manage.py dbshell
# Nếu connect được → database OK
# Nếu lỗi → check DATABASE_URL trong .env
```

3. **Check environment variables:**
   - DATABASE_URL phải là: `postgres://languagehub:languagehub123@db:5432/languagehub`
   - ALLOWED_HOSTS phải có domain: `unstressvn.com,www.unstressvn.com`

## Troubleshooting

### Lỗi: "could not translate host name 'db'"
→ Database container chưa start, đợi 30s và retry

### Lỗi: "relation does not exist"  
→ Chưa chạy migrations:
```bash
python manage.py migrate
```

### Website blank/no data
→ Chạy load sample data:
```bash
python manage.py load_sample_data
```

### Static files không load
→ Rebuild và redeploy để chạy collectstatic
