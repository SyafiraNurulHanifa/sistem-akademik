<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GuruController;

// Cek API
Route::get('/test', fn () => response()->json(['message' => 'API Laravel sudah jalan 🚀']));

// CRUD Guru
Route::apiResource('guru', GuruController::class);
