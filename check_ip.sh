#!/bin/bash

echo "🌐 Checking your public IP address for Brevo configuration..."
echo "=========================================================="

echo "📡 Your public IP address is:"
curl -s ifconfig.me
echo ""

echo "🔧 To add this IP to Brevo:"
echo "1. Go to https://app.brevo.com/"
echo "2. Navigate to Settings → SMTP & API"
echo "3. Find 'Authorized IPs' section"
echo "4. Add the IP address above"
echo "5. Save changes"
echo ""
echo "⏱️  Note: IP changes may take a few minutes to propagate"
