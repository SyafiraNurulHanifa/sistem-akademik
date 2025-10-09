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
Route::post('/guru/register', [AuthGuruController::class, 'store']); // Bisa untuk admin atau self-register
Route::post('/guru/login', [AuthGuruController::class, 'login']);

// ---- ADMIN AUTH ----
Route::post('/admin/register', [AuthAdminController::class, 'register']);
Route::post('/admin/login', [AuthAdminController::class, 'login']);

// ==========================
// ROUTE DENGAN AUTHENTIKASI & AUTHORIZATION
// ==========================

// ---- GURU ROUTES ----
Route::middleware(['auth:guru', 'check.type:guru'])->prefix('guru')->group(function () {
    Route::post('/logout', [AuthGuruController::class, 'logout']);
    
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
Route::middleware(['auth:admin', 'check.type:admin'])->prefix('admin')->group(function () {
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
    
    // Guru Management (CRUD) - MENGGUNAKAN GURU CONTROLLER
    Route::prefix('guru')->group(function () {
        Route::get('/', [GuruController::class, 'index']);
        Route::post('/', [GuruController::class, 'store']); // Admin create guru
        Route::get('/{id}', [GuruController::class, 'show']);
        Route::put('/{id}', [GuruController::class, 'update']);
        Route::delete('/{id}', [GuruController::class, 'destroy']);
    });
});


//route test
// Test route untuk cek middleware
Route::get('/test-admin', function() {
    return response()->json(['message' => 'Admin middleware works!']);
})->middleware(['auth:admin', 'check.type:admin']);

Route::get('/test-guru', function() {
    return response()->json(['message' => 'Guru middleware works!']);
})->middleware(['auth:guru', 'check.type:guru']);

Route::get('/test-checktype-admin', function() {
    return response()->json(['message' => 'Middleware check.type admin works!']);
})->middleware('check.type:admin');