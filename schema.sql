

CREATE DATABASE IF NOT EXISTS `coricare_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `coricare_db`;


CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `phone` VARCHAR(20) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `disease_scans` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `image_path` VARCHAR(255) NOT NULL,
  `disease_name` VARCHAR(100) NOT NULL,
  `confidence_score` DECIMAL(5,2) NOT NULL,
  `severity` VARCHAR(20) NOT NULL,
  `recommendation` TEXT NOT NULL, -- JSON string storing organic, eco-friendly chemical, prevention, water, soil, and recovery time guidelines
  `sustainability_score` INT NOT NULL DEFAULT 100,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_scans_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_user_scans` (`user_id`),
  INDEX `idx_disease` (`disease_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `chat_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `question` TEXT NOT NULL,
  `answer` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_user_chat` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `admins` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `admins` (`id`, `username`, `password`) 
VALUES (1, 'admin', '$2y$10$vKBd/0.l4pTf59s7bN4gYeFmI6s4MvH86wG6Zp5n6qK2S5j8a5j8S')
ON DUPLICATE KEY UPDATE `username`=`username`;


INSERT INTO `users` (`id`, `name`, `email`, `phone`, `password`) 
VALUES (1, 'Ramesh Kumar', 'farmer@coricare.com', '9876543210', '$2y$10$vKBd/0.l4pTf59s7bN4gYeFmI6s4MvH86wG6Zp5n6qK2S5j8a5j8S')
ON DUPLICATE KEY UPDATE `email`=`email`;


INSERT INTO `disease_scans` (`id`, `user_id`, `image_path`, `disease_name`, `confidence_score`, `severity`, `recommendation`, `sustainability_score`, `created_at`)
VALUES 
(1, 1, 'uploads/sample_healthy.jpg', 'Healthy Leaf', 98.40, 'None', 
 '{"organic":"No treatment needed. Continue current farming practices.","chemical":"None required.","prevention":"Practice crop rotation every 2 years. Maintain regular weeding.","water":"Irrigate early morning. Avoid overhead watering.","soil":"Add organic vermicompost to maintain soil health. Check pH regularly (6.0 - 7.0).","recovery":"Immediate"}',
 100, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 1, 'uploads/sample_mildew.jpg', 'Powdery Mildew', 87.50, 'Medium', 
 '{"organic":"Spray neem oil solution (0.5% concentration) or baking soda solution (1 tbsp per gallon of water with a dash of liquid soap).","chemical":"Use sulfur-based bio-fungicides only if infestation exceeds 20% of crop canopy.","prevention":"Space plants 15cm apart to improve air circulation. Prune infected leaves.","water":"Water at the base of the plant to keep foliage dry. Avoid over-watering.","soil":"Avoid excessive nitrogen fertilizer which stimulates lush, susceptible soft growth.","recovery":"7 - 10 days"}',
 85, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 1, 'uploads/sample_spot.jpg', 'Leaf Spot', 92.10, 'High', 
 '{"organic":"Apply copper fungicide spray (approved for organic farming) or garlic extract spray twice a week.","chemical":"If severe, use Chlorothalonil-based fungicides with careful dosage, but organic sprays are preferred to protect soil microbes.","prevention":"Destroy crop debris after harvesting. Avoid working in the field when plants are wet.","water":"Drip irrigation recommended to keep the foliage completely dry.","soil":"Incorporate green manure to improve soil drainage. Poor drainage aggravates leaf spot.","recovery":"14 - 18 days"}',
 75, DATE_SUB(NOW(), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE `id`=`id`;

INSERT INTO `chat_history` (`id`, `user_id`, `question`, `answer`, `created_at`)
VALUES
(1, 1, 'How much water does coriander need?', 'Coriander requires moderate moisture. It should be watered 1-2 times a week depending on weather and soil. Over-watering can lead to stem rot, so ensure well-draining soil and irrigate in the early morning at the base of the plant.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 1, 'What is the best fertilizer for organic coriander?', 'For organic coriander, well-rotted farmyard manure (FYM), compost, or vermicompost applied during soil preparation is best. A light application of neem cake helps prevent soil pests and provides nitrogen naturally.', DATE_SUB(NOW(), INTERVAL 3 DAY))
ON DUPLICATE KEY UPDATE `id`=`id`;
