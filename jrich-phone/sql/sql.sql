-- jrich-phone Database Installation Script
-- Version: 2.0.0

-- Enhanced Contacts Table
CREATE TABLE IF NOT EXISTS `jrich_phone_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `number` varchar(20) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `favorite` tinyint(1) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_number` (`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Enhanced Messages Table
CREATE TABLE IF NOT EXISTS `jrich_phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_number` varchar(20) NOT NULL,
  `receiver_number` varchar(20) NOT NULL,
  `message` text NOT NULL,
  `read_status` tinyint(1) DEFAULT 0,
  `message_type` enum('text','image','location') DEFAULT 'text',
  `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sender` (`sender_number`),
  KEY `idx_receiver` (`receiver_number`),
  KEY `idx_conversation` (`sender_number`, `receiver_number`),
  KEY `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Enhanced Transaction History
CREATE TABLE IF NOT EXISTS `jrich_phone_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `amount` int(11) NOT NULL,
  `type` enum('deposit','withdraw','transfer_in','transfer_out','payment') NOT NULL,
  `reason` varchar(255) NOT NULL,
  `target` varchar(50) DEFAULT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_type` (`type`),
  KEY `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Call Logs Table
CREATE TABLE IF NOT EXISTS `jrich_phone_call_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caller` varchar(20) NOT NULL,
  `receiver` varchar(20) NOT NULL,
  `status` enum('initiated','answered','missed','ended','busy') NOT NULL,
  `duration` int(11) DEFAULT 0,
  `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_caller` (`caller`),
  KEY `idx_receiver` (`receiver`),
  KEY `idx_status` (`status`),
  KEY `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Phone Settings Table
CREATE TABLE IF NOT EXISTS `jrich_phone_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_citizen_setting` (`citizenid`, `setting_key`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Phone Apps Table (for custom apps)
CREATE TABLE IF NOT EXISTS `jrich_phone_apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_name` varchar(100) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `app_icon` varchar(255) DEFAULT NULL,
  `app_color` varchar(7) DEFAULT '#007AFF',
  `app_route` varchar(255) NOT NULL,
  `app_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `requires_permission` varchar(100) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_app_name` (`app_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User App Permissions
CREATE TABLE IF NOT EXISTS `jrich_phone_user_apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `app_name` varchar(100) NOT NULL,
  `is_installed` tinyint(1) DEFAULT 1,
  `position` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_app` (`citizenid`, `app_name`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Phone Notes/Memos
CREATE TABLE IF NOT EXISTS `jrich_phone_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `color` varchar(7) DEFAULT '#FFD700',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Photo Gallery
CREATE TABLE IF NOT EXISTS `jrich_phone_gallery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `image_url` varchar(500) NOT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Default Apps
INSERT INTO `jrich_phone_apps` (`app_name`, `app_label`, `app_icon`, `app_color`, `app_route`, `app_order`) VALUES
('phone', 'Phone', '📞', '#4CAF50', '/phone', 1),
('messages', 'Messages', '💬', '#2196F3', '/messages', 2),
('contacts', 'Contacts', '👥', '#FF9800', '/contacts', 3),
('bank', 'Bank', '🏦', '#795548', '/bank', 4),
('garage', 'Garage', '🚗', '#9C27B0', '/garage', 5),
('settings', 'Settings', '⚙️', '#607D8B', '/settings', 6),
('camera', 'Camera', '📷', '#000000', '/camera', 7),
('gallery', 'Gallery', '🖼️', '#E91E63', '/gallery', 8),
('notes', 'Notes', '📝', '#FFD700', '/notes', 9),
('calculator', 'Calculator', '🧮', '#FF5722', '/calculator', 10)
ON DUPLICATE KEY UPDATE 
  `app_label` = VALUES(`app_label`),
  `app_icon` = VALUES(`app_icon`),
  `app_color` = VALUES(`app_color`);

-- Insert Default Settings for existing players (if players table exists)
INSERT IGNORE INTO `jrich_phone_settings` (`citizenid`, `setting_key`, `setting_value`)
SELECT `citizenid`, 'wallpaper', 'default_wallpaper.png' FROM `players`
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'players')
UNION ALL
SELECT `citizenid`, 'ringtone', 'ringtone.ogg' FROM `players`
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'players');

-- Add indexes for better performance on large datasets
CREATE INDEX `idx_messages_conversation` ON `jrich_phone_messages` (`sender_number`, `receiver_number`, `timestamp`);
CREATE INDEX `idx_call_logs_recent` ON `jrich_phone_call_logs` (`caller`, `timestamp` DESC);
CREATE INDEX `idx_transactions_recent` ON `jrich_phone_transactions` (`citizenid`, `timestamp` DESC);

-- Views for easier querying
CREATE OR REPLACE VIEW `v_phone_conversations` AS
SELECT 
    CASE 
        WHEN sender_number < receiver_number 
        THEN CONCAT(sender_number, '-', receiver_number)
        ELSE CONCAT(receiver_number, '-', sender_number)
    END as conversation_id,
    sender_number,
    receiver_number,
    message,
    read_status,
    timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY CASE 
            WHEN sender_number < receiver_number 
            THEN CONCAT(sender_number, '-', receiver_number)
            ELSE CONCAT(receiver_number, '-', sender_number)
        END 
        ORDER BY timestamp DESC
    ) as msg_order
FROM `jrich_phone_messages`
ORDER BY timestamp DESC;

CREATE OR REPLACE VIEW `v_recent_calls` AS
SELECT 
    c.*,
    CASE 
        WHEN c.status = 'answered' AND c.duration > 0 THEN 'completed'
        WHEN c.status = 'initiated' THEN 'missed'
        ELSE c.status
    END as call_status,
    CASE 
        WHEN c.duration > 0 THEN CONCAT(FLOOR(c.duration/60), 'm ', c.duration%60, 's')
        ELSE 'No answer'
    END as duration_formatted
FROM `jrich_phone_call_logs` c
ORDER BY c.timestamp DESC;