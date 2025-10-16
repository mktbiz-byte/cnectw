# CNEC Taiwan Campaign Platform

Influencer marketing campaign platform for Taiwan market.

## Features

- 🎯 Campaign management for Taiwan influencers
- 👥 Creator application and approval system
- 💰 Point-based reward system (TWD)
- 📊 Admin dashboard with analytics
- 🔐 Secure authentication with Supabase
- 📧 Email notifications
- 🌏 Taiwan region-specific (TW)

## Tech Stack

- **Frontend**: React + Vite
- **Styling**: Tailwind CSS
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Deployment**: Netlify

## Setup

### 1. Install Dependencies

```bash
npm install --legacy-peer-deps
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your Taiwan Supabase credentials:

```env
VITE_SUPABASE_URL=https://your-taiwan-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-taiwan-anon-key
VITE_PLATFORM_REGION=tw
VITE_PLATFORM_COUNTRY=TW
```

### 3. Setup Database

1. Create a new Supabase project (Singapore region recommended)
2. Run `COMPLETE_TW_SCHEMA.sql` in SQL Editor
3. Run `FIX_TAIWAN_VIRTUAL_SELECTION.sql` in SQL Editor

### 4. Run Development Server

```bash
npm run dev
```

Visit http://localhost:5173

### 5. Build for Production

```bash
npm run build
```

## Deployment

### Netlify

```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod --dir=dist
```

Set environment variables in Netlify dashboard.

## Documentation

- `TAIWAN_VERSION_SETUP_GUIDE.md` - Complete setup guide
- `TAIWAN_DEPLOYMENT_CHECKLIST.md` - Deployment checklist
- `COMPLETE_TW_SCHEMA.sql` - Database schema
- `FIX_TAIWAN_VIRTUAL_SELECTION.sql` - Virtual selection feature fix

## Default Configuration

- **Region**: Taiwan (TW)
- **Currency**: TWD (New Taiwan Dollar)
- **Locale**: zh-TW (Traditional Chinese)
- **Timezone**: Asia/Taipei

## Admin Account

After signup, run this SQL to make a user admin:

```sql
UPDATE user_profiles 
SET role = 'admin' 
WHERE email = 'your-email@example.com';
```

## Support

For issues or questions, contact: support@cnec.tw

## License

Proprietary - CNEC Taiwan

---

**Based on**: CNEC US Platform  
**Platform Region**: Taiwan (TW)  
**Last Updated**: 2025-10-16

