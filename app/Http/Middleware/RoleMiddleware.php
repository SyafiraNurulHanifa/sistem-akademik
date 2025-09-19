<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Models\Admin;
use App\Models\Guru;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthorized',
            ], 401);
        }

        // --- Cek abilities dari token Sanctum ---
        $abilities = $request->user()->currentAccessToken()->abilities ?? [];
        if (!in_array($role, $abilities)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthorized - role tidak sesuai',
            ], 403);
        }

        // --- Cek instance model ---
        if ($role === 'admin' && $user instanceof Admin) {
            return $next($request);
        }

        if ($role === 'guru' && $user instanceof Guru) {
            return $next($request);
        }

        return response()->json([
            'status'  => 'error',
            'message' => 'Anda tidak memiliki akses ke resource ini',
        ], 403);
    }
}
