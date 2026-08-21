-- ============================================================
-- GAMEHUB — Supabase schema (Phase 1 core)
-- Run in Supabase SQL Editor. Idempotent-ish: uses IF NOT EXISTS
-- where possible. Extend with additional tables (game_reports,
-- notifications, payouts detail, etc.) as those features are built.
-- ============================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ---------- profiles (extends auth.users) ----------
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  avatar_url text,
  is_developer boolean not null default false,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- categories ----------
create table if not exists categories (
  id text primary key,               -- e.g. 'puzzle', 'action'
  label text not null,
  icon text,
  sort_order int not null default 0
);

-- ---------- developers ----------
create table if not exists developers (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  studio_name text not null,
  contact_email text,
  website text,
  status text not null default 'active' check (status in ('active','suspended')),
  created_at timestamptz not null default now()
);

-- ---------- games ----------
create table if not exists games (
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  name text not null,
  tagline text,
  description text,
  category_id text references categories(id),
  developer_id uuid references developers(id),   -- null for first-party original games
  is_original boolean not null default false,
  game_url text not null,            -- external URL, or internal path for original games
  thumbnail_url text,
  screenshots text[] default '{}',
  tags text[] default '{}',
  version text default '1.0.0',
  status text not null default 'submitted'
    check (status in ('submitted','under_review','approved','published','rejected','suspended')),
  rejection_reason text,
  is_featured boolean not null default false,
  badge text,                         -- 'hot' | 'new' | 'top' | 'original' | null
  rating_avg numeric(2,1) not null default 0,
  rating_count int not null default 0,
  play_count bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_games_category on games(category_id);
create index if not exists idx_games_status on games(status);
create index if not exists idx_games_featured on games(is_featured) where is_featured = true;
create index if not exists idx_games_play_count on games(play_count desc);

-- ---------- developer_games (submission workflow trail) ----------
create table if not exists developer_games (
  id uuid primary key default uuid_generate_v4(),
  game_id uuid not null references games(id) on delete cascade,
  developer_id uuid not null references developers(id) on delete cascade,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references profiles(id)
);

-- ---------- ratings ----------
create table if not exists ratings (
  id uuid primary key default uuid_generate_v4(),
  game_id uuid not null references games(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  stars int not null check (stars between 1 and 5),
  created_at timestamptz not null default now(),
  unique (game_id, user_id)
);

-- ---------- reviews ----------
create table if not exists reviews (
  id uuid primary key default uuid_generate_v4(),
  game_id uuid not null references games(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  body text not null,
  is_reported boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_reviews_game on reviews(game_id);

-- ---------- wishlists / library ----------
create table if not exists wishlists (
  user_id uuid not null references profiles(id) on delete cascade,
  game_id uuid not null references games(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (user_id, game_id)
);

-- ---------- game_sessions (per play session) ----------
create table if not exists game_sessions (
  id uuid primary key default uuid_generate_v4(),
  game_id uuid not null references games(id) on delete cascade,
  user_id uuid references profiles(id) on delete set null, -- null = guest
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_seconds int
);
create index if not exists idx_sessions_game on game_sessions(game_id);

-- ---------- game_plays (lightweight play-count event) ----------
create table if not exists game_plays (
  id bigint generated always as identity primary key,
  game_id uuid not null references games(id) on delete cascade,
  user_id uuid references profiles(id) on delete set null,
  played_at timestamptz not null default now()
);
create index if not exists idx_plays_game on game_plays(game_id);

-- ---------- game_reports (moderation) ----------
create table if not exists game_reports (
  id uuid primary key default uuid_generate_v4(),
  game_id uuid not null references games(id) on delete cascade,
  reported_by uuid references profiles(id) on delete set null,
  reason text not null,
  details text,
  status text not null default 'open' check (status in ('open','reviewed','dismissed')),
  created_at timestamptz not null default now()
);

-- ---------- notifications ----------
create table if not exists notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  body text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user on notifications(user_id, is_read);

-- ---------- ad_events (populated once a real ad SDK is integrated) ----------
create table if not exists ad_events (
  id bigint generated always as identity primary key,
  game_id uuid not null references games(id) on delete cascade,
  ad_type text not null check (ad_type in ('banner','native','interstitial','rewarded','pre_game','game_over')),
  event_type text not null check (event_type in ('impression','click','complete')),
  network text,                      -- e.g. 'admob' — null until real integration
  created_at timestamptz not null default now()
);
create index if not exists idx_ad_events_game on ad_events(game_id);

-- ---------- developer_revenue (derived from verified ad network data only) ----------
create table if not exists developer_revenue (
  id uuid primary key default uuid_generate_v4(),
  developer_id uuid not null references developers(id) on delete cascade,
  game_id uuid not null references games(id) on delete cascade,
  period_start date not null,
  period_end date not null,
  gross_revenue numeric(12,2),       -- null until real ad network reports data
  platform_share_pct numeric(4,1) not null default 30.0,
  developer_share_pct numeric(4,1) not null default 70.0,
  developer_payout numeric(12,2),
  is_estimated boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------- payouts ----------
create table if not exists payouts (
  id uuid primary key default uuid_generate_v4(),
  developer_id uuid not null references developers(id) on delete cascade,
  amount numeric(12,2) not null,
  status text not null default 'pending' check (status in ('pending','processing','paid','failed')),
  paid_at timestamptz,
  created_at timestamptz not null default now()
);

-- ---------- platform_settings (single-row config, admin editable) ----------
create table if not exists platform_settings (
  id int primary key default 1,
  default_developer_share_pct numeric(4,1) not null default 70.0,
  default_platform_share_pct numeric(4,1) not null default 30.0,
  maintenance_mode boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);
insert into platform_settings (id) values (1) on conflict (id) do nothing;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table profiles enable row level security;
alter table categories enable row level security;
alter table developers enable row level security;
alter table games enable row level security;
alter table developer_games enable row level security;
alter table ratings enable row level security;
alter table reviews enable row level security;
alter table wishlists enable row level security;
alter table game_sessions enable row level security;
alter table game_plays enable row level security;
alter table game_reports enable row level security;
alter table notifications enable row level security;
alter table ad_events enable row level security;
alter table developer_revenue enable row level security;
alter table payouts enable row level security;
alter table platform_settings enable row level security;

-- profiles: readable by all, editable only by owner
create policy "profiles_select_all" on profiles for select using (true);
create policy "profiles_update_own" on profiles for update using (auth.uid() = id);
create policy "profiles_insert_own" on profiles for insert with check (auth.uid() = id);

-- categories: public read, admin write (handled via service role in admin dashboard)
create policy "categories_select_all" on categories for select using (true);

-- games: published games readable by everyone; developers can see/manage their own at any status
create policy "games_select_published" on games for select
  using (status = 'published' or exists (
    select 1 from developers d where d.id = games.developer_id and d.profile_id = auth.uid()
  ) or exists (
    select 1 from profiles p where p.id = auth.uid() and p.is_admin = true
  ));
create policy "games_insert_own_developer" on games for insert
  with check (exists (select 1 from developers d where d.id = developer_id and d.profile_id = auth.uid()));
create policy "games_update_own_developer" on games for update
  using (exists (select 1 from developers d where d.id = developer_id and d.profile_id = auth.uid()));

-- developers: public read of active studios, self-manage own row
create policy "developers_select_all" on developers for select using (true);
create policy "developers_insert_own" on developers for insert with check (auth.uid() = profile_id);
create policy "developers_update_own" on developers for update using (auth.uid() = profile_id);

-- ratings / reviews: public read, authenticated users manage their own
create policy "ratings_select_all" on ratings for select using (true);
create policy "ratings_upsert_own" on ratings for insert with check (auth.uid() = user_id);
create policy "ratings_update_own" on ratings for update using (auth.uid() = user_id);

create policy "reviews_select_all" on reviews for select using (true);
create policy "reviews_insert_own" on reviews for insert with check (auth.uid() = user_id);

-- wishlists: private to the user
create policy "wishlists_owner_all" on wishlists for all using (auth.uid() = user_id);

-- sessions/plays: users see their own; inserts allowed for authenticated + guest via anon key with user_id null
create policy "sessions_select_own" on game_sessions for select using (auth.uid() = user_id);
create policy "sessions_insert_any" on game_sessions for insert with check (true);

create policy "plays_insert_any" on game_plays for insert with check (true);
create policy "plays_select_own" on game_plays for select using (auth.uid() = user_id);

-- reports: users can create, only admins can read/manage
create policy "reports_insert_any" on game_reports for insert with check (true);
create policy "reports_select_admin" on game_reports for select
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.is_admin = true));

-- notifications: private to the user
create policy "notifications_owner_all" on notifications for all using (auth.uid() = user_id);

-- ad_events: insert-only from client, read restricted to owning developer/admin
create policy "ad_events_insert_any" on ad_events for insert with check (true);
create policy "ad_events_select_owner" on ad_events for select
  using (exists (
    select 1 from games g join developers d on d.id = g.developer_id
    where g.id = ad_events.game_id and d.profile_id = auth.uid()
  ) or exists (select 1 from profiles p where p.id = auth.uid() and p.is_admin = true));

-- developer_revenue / payouts: visible only to owning developer or admin
create policy "revenue_select_owner" on developer_revenue for select
  using (exists (select 1 from developers d where d.id = developer_revenue.developer_id and d.profile_id = auth.uid())
    or exists (select 1 from profiles p where p.id = auth.uid() and p.is_admin = true));

create policy "payouts_select_owner" on payouts for select
  using (exists (select 1 from developers d where d.id = payouts.developer_id and d.profile_id = auth.uid())
    or exists (select 1 from profiles p where p.id = auth.uid() and p.is_admin = true));

-- platform_settings: public read (frontend needs share % etc.), admin-only write
create policy "settings_select_all" on platform_settings for select using (true);

-- ============================================================
-- SEED DATA
-- ============================================================
insert into categories (id, label, icon, sort_order) values
  ('puzzle',   'Puzzle',   '🧩', 1),
  ('action',   'Action',   '⚔️', 2),
  ('racing',   'Racing',   '🏎️', 3),
  ('sports',   'Sports',   '🏆', 4),
  ('strategy', 'Strategy', '🏰', 5)
on conflict (id) do nothing;

insert into games (slug, name, tagline, category_id, is_original, game_url, badge, rating_avg, rating_count, play_count, status, is_featured)
values
('merge-forge', 'Merge Forge', 'Merge, upgrade, unleash the forge.', 'puzzle', true, 'games/merge-forge/index.html', 'new', 4.7, 53, 2100, 'published', false),
  ('color-collapse', 'Color Collapse', 'Chain colors before the grid overflows.', 'puzzle', true, 'games/color-collapse/index.html', 'hot', 4.6, 85, 3400, 'published', false),
  ('neon-survivor', 'Neon Survivor', 'Outlast the swarm. Upgrade or die.', 'action', true, 'games/neon-survivor/index.html', 'top', 4.8, 125, 5000, 'published', true),
  ('shadow-dash', 'Shadow Dash', 'Switch lanes. Dash through danger.', 'action', true, 'games/shadow-dash/index.html', 'new', 4.5, 30, 1200, 'published', false),
  ('nitro-rush', 'Nitro Rush', 'Dodge traffic. Bank nitro. Go faster.', 'racing', true, 'games/nitro-rush/index.html', 'hot', 4.6, 45, 1800, 'published', false),
  ('hoop-master', 'Hoop Master', 'Pull back, release, swish. Chain combos.', 'sports', true, 'games/hoop-master/index.html', 'new', 4.7, 25, 980, 'published', false),
  ('sky-defender', 'Sky Defender', 'Vertical shooter. Waves, formations, boss fights.', 'action', true, 'games/sky-defender/index.html', 'new', 4.6, 22, 870, 'published', false),
  ('mini-empire', 'Mini Empire', 'Build, upgrade, collect. Expand your territory.', 'strategy', true, 'games/mini-empire/index.html', 'new', 4.5, 16, 640, 'published', false),
  ('chess', 'Chess', 'Classic strategy, full rules, two players.', 'strategy', true, 'games/chess/index.html', null, 4.6, 58, 2300, 'published', false),
  ('towerdefense', 'Tower Defense', 'Place towers, hold the line, survive the waves.', 'strategy', true, 'games/towerdefense/index.html', 'hot', 4.7, 48, 1900, 'published', false),
  ('tycoon', 'Coin Tycoon', 'Grow your business empire from the ground up.', 'strategy', true, 'games/tycoon/index.html', null, 4.4, 28, 1100, 'published', false),
  ('targetstrike3d', 'Target Strike 3D', 'Aim, fire, clear every target in 3D.', 'action', true, 'games/targetstrike3d/index.html', 'new', 4.5, 35, 1400, 'published', false),
  ('snake', 'Snake', 'Grow longer, don''t hit yourself.', 'action', true, 'games/snake/index.html', null, 4.3, 78, 3100, 'published', false),
  ('flappy', 'Flappy Golden Bird', 'Tap to fly, thread every gap.', 'action', true, 'games/flappy/index.html', null, 4.2, 70, 2800, 'published', false),
  ('whackamole', 'Whack-a-Mole', 'Fast reflexes, faster moles.', 'action', true, 'games/whackamole/index.html', null, 4.1, 40, 1600, 'published', false),
  ('reaction', 'Reaction Test', 'How fast are your reflexes, really?', 'action', true, 'games/reaction/index.html', null, 4, 23, 920, 'published', false),
  ('typingtest', 'Typing Speed Test', 'Race the clock, nail every word.', 'action', true, 'games/typingtest/index.html', null, 4.2, 25, 1000, 'published', false),
  ('bubbleshooter', 'Bubble Shooter', 'Aim, pop, chain matching bubbles.', 'puzzle', true, 'games/bubbleshooter/index.html', 'hot', 4.6, 50, 2000, 'published', false),
  ('connectfour', 'Connect Four', 'Line up four before your opponent does.', 'puzzle', true, 'games/connectfour/index.html', null, 4.4, 38, 1500, 'published', false),
  ('tictactoe', 'Tic-Tac-Toe', 'The classic, same-device two player.', 'puzzle', true, 'games/tictactoe/index.html', null, 4, 63, 2500, 'published', false),
  ('slidingpuzzle', 'Sliding Puzzle', 'Slide tiles back into perfect order.', 'puzzle', true, 'games/slidingpuzzle/index.html', null, 4.1, 21, 830, 'published', false),
  ('memory', 'Memory Match', 'Flip, remember, find every pair.', 'puzzle', true, 'games/memory/index.html', null, 4.3, 43, 1700, 'published', false),
  ('simonsays', 'Simon Says', 'Watch the pattern, repeat it back.', 'puzzle', true, 'games/simonsays/index.html', null, 4.2, 19, 760, 'published', false),
  ('wordguess', 'Word Guess', 'Crack the hidden word, letter by letter.', 'puzzle', true, 'games/wordguess/index.html', null, 4.3, 30, 1200, 'published', false),
  ('oddoneout', 'Find the Odd One', 'Spot what doesn''t belong, fast.', 'puzzle', true, 'games/oddoneout/index.html', null, 4, 17, 690, 'published', false),
  ('colormatch', 'Match the Color', 'Quick color reflex challenge.', 'puzzle', true, 'games/colormatch/index.html', null, 4.1, 20, 810, 'published', false),
  ('mathsprint', 'Math Sprint', 'Solve fast, beat the clock.', 'puzzle', true, 'games/mathsprint/index.html', null, 4, 15, 590, 'published', false),
  ('numberguess', 'Guess the Number', 'Narrow it down before you''re out of tries.', 'puzzle', true, 'games/numberguess/index.html', null, 3.9, 16, 640, 'published', false),
  ('diceroll', 'Dice Roll', 'Simple stakes, quick rounds.', 'puzzle', true, 'games/diceroll/index.html', null, 3.8, 13, 520, 'published', false),
  ('rps', 'Rock-Paper-Scissors', 'Best of series against the house.', 'puzzle', true, 'games/rps/index.html', null, 3.9, 18, 710, 'published', false),
  ('balloonpop', 'Pop the Balloon', 'Tap fast, don''t miss a single one.', 'action', true, 'games/balloonpop/index.html', null, 4, 17, 680, 'published', false),
  ('speedracer', 'Speed Racer', 'Lane-dodge racing, quick sessions.', 'racing', true, 'games/speedracer/index.html', null, 4.2, 33, 1300, 'published', false),
  ('block-escape', 'Block Escape', 'Push every crate onto its target.', 'puzzle', true, 'games/block-escape/index.html', 'new', 4.4, 11, 430, 'published', false),
  ('robo-arena', 'Robo Arena', 'Tap to strike. Survive every wave.', 'action', true, 'games/robo-arena/index.html', 'new', 4.5, 13, 510, 'published', false),
  ('street-drift-x', 'Street Drift X', 'Hold to drift, chain the multiplier.', 'racing', true, 'games/street-drift-x/index.html', 'hot', 4.6, 12, 470, 'published', false),
  ('cafe-rush', 'Cafe Rush', 'Serve every order before patience runs out.', 'strategy', true, 'games/cafe-rush/index.html', 'new', 4.3, 10, 380, 'published', false),
  ('penalty-clash', 'Penalty Clash', 'Aim the corners, beat the keeper.', 'sports', true, 'games/penalty-clash/index.html', 'new', 4.4, 9, 350, 'published', false)
on conflict (slug) do nothing;
