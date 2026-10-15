# CloudMint Vercel starter
Includes a responsive website, Supabase email/password authentication, admin panel, maintenance ON/OFF setting, max validity (up to 120 days), minimum withdrawal setting, and manual payment-request review.

## Deploy
1. Create a Supabase project.
2. Run `supabase/schema.sql` in Supabase SQL Editor.
3. Upload this folder to a GitHub repository.
4. Import the repo in Vercel.
5. Add Vercel Environment Variables `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from Supabase Project Settings > API.
6. Deploy.
7. Sign up using your email. In Supabase > Authentication > Users, copy your user UUID.
8. Run `update public.profiles set role='admin' where id='YOUR-USER-UUID';` in Supabase SQL Editor.
9. Sign in again to access Admin panel.

## Local
`npm install`, copy `.env.example` to `.env.local`, fill in Supabase values, then `npm run dev`.

## Important
This is a starter, not yet a fully audited production payment system. It does not implement mining, guaranteed 2x investment returns, or automated crypto transfers. Manual status changes do not send money. Do not take customer funds or promise returns without verified revenue, sufficient reserves, and advice on applicable Pakistani laws and licensing. Never expose a Supabase service-role key in browser code.
