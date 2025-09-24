<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string  $role
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();

        // Pastikan user login & punya role sesuai
        if (!$user || $user->role !== $role) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Anda tidak memiliki akses ke halaman ini'
            ], 403);
        }

        return $next($request);
    }
}
