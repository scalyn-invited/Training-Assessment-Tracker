-- Training Assessment Tracker
-- MySQL 8.0+ / MariaDB 10.5+ import for a NEW, dedicated database.
--
-- Import this file once through cPanel phpMyAdmin. It creates the schema and
-- disposable demonstration records. It intentionally does NOT drop tables.
-- Do not import it into a database that already contains tracker data.

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `role` enum('administrator','member') NOT NULL DEFAULT 'member',
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_index` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `skills` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `skills_name_unique` (`name`),
  KEY `skills_is_active_index` (`is_active`),
  KEY `skills_created_by_foreign` (`created_by`),
  CONSTRAINT `skills_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `development_plans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `cycle_number` int unsigned NOT NULL DEFAULT 1,
  `key_gaps` text NOT NULL,
  `weekly_focus` text NOT NULL,
  `status` enum('draft','active','completed') NOT NULL DEFAULT 'draft',
  `activated_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `development_plans_user_id_cycle_number_unique` (`user_id`,`cycle_number`),
  KEY `development_plans_status_index` (`status`),
  KEY `development_plans_user_id_status_index` (`user_id`,`status`),
  KEY `development_plans_created_by_foreign` (`created_by`),
  CONSTRAINT `development_plans_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `development_plans_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assessments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `development_plan_id` bigint unsigned NOT NULL,
  `skill_id` bigint unsigned NOT NULL,
  `type` enum('baseline','final') NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `note` text DEFAULT NULL,
  `recorded_by` bigint unsigned DEFAULT NULL,
  `recorded_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assessments_plan_skill_type_unique` (`development_plan_id`,`skill_id`,`type`),
  KEY `assessments_plan_type_index` (`development_plan_id`,`type`),
  KEY `assessments_skill_id_foreign` (`skill_id`),
  KEY `assessments_recorded_by_foreign` (`recorded_by`),
  CONSTRAINT `assessments_development_plan_id_foreign` FOREIGN KEY (`development_plan_id`) REFERENCES `development_plans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assessments_skill_id_foreign` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `assessments_recorded_by_foreign` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `weekly_entries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `development_plan_id` bigint unsigned NOT NULL,
  `week_number` tinyint unsigned NOT NULL,
  `skill_id` bigint unsigned NOT NULL,
  `objective` text NOT NULL,
  `evidence` text DEFAULT NULL,
  `outcome_score` decimal(5,2) DEFAULT NULL,
  `status` enum('planned','evidenced','closed') NOT NULL DEFAULT 'planned',
  `recorded_by` bigint unsigned DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `weekly_entries_plan_week_unique` (`development_plan_id`,`week_number`),
  KEY `weekly_entries_status_week_index` (`status`,`week_number`),
  KEY `weekly_entries_skill_id_foreign` (`skill_id`),
  KEY `weekly_entries_recorded_by_foreign` (`recorded_by`),
  CONSTRAINT `weekly_entries_development_plan_id_foreign` FOREIGN KEY (`development_plan_id`) REFERENCES `development_plans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `weekly_entries_skill_id_foreign` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `weekly_entries_recorded_by_foreign` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- The imported records are deliberately disposable demo fixtures.
-- Every account initially uses the password: password
-- Change these passwords before giving anyone access to the public site.
INSERT INTO `users` (`id`,`name`,`email`,`email_verified_at`,`role`,`password`,`remember_token`,`created_at`,`updated_at`) VALUES
  (1,'Programme Administrator','admin@example.test','2026-09-19 00:00:00','administrator','$2y$10$wDKQpFhi/7SJ65lP1HCrO.AyPO7aPBVGRaNJS1ehVhwqpESpbBetK',NULL,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (2,'Member In Draft','draft.member@example.test','2026-09-19 00:00:00','member','$2y$10$wDKQpFhi/7SJ65lP1HCrO.AyPO7aPBVGRaNJS1ehVhwqpESpbBetK',NULL,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (3,'Member In Progress','active.member@example.test','2026-09-19 00:00:00','member','$2y$10$wDKQpFhi/7SJ65lP1HCrO.AyPO7aPBVGRaNJS1ehVhwqpESpbBetK',NULL,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (4,'Member Completed','completed.member@example.test','2026-09-19 00:00:00','member','$2y$10$wDKQpFhi/7SJ65lP1HCrO.AyPO7aPBVGRaNJS1ehVhwqpESpbBetK',NULL,'2026-09-19 00:00:00','2026-09-19 00:00:00');

INSERT INTO `skills` (`id`,`name`,`description`,`is_active`,`created_by`,`created_at`,`updated_at`) VALUES
  (1,'JavaScript Fundamentals','Arrays, objects, async/await, fetch and error handling.',1,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (2,'Laravel Framework','Routing, controllers, requests, migrations and Eloquent.',1,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (3,'REST API Design','Verbs, status codes, resources and structured error responses.',1,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (4,'Database and ORM','Relational modelling, eager loading, N+1 and indexes.',1,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (5,'Automated Testing','Feature and unit tests with Pest or PHPUnit.',1,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (6,'Modern App Development','Git discipline, tooling, CI and deployment.',1,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (7,'Legacy jQuery Maintenance','Retired from the current cycle; historical assessments remain intact.',0,1,'2026-09-19 00:00:00','2026-09-19 00:00:00');

INSERT INTO `development_plans` (`id`,`user_id`,`cycle_number`,`key_gaps`,`weekly_focus`,`status`,`activated_at`,`completed_at`,`created_by`,`created_at`,`updated_at`) VALUES
  (1,2,1,'Async control flow and API error handling.','One JavaScript domain per week, evidenced by committed exercises.','draft',NULL,NULL,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (2,3,1,'Database reasoning and automated testing.','Query counts measured before and after every change.','active','2026-09-10 00:00:00',NULL,1,'2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (3,4,1,'Authorisation modelling and deployment.','One shipped, reviewable increment per week.','completed','2026-08-10 00:00:00','2026-09-10 00:00:00',1,'2026-09-19 00:00:00','2026-09-19 00:00:00');

INSERT INTO `assessments` (`id`,`development_plan_id`,`skill_id`,`type`,`score`,`note`,`recorded_by`,`recorded_at`,`created_at`,`updated_at`) VALUES
  (1,1,1,'baseline',42.00,NULL,1,'2026-09-19 00:00:00','2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (2,1,2,'baseline',48.00,NULL,1,'2026-09-19 00:00:00','2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (3,1,3,'baseline',45.00,NULL,1,'2026-09-19 00:00:00','2026-09-19 00:00:00','2026-09-19 00:00:00'),
  (4,2,1,'baseline',50.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (5,2,2,'baseline',46.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (6,2,3,'baseline',52.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (7,2,4,'baseline',44.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (8,2,5,'baseline',49.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (9,2,6,'baseline',51.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (10,3,1,'baseline',40.00,NULL,1,'2026-08-10 00:00:00','2026-08-10 00:00:00','2026-08-10 00:00:00'),
  (11,3,1,'final',70.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (12,3,2,'baseline',45.00,NULL,1,'2026-08-10 00:00:00','2026-08-10 00:00:00','2026-08-10 00:00:00'),
  (13,3,2,'final',72.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (14,3,3,'baseline',48.00,NULL,1,'2026-08-10 00:00:00','2026-08-10 00:00:00','2026-08-10 00:00:00'),
  (15,3,3,'final',74.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (16,3,4,'baseline',42.00,NULL,1,'2026-08-10 00:00:00','2026-08-10 00:00:00','2026-08-10 00:00:00'),
  (17,3,4,'final',71.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (18,3,5,'baseline',50.00,NULL,1,'2026-08-10 00:00:00','2026-08-10 00:00:00','2026-08-10 00:00:00'),
  (19,3,5,'final',76.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00'),
  (20,3,6,'baseline',47.00,NULL,1,'2026-08-10 00:00:00','2026-08-10 00:00:00','2026-08-10 00:00:00'),
  (21,3,6,'final',75.00,NULL,1,'2026-09-10 00:00:00','2026-09-10 00:00:00','2026-09-10 00:00:00');

INSERT INTO `weekly_entries` (`id`,`development_plan_id`,`week_number`,`skill_id`,`objective`,`evidence`,`outcome_score`,`status`,`recorded_by`,`closed_at`,`created_at`,`updated_at`) VALUES
  (1,2,1,1,'Demonstrate JavaScript transformation and async error handling.','Completed exercise and review notes.',68.00,'closed',1,'2026-09-11 00:00:00','2026-09-10 00:00:00','2026-09-11 00:00:00'),
  (2,2,2,2,'Trace a Laravel request through routing, validation and persistence.','Implemented and tested the request lifecycle exercise.',70.00,'closed',1,'2026-09-12 00:00:00','2026-09-11 00:00:00','2026-09-12 00:00:00'),
  (3,2,3,3,'Apply API status and error-envelope conventions.','Endpoint checks and test output recorded.',NULL,'evidenced',1,NULL,'2026-09-12 00:00:00','2026-09-12 00:00:00'),
  (4,3,1,1,'Complete the JavaScript foundation exercise.','Exercise and review evidence recorded.',70.00,'closed',1,'2026-08-12 00:00:00','2026-08-10 00:00:00','2026-08-12 00:00:00'),
  (5,3,2,2,'Build and explain the Laravel workflow.','Feature tests and technical notes recorded.',72.00,'closed',1,'2026-08-19 00:00:00','2026-08-17 00:00:00','2026-08-19 00:00:00'),
  (6,3,3,3,'Apply REST API design rules.','HTTP verification recorded.',74.00,'closed',1,'2026-08-26 00:00:00','2026-08-24 00:00:00','2026-08-26 00:00:00'),
  (7,3,4,4,'Review database relationships and query behaviour.','Relationship and query evidence recorded.',71.00,'closed',1,'2026-09-02 00:00:00','2026-08-31 00:00:00','2026-09-02 00:00:00'),
  (8,3,5,5,'Complete automated regression checks.','Unit and feature test evidence recorded.',76.00,'closed',1,'2026-09-05 00:00:00','2026-09-03 00:00:00','2026-09-05 00:00:00'),
  (9,3,6,6,'Prepare the application for review and deployment.','Deployment readiness notes recorded.',75.00,'closed',1,'2026-09-10 00:00:00','2026-09-08 00:00:00','2026-09-10 00:00:00');

INSERT INTO `migrations` (`migration`,`batch`) VALUES
  ('0001_01_01_000000_create_users_table',1),
  ('0001_01_01_000001_create_cache_table',1),
  ('0001_01_01_000002_create_jobs_table',1),
  ('2026_09_07_100000_add_role_to_users_table',1),
  ('2026_09_07_100100_create_skills_table',1),
  ('2026_09_07_100200_create_development_plans_table',1),
  ('2026_09_07_100300_create_assessments_table',1),
  ('2026_09_07_100400_create_weekly_entries_table',1),
  ('2026_09_08_103255_create_personal_access_tokens_table',1),
  ('2026_09_17_000000_add_cycles_to_development_plans',1);
