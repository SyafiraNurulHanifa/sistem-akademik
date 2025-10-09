<?php
// app/Http/Middleware/CheckUserType.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckUserType
{
    public function handle(Request $request, Closure $next, $type)
    {
        // Cek berdasarkan guard yang sesuai
        if (!Auth::guard($type)->check()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses ditolak. Anda tidak memiliki izin untuk mengakses route ini.'
            ], 403);
        }

        return $next($request);
    }
}