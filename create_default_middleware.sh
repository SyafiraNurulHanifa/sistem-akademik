#!/usr/bin/env bash
set -euo pipefail

# Jalankan dari root project Laravel
PROJECT_DIR="$(pwd)"
MIDDLEWARE_DIR="$PROJECT_DIR/app/Http/Middleware"

echo "Project dir: $PROJECT_DIR"
mkdir -p "$MIDDLEWARE_DIR"

create_file() {
  local path="$1"
  local content="$2"
  if [ -f "$path" ]; then
    echo "SKIP: $path already exists"
  else
    echo "CREATE: $path"
    printf "%s\n" "$content" > "$path"
    chmod 644 "$path"
  fi
}

# TrustProxies.php
create_file "$MIDDLEWARE_DIR/TrustProxies.php" "<?php
namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request;

class TrustProxies extends Middleware
{
    /**
     * The trusted proxies for this application.
     *
     * @var array|string|null
     */
    protected \$proxies;

    /**
     * The headers that should be used to detect proxies.
     *
     * @var int
     */
    protected \$headers = Request::HEADER_X_FORWARDED_FOR
                         | Request::HEADER_X_FORWARDED_HOST
                         | Request::HEADER_X_FORWARDED_PORT
                         | Request::HEADER_X_FORWARDED_PROTO;
}
"

# PreventRequestsDuringMaintenance.php
create_file "$MIDDLEWARE_DIR/PreventRequestsDuringMaintenance.php" "<?php
namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\PreventRequestsDuringMaintenance as Middleware;

class PreventRequestsDuringMaintenance extends Middleware
{
    //
}
"

# TrimStrings.php
create_file "$MIDDLEWARE_DIR/TrimStrings.php" "<?php
namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\TrimStrings as Middleware;

class TrimStrings extends Middleware
{
    /**
     * The names of the attributes that should not be trimmed.
     *
     * @var array
     */
    protected \$except = [
        //
    ];
}
"

# EncryptCookies.php
create_file "$MIDDLEWARE_DIR/EncryptCookies.php" "<?php
namespace App\Http\Middleware;

use Illuminate\Cookie\Middleware\EncryptCookies as Middleware;

class EncryptCookies extends Middleware
{
    /**
     * The names of the cookies that should not be encrypted.
     *
     * @var array
     */
    protected \$except = [
        //
    ];
}
"

# VerifyCsrfToken.php
create_file "$MIDDLEWARE_DIR/VerifyCsrfToken.php" "<?php
namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

class VerifyCsrfToken extends Middleware
{
    /**
     * The URIs that should be excluded from CSRF verification.
     *
     * @var array
     */
    protected \$except = [
        //
    ];
}
"

# Authenticate.php
create_file "$MIDDLEWARE_DIR/Authenticate.php" "<?php
namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \\Illuminate\\Http\\Request  \$request
     * @return string|null
     */
    protected function redirectTo(\$request)
    {
        if (! \$request->expectsJson()) {
            return route('login');
        }
    }
}
"

# RedirectIfAuthenticated.php
create_file "$MIDDLEWARE_DIR/RedirectIfAuthenticated.php" "<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Providers\RouteServiceProvider;

class RedirectIfAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param  \\Illuminate\\Http\\Request  \$request
     * @param  \\Closure  \$next
     * @param  string[]  ...\$guards
     * @return mixed
     */
    public function handle(Request \$request, Closure \$next, ...\$guards)
    {
        \$guards = empty(\$guards) ? [null] : \$guards;

        foreach (\$guards as \$guard) {
            if (Auth::guard(\$guard)->check()) {
                return redirect(RouteServiceProvider::HOME);
            }
        }

        return \$next(\$request);
    }
}
"

echo
echo "Done creating middleware files (if they didn't exist)."
echo "Next steps:"
echo "  1) composer dump-autoload"
echo "  2) php artisan optimize:clear"
echo "  3) Verify app/Http/Kernel.php references these classes"
echo
echo "Running composer dump-autoload and artisan optimize:clear now..."

# Run composer dump-autoload if composer available
if command -v composer >/dev/null 2>&1; then
  composer dump-autoload
fi

# Run artisan optimize:clear if php and artisan exist
if [ -x \"$(command -v php)\" ] && [ -f \"$PROJECT_DIR/artisan\" ]; then
  php artisan optimize:clear || true
fi

echo "All done."

