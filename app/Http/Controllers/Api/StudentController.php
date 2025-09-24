<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Student;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\SchoolClass;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Http\Response;

class StudentController extends Controller
{
    /**
     * GET /api/students
     * Ambil semua data siswa beserta user dan kelasnya
     */
    public function index()
    {
        $students = Student::with(['user.profile', 'schoolClass'])->get();
        return response()->json([
            'status'  => 'success',
            'message' => 'Daftar siswa berhasil diambil',
            'data'    => $students
        ], Response::HTTP_OK);
    }

    /**
     * POST /api/students
     * Tambah siswa baru
     */
    public function store(Request $request)
    {
        $request->validate([
            'full_name'    => 'required|string|max:255',
            'email'        => 'required|string|email|unique:users,email',
            'password'     => 'required|string|min:6',
            'nisn'         => 'required|string|unique:students,nisn',
            'class_id'     => 'required|integer|exists:classes,id',
            'address'      => 'nullable|string',
            'phone_number' => 'nullable|string',
        ]);

        try {
            // Gunakan transaction untuk memastikan semua data tersimpan
            DB::beginTransaction();

            $user = User::create([
                'name'     => $request->full_name,
                'email'    => $request->email,
                'password' => Hash::make($request->password),
            ]);

            UserProfile::create([
                'user_id'      => $user->id,
                'full_name'    => $request->full_name,
                'address'      => $request->address,
                'phone_number' => $request->phone_number,
            ]);

            Student::create([
                'user_id'  => $user->id,
                'nisn'     => $request->nisn,
                'class_id' => $request->class_id,
            ]);

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Siswa berhasil ditambahkan',
            ], Response::HTTP_CREATED);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal menambahkan siswa',
                'error'   => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * GET /api/students/{id}
     * Ambil detail siswa
     */
    public function show($id)
    {
        $student = Student::with(['user.profile', 'schoolClass'])->findOrFail($id);
        return response()->json([
            'status'  => 'success',
            'message' => 'Detail siswa berhasil diambil',
            'data'    => $student
        ], Response::HTTP_OK);
    }

    /**
     * PUT /api/students/{id}
     * Update data siswa
     */
    public function update(Request $request, $id)
    {
        $student = Student::findOrFail($id);
        $user = $student->user;

        $request->validate([
            'full_name'    => 'sometimes|required|string|max:255',
            'email'        => 'sometimes|required|string|email|unique:users,email,' . $user->id,
            'password'     => 'nullable|string|min:6',
            'nisn'         => 'sometimes|required|string|unique:students,nisn,' . $student->id,
            'class_id'     => 'sometimes|required|integer|exists:classes,id',
            'address'      => 'nullable|string',
            'phone_number' => 'nullable|string',
        ]);

        try {
            DB::beginTransaction();

            if ($request->has('full_name')) {
                $user->name = $request->full_name;
                $user->profile->full_name = $request->full_name;
            }
            if ($request->has('email')) {
                $user->email = $request->email;
            }
            if ($request->has('password') && $request->password !== null) {
                $user->password = Hash::make($request->password);
            }
            $user->save();
            $user->profile->save();

            $student->nisn = $request->nisn ?? $student->nisn;
            $student->class_id = $request->class_id ?? $student->class_id;
            $student->save();

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Data siswa berhasil diperbarui',
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal memperbarui data siswa',
                'error'   => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * DELETE /api/students/{id}
     * Hapus siswa
     */
    public function destroy($id)
    {
        $student = Student::findOrFail($id);
        $user = $student->user;

        $student->delete();
        $user->profile->delete();
        $user->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Siswa berhasil dihapus',
        ], Response::HTTP_OK);
    }
}