CREATE TABLE `project_recipients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `score` int(11) NOT NULL DEFAULT '40',
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `domain` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `suppression_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `delivered_count` int(11) NOT NULL DEFAULT '0',
  `opened_at` datetime DEFAULT NULL,
  `opened_count` int(11) NOT NULL DEFAULT '0',
  `clicked_at` datetime DEFAULT NULL,
  `clicked_count` int(11) NOT NULL DEFAULT '0',
  `soft_bounce_at` datetime DEFAULT NULL,
  `soft_bounce_count` int(11) NOT NULL DEFAULT '0',
  `hard_bounce_at` datetime DEFAULT NULL,
  `hard_bounce_count` int(11) NOT NULL DEFAULT '0',
  `opt_out_at` datetime DEFAULT NULL,
  `opt_out_count` int(11) NOT NULL DEFAULT '0',
  `spam_report_at` datetime DEFAULT NULL,
  `spam_report_count` int(11) NOT NULL DEFAULT '0',
  `tx_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tx_message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `result_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `provider_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_project_recipients_on_token` (`token`),
  UNIQUE KEY `index_project_recipients_on_project_id_and_email` (`project_id`,`email`),
  KEY `index_project_recipients_on_project_id_and_domain` (`project_id`,`domain`),
  KEY `index_project_recipients_on_project_id_and_score` (`project_id`,`score`),
  KEY `index_project_recipients_on_project_id_and_provider_id` (`project_id`,`provider_id`),
  KEY `index_project_recipients_on_project_id_and_suppression_state` (`project_id`,`suppression_state`),
  KEY `index_project_recipients_on_project_id` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=298153427 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci