<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Subject;
use Illuminate\Http\Response;

class SubjectController extends Controller
{
    /**
     * GET /api/subjects
     * Ambil semua data mata pelajaran
     */
    public function index()
    {
        $subjects = Subject::all();
        return response()->json([
            'status'  => 'success',
            'message' => 'Daftar mata pelajaran berhasil diambil',
            'data'    => $subjects
        ], Response::HTTP_OK);
    }

    /**
     * POST /api/subjects
     * Tambah mata pelajaran baru
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255|unique:subjects,name',
        ]);

        $subject = Subject::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Mata pelajaran berhasil ditambahkan',
            'data'    => $subject
        ], Response::HTTP_CREATED);
    }

    /**
     * GET /api/subjects/{id}
     * Ambil detail mata pelajaran
     */
    public function show($id)
    {
        $subject = Subject::findOrFail($id);
        return response()->json([
            'status'  => 'success',
            'message' => 'Detail mata pelajaran berhasil diambil',
            'data'    => $subject
        ], Response::HTTP_OK);
    }

    /**
     * PUT /api/subjects/{id}
     * Update data mata pelajaran
     */
    public function update(Request $request, $id)
    {
        $subject = Subject::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255|unique:subjects,name,' . $subject->id,
        ]);

        $subject->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Mata pelajaran berhasil diperbarui',
            'data'    => $subject
        ], Response::HTTP_OK);
    }

    /**
     * DELETE /api/subjects/{id}
     * Hapus mata pelajaran
     */
    public function destroy($id)
    {
        $subject = Subject::findOrFail($id);
        $subject->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Mata pelajaran berhasil dihapus',
        ], Response::HTTP_OK);
    }
}