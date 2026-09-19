<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('development_plans', function (Blueprint $table) {
            $table->dropUnique(['user_id']);
            $table->unsignedInteger('cycle_number')->default(1)->after('user_id');
            $table->unique(['user_id', 'cycle_number']);
            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('development_plans', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'status']);
            $table->dropUnique(['user_id', 'cycle_number']);
            $table->dropColumn('cycle_number');
            $table->unique('user_id');
        });
    }
};
