# Power Proxy Seller — وب‌اپلیکیشن مدیریت (Flutter)

وب‌اپلیکیشن **Power Proxy Seller** پنل مدیریتی ربات فروش VPN/پروکسی است. با این اپ می‌توانید کاربران، سفارش‌ها، پنل‌ها، پرداخت‌ها و تنظیمات ربات تلگرام را از طریق مرورگر مدیریت کنید.

این پروژه به [هستهٔ Laravel](https://github.com/rezahajrahimi/telegram-vpn-seller-bot-v2) متصل می‌شود و رابط کاربری RTL فارسی برای داشبورد، گزارش‌ها و تنظیمات پیشرفته فراهم می‌کند.

---

# 🔓 آزادسازی پروژه پس از ۳ سال

بعد از **سه سال توسعه، نگه‌داری و استفاده خصوصی**، این پروژه اکنون به‌صورت کامل **آزاد (Open Source)** منتشر شده تا همهٔ توسعه‌دهندگان بتوانند روی آن فعالیت کنند، آن را گسترش دهند و به بهبود دسترسی کاربران ایرانی به اینترنت آزاد کمک کنند.

کد وب‌اپ که قبلاً فقط به‌صورت بیلد منتشر می‌شد، اکنون **سورس کامل** در دسترس است و می‌توانید مستقیماً روی آن مشارکت داشته باشید:

## 📦 سورس‌های آزاد شده

### 🟦 هستهٔ ربات (Laravel)
سورس کامل هستهٔ ربات تلگرام برای مدیریت فروش VPN، اتصال به پنل‌ها، مدیریت کاربران و سفارش‌ها:

🔗 https://github.com/rezahajrahimi/telegram-vpn-seller-bot-v2

### 🟦 وب‌اپلیکیشن ربات (Flutter)
نسخهٔ وب‌اپلیکیشن برای مدیریت و تعامل با ربات، مناسب برای پنل‌های فروش و داشبوردهای مدیریتی:

🔗 https://github.com/rezahajrahimi/power_ps_front_3

این آزادسازی با هدف ایجاد یک اکوسیستم **باز، شفاف و قابل توسعه** انجام شده تا هر کسی بتواند در مسیر ساخت ابزارهای بهتر برای اینترنت آزاد نقش داشته باشد.

---

## ❤️ حمایت از توسعه پروژه

اگر می‌خواهید از ادامهٔ توسعه و نگه‌داری این پروژه حمایت کنید، می‌توانید از طریق شبکه‌های زیر کمک مالی ارسال کنید:

### 💠 TRON (TRC20)
`TRHjr9TrMWtdQxrH72bCg5LJ2XQU9PkQEL`

### 💠 Litecoin (LTC)
`ltc1qdapm3c45s6dngspmvh9wen52ymf7mt5hcyxkfm`

---

## ویژگی‌های کلیدی

- **داشبورد مدیریتی** با نمودارها و خلاصهٔ مالی
- مدیریت **کاربران**، **تراکنش‌ها** و **سفارش‌ها**
- تنظیم **پنل‌ها** (Marzban، Hiddify، Sanaei، Pasarguard)
- **افزودن کانفیگ از Excel** (xlsx/csv) برای موجودی انبار
- مدیریت **محصولات**، **دسته‌بندی‌ها** و **انبار**
- تنظیم **درگاه‌های پرداخت** (زرین‌پال، NowPayments، Cryptomus)
- **شخصی‌سازی ربات**: متن‌ها، منوها، دکمه‌ها
- **بازاریابی**: کد تخفیف، زیرمجموعه، وفاداری
- **کارت هدیه**، **اکانت آزمایشی**، **قفل کانال**
- **پشتیبان‌گیری**، **Cron Job**ها و **گزارش‌ها**
- رابط **RTL فارسی** و طراحی تیره (Dark)

---

## پیش‌نیازها

| ابزار | نسخه |
|--------|------|
| Flutter SDK | 3.6+ |
| Dart SDK | ^3.6.1 |
| Chrome (برای Web) | — |
| Git | — |

**الزامی:** هستهٔ Laravel باید نصب و در حال اجرا باشد:
[telegram-vpn-seller-bot-v2](https://github.com/rezahajrahimi/telegram-vpn-seller-bot-v2)

---

## نصب سریع (سرور تولید)

### روش ۱ — اسکریپت خودکار

اگر از [install.sh](https://github.com/rezahajrahimi/powerps-core-scripts) استفاده می‌کنید، وب‌اپ و هسته با هم نصب می‌شوند و `BASE_URL` در `assets/.env` خودکار تنظیم می‌گردد.

```sh
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/rezahajrahimi/powerps-core-scripts/refs/heads/main/install.sh)" @ install
```

### روش ۲ — آپلود بیلد Web

```sh
git clone https://github.com/rezahajrahimi/power_ps_front_3.git
cd power_ps_front_3
flutter pub get
flutter build web --release
```

خروجی در `build/web/` است. آن را روی هاست آپلود کنید و `assets/.env` را ویرایش کنید:

```env
BASE_URL=https://core.yourdomain.com
```

> در محیط Web، اپ ابتدا `assets/.env` را از سرور می‌خواند؛ بنابراین می‌توانید آدرس API را بدون rebuild تغییر دهید.

---

## راه‌اندازی محلی (توسعه)

### ۱. کلون مخزن

```sh
git clone https://github.com/rezahajrahimi/power_ps_front_3.git
cd power_ps_front_3
```

### ۲. تنظیم آدرس API

فایل `assets/.env` را بسازید (یا از قالب کپی کنید):

```sh
cp tools/assets-dotenv.template assets/.env
```

مقدار `BASE_URL` را برابر آدرس هستهٔ Laravel قرار دهید:

```env
BASE_URL=http://127.0.0.1:8000
```

در `.env` هسته، `FRONT_URL` را هم با آدرس وب‌اپ هماهنگ کنید:

```env
FRONT_URL=http://localhost:8080
```

### ۳. نصب وابستگی‌ها

```sh
flutter pub get
```

### ۴. اجرا

```sh
flutter run -d chrome
```

یا با پورت مشخص:

```sh
flutter run -d web-server --web-port 8080
```

### ۵. ورود به پنل

| فیلد | مقدار |
|------|--------|
| نام کاربری | مقدار `TELEGRAM_ADMIN_ID` در `.env` هسته |
| رمز عبور | `admin123456` |

> پس از اولین ورود، رمز عبور را حتماً تغییر دهید.

---

## بیلد Release

```sh
flutter build web --release
```

خروجی در `build/web/` قرار می‌گیرد.

### انتشار با اسکریپت داخلی

```sh
# بیلد + آماده‌سازی dist/powerps-webapp
./tools/publish-powerps-webapp.sh

# فقط بسته‌بندی (اگر build/web موجود است)
./tools/publish-powerps-webapp.sh --skip-build

# بیلد + push به مخزن powerps-webapp
./tools/publish-powerps-webapp.sh --push
```

---

## ساختار پروژه

```
lib/
├── main.dart              # نقطهٔ ورود، Providerها، مسیریابی
├── helper/                # Dio، env، shared preferences
├── models/                # مدل‌های داده
├── provider/              # State management (Provider)
├── repositories/          # فراخوانی API
├── screens/
│   └── admin_screen/      # داشبورد، کاربران، تراکنش‌ها، تنظیمات
├── styles/                # تم و استایل
└── widgets/               # کامپوننت‌های مشترک

assets/
├── .env                   # BASE_URL (در git نادیده گرفته می‌شود)
└── images/                # آیکون‌ها و تصاویر
```

---

## اتصال به API

- همهٔ درخواست‌ها از `lib/helper/connector/dio.dart` به `BASE_URL` ارسال می‌شوند
- احراز هویت با Bearer Token (Sanctum) انجام می‌شود
- ترتیب اولویت آدرس API: **SharedPreferences** → **assets/.env** → مقدار پیش‌فرض

---

## تست و کیفیت کد

```sh
flutter analyze
flutter test
```

---

## مشارکت در توسعه

از مشارکت شما استقبال می‌کنیم!

1. مخزن را **Fork** کنید
2. شاخهٔ feature بسازید: `git checkout -b feature/my-feature`
3. تغییرات را commit کنید
4. Pull Request باز کنید

### راهنما

- قبل از PR، `flutter analyze` را اجرا کنید
- از الگوی موجود Provider + Repository پیروی کنید
- UI فارسی RTL را حفظ کنید
- تغییرات بزرگ را ابتدا در Issue مطرح کنید

---

## راه‌های ارتباطی

- وب‌سایت: [https://powerps.ir](https://powerps.ir)
- پشتیبانی تلگرام: [@powerproxysellersupport](https://t.me/powerproxysellersupport)
- توسعه‌دهنده / مشارکت: [@Rezahajrahimi_dev](https://t.me/Rezahajrahimi_dev)
- آموزش نصب (ویدیو): [YouTube](https://youtu.be/drZGXXxSNSE)

---

## مجوز

این پروژه تحت مجوز **MIT** منتشر شده است.
