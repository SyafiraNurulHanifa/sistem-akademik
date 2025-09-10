<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/test-storage', function () {
    // Simpan file dummy ke storage/app/public
    $path = 'test-folder/dummy.txt';
    Storage::disk('public')->put($path, 'Hello from Laravel Storage!');

    // Dapatkan URL publiknya
    $url = Storage::url($path);

    return response()->json([
        'message' => 'File berhasil dibuat di storage/app/public',
        'path' => $path,
        'url' => url($url),
    ]);
});