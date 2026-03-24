#!/bin/bash
# Admin Dashboard Setup Verification

echo "🔍 Checking admin dashboard setup..."
echo ""

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "❌ .env.local file not found"
    echo "📋 Please create it by running:"
    echo "   cp .env.example .env.local"
    exit 1
fi

echo "✅ .env.local found"

# Check if SUPABASE_URL is set
if ! grep -q "NEXT_PUBLIC_SUPABASE_URL=" .env.local; then
    echo "❌ NEXT_PUBLIC_SUPABASE_URL not set"
    exit 1
fi

# Check if SUPABASE_KEY is set
if ! grep -q "NEXT_PUBLIC_SUPABASE_ANON_KEY=" .env.local; then
    echo "❌ NEXT_PUBLIC_SUPABASE_ANON_KEY not set"
    exit 1
fi

# Check if placeholder key is still there
if grep -q "PLACEHOLDER" .env.local; then
    echo "⚠️  PLACEHOLDER_REPLACE_WITH_YOUR_ACTUAL_KEY found"
    echo ""
    echo "📍 Steps to fix:"
    echo "1. Go to https://app.supabase.com"
    echo "2. Select project 'xbrlpovbwwyjvefblmuz'"
    echo "3. Click Settings → API"
    echo "4. Copy the 'anon' key"
    echo "5. Replace PLACEHOLDER_REPLACE_WITH_YOUR_ACTUAL_KEY in .env.local"
    exit 1
fi

echo "✅ NEXT_PUBLIC_SUPABASE_URL configured"
echo "✅ NEXT_PUBLIC_SUPABASE_ANON_KEY configured"
echo ""
echo "✨ Setup complete! Run 'npm run dev' to start"
