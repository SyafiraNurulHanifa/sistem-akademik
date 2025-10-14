<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AbsensiGuruController;
use App\Http\Controllers\AuthGuruController;
use App\Http\Controllers\AuthAdminController;
use App\Http\Controllers\GuruController;
use App\Http\Controllers\ProfilGuruController;

// ==========================
// ROUTE TERBUKA
// ==========================

// ---- GURU AUTH ----
Route::post('/guru/register', [AuthGuruController::class, 'store']);
Route::post('/guru/login', [AuthGuruController::class, 'login']);

// ---- ADMIN AUTH ----
Route::post('/admin/register', [AuthAdminController::class, 'register']);
Route::post('/admin/login', [AuthAdminController::class, 'login']);

// ==========================
// ROUTE DENGAN AUTHENTIKASI
// ==========================

// ---- GURU ROUTES ----
Route::middleware('auth:guru')->prefix('guru')->group(function () {
    Route::post('/logout', [AuthGuruController::class, 'logout']);
    Route::post('/logout-all', [AuthGuruController::class, 'logoutAll']);
    
    // Profil
    Route::get('/profile', [ProfilGuruController::class, 'show']);
    Route::put('/profile', [ProfilGuruController::class, 'update']);
    
    // Absensi
    Route::prefix('absensi')->group(function () {
        Route::post('/check-in', [AbsensiGuruController::class, 'checkIn']);
        Route::post('/check-out', [AbsensiGuruController::class, 'checkOut']);
        Route::get('/riwayat', [AbsensiGuruController::class, 'riwayat']);
        Route::get('/dashboard', [AbsensiGuruController::class, 'dashboard']);
    });
});

// ---- ADMIN ROUTES ----
Route::middleware('auth:admin')->prefix('admin')->group(function () {
    // Auth Admin
    Route::post('/logout', [AuthAdminController::class, 'logout']);
    Route::post('/logout-all', [AuthAdminController::class, 'logoutAll']);
    Route::get('/me', [AuthAdminController::class, 'me']);
    
    // Absensi Management
    Route::prefix('absensi')->group(function () {
        Route::post('/', [AbsensiGuruController::class, 'adminStore']);
        Route::get('/{tanggal}', [AbsensiGuruController::class, 'listByDate']);
        Route::put('/edit/{id}', [AbsensiGuruController::class, 'adminUpdate']);
    });
    
    // Guru Management (CRUD)
    Route::prefix('guru')->group(function () {
        Route::get('/', [GuruController::class, 'index']);
        Route::post('/', [GuruController::class, 'store']);
        Route::get('/{id}', [GuruController::class, 'show']);
        Route::put('/{id}', [GuruController::class, 'update']);
        Route::delete('/{id}', [GuruController::class, 'destroy']);
    });
});

// ==========================
// TEST ROUTES
// ==========================
/*Route::get('/test-server', function() {
    return response()->json(['message' => 'Server is running!']);
});

// Test guard-based authentication
Route::get('/test-admin-guard', function() {
    return response()->json([
        'message' => 'Admin guard works!',
        'user_type' => get_class(auth()->user())
    ]);
})->middleware('auth:admin');

Route::get('/test-guru-guard', function() {
    return response()->json([
        'message' => 'Guru guard works!',
        'user_type' => get_class(auth()->user())
    ]);
})->middleware('auth:guru');
*/

// routes/api.php - TEST BASIC DULU
Route::get('/test-simple', function() {
    return response()->json(['message' => 'Basic test works']);
});

// Test tanpa guard dulu
Route::get('/test-no-guard', function() {
    return response()->json(['message' => 'No guard test works']);
});

// Test dengan auth sanctum umum
Route::get('/test-auth-simple', function() {
    $user = auth()->user();
    return response()->json([
        'message' => 'Auth simple works',
        'user_exists' => !is_null($user),
        'user_class' => $user ? get_class($user) : 'No user'
    ]);
})->middleware('auth:sanctum');