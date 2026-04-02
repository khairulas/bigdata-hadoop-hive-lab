--
-- Table structure for table `webpage`
--

DROP TABLE IF EXISTS `webpage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `webpage` (
  `web_page_num` int(11) NOT NULL AUTO_INCREMENT,
  `web_page_file_name` varchar(255) NOT NULL,
  `associated_files` varchar(255) NOT NULL,
  PRIMARY KEY (`web_page_num`)
) ENGINE=MyISAM AUTO_INCREMENT=54 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webpage`
--

LOCK TABLES `webpage` WRITE;
/*!40000 ALTER TABLE `webpage` DISABLE KEYS */;
INSERT INTO `webpage` VALUES (1,'sorrento_f00l_sales.html','theme.css,code.js,sorrento_f00l.jpg'),(2,'titanic_2100_sales.html','theme.css,code.js,titanic_2100.jpg'),(3,'meetoo_3.0_sales.html','theme.css,code.js,meetoo_3.0.jpg'),(4,'meetoo_3.1_sales.html','theme.css,code.js,meetoo_3.1.jpg'),(5,'ifruit_1_sales.html','theme.css,code.js,ifruit_1.jpg'),(6,'ifruit_3_sales.html','theme.css,code.js,ifruit_3.jpg'),(7,'ifruit_2_sales.html','theme.css,code.js,ifruit_2.jpg'),(8,'ifruit_5_sales.html','theme.css,code.js,ifruit_5.jpg'),(9,'titanic_1000_sales.html','theme.css,code.js,titanic_1000.jpg'),(10,'meetoo_1.0_sales.html','theme.css,code.js,meetoo_1.0.jpg'),(11,'sorrento_f21l_sales.html','theme.css,code.js,sorrento_f21l.jpg'),(12,'ifruit_4_sales.html','theme.css,code.js,ifruit_4.jpg'),(13,'sorrento_f23l_sales.html','theme.css,code.js,sorrento_f23l.jpg'),(14,'titanic_2200_sales.html','theme.css,code.js,titanic_2200.jpg'),(15,'ronin_novelty_note_1_sales.html','theme.css,code.js,ronin_novelty_note_1.jpg'),(16,'titanic_2500_sales.html','theme.css,code.js,titanic_2500.jpg'),(17,'ronin_novelty_note_3_sales.html','theme.css,code.js,ronin_novelty_note_3.jpg'),(18,'ronin_novelty_note_2_sales.html','theme.css,code.js,ronin_novelty_note_2.jpg'),(19,'ronin_novelty_note_4_sales.html','theme.css,code.js,ronin_novelty_note_4.jpg'),(20,'ifruit_3a_sales.html','theme.css,code.js,ifruit_3a.jpg'),(21,'titanic_2300_sales.html','theme.css,code.js,titanic_2300.jpg'),(22,'sorrento_f24l_sales.html','theme.css,code.js,sorrento_f24l.jpg'),(23,'sorrento_f20l_sales.html','theme.css,code.js,sorrento_f20l.jpg'),(24,'sorrento_f32l_sales.html','theme.css,code.js,sorrento_f32l.jpg'),(25,'sorrento_f22l_sales.html','theme.css,code.js,sorrento_f22l.jpg'),(26,'sorrento_f30l_sales.html','theme.css,code.js,sorrento_f30l.jpg'),(27,'sorrento_f10l_sales.html','theme.css,code.js,sorrento_f10l.jpg'),(28,'titanic_4000_sales.html','theme.css,code.js,titanic_4000.jpg'),(29,'sorrento_f41l_sales.html','theme.css,code.js,sorrento_f41l.jpg'),(30,'titanic_deckchairs_sales.html','theme.css,code.js,titanic_deckchairs.jpg'),(31,'meetoo_4.1_sales.html','theme.css,code.js,meetoo_4.1.jpg'),(32,'meetoo_4.0_sales.html','theme.css,code.js,meetoo_4.0.jpg'),(33,'meetoo_2.0_sales.html','theme.css,code.js,meetoo_2.0.jpg'),(34,'titanic_2000_sales.html','theme.css,code.js,titanic_2000.jpg'),(35,'meetoo_5.0_sales.html','theme.css,code.js,meetoo_5.0.jpg'),(36,'meetoo_5.1_sales.html','theme.css,code.js,meetoo_5.1.jpg'),(37,'titanic_3000_sales.html','theme.css,code.js,titanic_3000.jpg'),(38,'titanic_1100_sales.html','theme.css,code.js,titanic_1100.jpg'),(39,'sorrento_f33l_sales.html','theme.css,code.js,sorrento_f33l.jpg'),(40,'ifruit_4a_sales.html','theme.css,code.js,ifruit_4a.jpg'),(41,'sorrento_f31l_sales.html','theme.css,code.js,sorrento_f31l.jpg'),(42,'sorrento_f40l_sales.html','theme.css,code.js,sorrento_f40l.jpg'),(43,'sorrento_f01l_sales.html','theme.css,code.js,sorrento_f01l.jpg'),(44,'sorrento_f11l_sales.html','theme.css,code.js,sorrento_f11l.jpg'),(45,'titanic_2400_sales.html','theme.css,code.js,titanic_2400.jpg'),(46,'ronin_s4_sales.html','theme.css,code.js,ronin_s4.jpg'),(47,'ronin_s1_sales.html','theme.css,code.js,ronin_s1.jpg'),(48,'ronin_s3_sales.html','theme.css,code.js,ronin_s3.jpg'),(49,'ronin_s2_sales.html','theme.css,code.js,ronin_s2.jpg'),(50,'ifruit_5a_sales.html','theme.css,code.js,ifruit_5a.jpg'),(51,'contactus.html','theme.css,code.js'),(52,'coveragemap.html','theme.css,code.js,map.jpg'),(53,'discounts.html','theme.css,code.js,promo.jpg');
/*!40000 ALTER TABLE `webpage` ENABLE KEYS */;
UNLOCK TABLES;