-- MySQL dump 10.13  Distrib 8.4.3, for macos14.5 (arm64)
--
-- Host: 127.0.0.1    Database: fastapiadmin
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `app_ai_mcp`
--

DROP TABLE IF EXISTS `app_ai_mcp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_ai_mcp` (
  `name` varchar(50) NOT NULL COMMENT 'MCP 名称',
  `type` int NOT NULL COMMENT 'MCP 类型(0:stdio 1:sse)',
  `url` varchar(255) DEFAULT NULL COMMENT '远程 SSE 地址',
  `command` varchar(255) DEFAULT NULL COMMENT 'MCP 命令',
  `args` varchar(255) DEFAULT NULL COMMENT 'MCP 命令参数',
  `env` json DEFAULT NULL COMMENT 'MCP 环境变量',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_app_ai_mcp_uuid` (`uuid`),
  KEY `ix_app_ai_mcp_updated_time` (`updated_time`),
  KEY `ix_app_ai_mcp_created_id` (`created_id`),
  KEY `ix_app_ai_mcp_status` (`status`),
  KEY `ix_app_ai_mcp_updated_id` (`updated_id`),
  KEY `ix_app_ai_mcp_created_time` (`created_time`),
  KEY `ix_app_ai_mcp_id` (`id`),
  CONSTRAINT `app_ai_mcp_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `app_ai_mcp_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='MCP 服务器表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_ai_mcp`
--

/*!40000 ALTER TABLE `app_ai_mcp` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_ai_mcp` ENABLE KEYS */;

--
-- Table structure for table `app_job`
--

DROP TABLE IF EXISTS `app_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_job` (
  `name` varchar(64) DEFAULT NULL COMMENT '任务名称',
  `jobstore` varchar(64) DEFAULT NULL COMMENT '存储器',
  `executor` varchar(64) DEFAULT NULL COMMENT '执行器:将运行此作业的执行程序的名称',
  `trigger` varchar(64) NOT NULL COMMENT '触发器:控制此作业计划的 trigger 对象',
  `trigger_args` text COMMENT '触发器参数',
  `func` text NOT NULL COMMENT '任务函数',
  `args` text COMMENT '位置参数',
  `kwargs` text COMMENT '关键字参数',
  `coalesce` tinyint(1) DEFAULT NULL COMMENT '是否合并运行:是否在多个运行时间到期时仅运行作业一次',
  `max_instances` int DEFAULT NULL COMMENT '最大实例数:允许的最大并发执行实例数',
  `start_date` varchar(64) DEFAULT NULL COMMENT '开始时间',
  `end_date` varchar(64) DEFAULT NULL COMMENT '结束时间',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_app_job_uuid` (`uuid`),
  KEY `ix_app_job_id` (`id`),
  KEY `ix_app_job_status` (`status`),
  KEY `ix_app_job_created_time` (`created_time`),
  KEY `ix_app_job_updated_id` (`updated_id`),
  KEY `ix_app_job_created_id` (`created_id`),
  KEY `ix_app_job_updated_time` (`updated_time`),
  CONSTRAINT `app_job_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `app_job_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务调度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_job`
--

/*!40000 ALTER TABLE `app_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_job` ENABLE KEYS */;

--
-- Table structure for table `app_job_log`
--

DROP TABLE IF EXISTS `app_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_job_log` (
  `job_name` varchar(64) NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL COMMENT '任务组名',
  `job_executor` varchar(64) NOT NULL COMMENT '任务执行器',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `job_args` varchar(255) DEFAULT NULL COMMENT '位置参数',
  `job_kwargs` varchar(255) DEFAULT NULL COMMENT '关键字参数',
  `job_trigger` varchar(255) DEFAULT NULL COMMENT '任务触发器',
  `job_message` varchar(500) DEFAULT NULL COMMENT '日志信息',
  `exception_info` varchar(2000) DEFAULT NULL COMMENT '异常信息',
  `job_id` int DEFAULT NULL COMMENT '任务ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_app_job_log_uuid` (`uuid`),
  KEY `ix_app_job_log_id` (`id`),
  KEY `ix_app_job_log_status` (`status`),
  KEY `ix_app_job_log_job_id` (`job_id`),
  KEY `ix_app_job_log_updated_time` (`updated_time`),
  KEY `ix_app_job_log_created_time` (`created_time`),
  CONSTRAINT `app_job_log_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `app_job` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务调度日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_job_log`
--

/*!40000 ALTER TABLE `app_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_job_log` ENABLE KEYS */;

--
-- Table structure for table `app_myapp`
--

DROP TABLE IF EXISTS `app_myapp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_myapp` (
  `name` varchar(64) NOT NULL COMMENT '应用名称',
  `access_url` varchar(500) NOT NULL COMMENT '访问地址',
  `icon_url` varchar(300) DEFAULT NULL COMMENT '应用图标URL',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_app_myapp_uuid` (`uuid`),
  KEY `ix_app_myapp_created_id` (`created_id`),
  KEY `ix_app_myapp_status` (`status`),
  KEY `ix_app_myapp_updated_id` (`updated_id`),
  KEY `ix_app_myapp_created_time` (`created_time`),
  KEY `ix_app_myapp_id` (`id`),
  KEY `ix_app_myapp_updated_time` (`updated_time`),
  CONSTRAINT `app_myapp_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `app_myapp_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='应用系统表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_myapp`
--

/*!40000 ALTER TABLE `app_myapp` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_myapp` ENABLE KEYS */;

--
-- Table structure for table `apscheduler_jobs`
--

DROP TABLE IF EXISTS `apscheduler_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `apscheduler_jobs` (
  `id` varchar(191) NOT NULL,
  `next_run_time` double DEFAULT NULL,
  `job_state` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_apscheduler_jobs_next_run_time` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apscheduler_jobs`
--

/*!40000 ALTER TABLE `apscheduler_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `apscheduler_jobs` ENABLE KEYS */;

--
-- Table structure for table `gen_demo`
--

DROP TABLE IF EXISTS `gen_demo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_demo` (
  `name` varchar(64) DEFAULT NULL COMMENT '名称',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_demo_uuid` (`uuid`),
  KEY `ix_gen_demo_created_id` (`created_id`),
  KEY `ix_gen_demo_status` (`status`),
  KEY `ix_gen_demo_updated_id` (`updated_id`),
  KEY `ix_gen_demo_created_time` (`created_time`),
  KEY `ix_gen_demo_id` (`id`),
  KEY `ix_gen_demo_updated_time` (`updated_time`),
  CONSTRAINT `gen_demo_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_demo_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='示例表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_demo`
--

/*!40000 ALTER TABLE `gen_demo` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_demo` ENABLE KEYS */;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_name` varchar(200) NOT NULL COMMENT '表名称',
  `table_comment` varchar(500) DEFAULT NULL COMMENT '表描述',
  `class_name` varchar(100) NOT NULL COMMENT '实体类名称',
  `package_name` varchar(100) DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(100) DEFAULT NULL COMMENT '生成功能名',
  `sub_table_name` varchar(64) DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) DEFAULT NULL COMMENT '子表关联的外键名',
  `parent_menu_id` int DEFAULT NULL COMMENT '父菜单ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_table_uuid` (`uuid`),
  KEY `ix_gen_table_id` (`id`),
  KEY `ix_gen_table_status` (`status`),
  KEY `ix_gen_table_updated_time` (`updated_time`),
  KEY `ix_gen_table_created_id` (`created_id`),
  KEY `ix_gen_table_created_time` (`created_time`),
  KEY `ix_gen_table_updated_id` (`updated_id`),
  CONSTRAINT `gen_table_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_name` varchar(200) NOT NULL COMMENT '列名称',
  `column_comment` varchar(500) DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) NOT NULL COMMENT '列类型',
  `column_length` varchar(50) DEFAULT NULL COMMENT '列长度',
  `column_default` varchar(200) DEFAULT NULL COMMENT '列默认值',
  `is_pk` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否主键',
  `is_increment` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否自增',
  `is_nullable` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否允许为空',
  `is_unique` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否唯一',
  `python_type` varchar(100) DEFAULT NULL COMMENT 'Python类型',
  `python_field` varchar(200) DEFAULT NULL COMMENT 'Python字段名',
  `is_insert` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否为新增字段',
  `is_edit` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否编辑字段',
  `is_list` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否列表字段',
  `is_query` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否查询字段',
  `query_type` varchar(50) DEFAULT NULL COMMENT '查询方式',
  `html_type` varchar(100) DEFAULT NULL COMMENT '显示类型',
  `dict_type` varchar(200) DEFAULT NULL COMMENT '字典类型',
  `sort` int NOT NULL COMMENT '排序',
  `table_id` int NOT NULL COMMENT '归属表编号',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_table_column_uuid` (`uuid`),
  KEY `ix_gen_table_column_updated_id` (`updated_id`),
  KEY `ix_gen_table_column_id` (`id`),
  KEY `ix_gen_table_column_table_id` (`table_id`),
  KEY `ix_gen_table_column_updated_time` (`updated_time`),
  KEY `ix_gen_table_column_created_id` (`created_id`),
  KEY `ix_gen_table_column_status` (`status`),
  KEY `ix_gen_table_column_created_time` (`created_time`),
  CONSTRAINT `gen_table_column_ibfk_1` FOREIGN KEY (`table_id`) REFERENCES `gen_table` (`id`) ON DELETE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `name` varchar(64) NOT NULL COMMENT '部门名称',
  `order` int NOT NULL COMMENT '显示排序',
  `code` varchar(16) DEFAULT NULL COMMENT '部门编码',
  `leader` varchar(32) DEFAULT NULL COMMENT '部门负责人',
  `phone` varchar(11) DEFAULT NULL COMMENT '手机',
  `email` varchar(64) DEFAULT NULL COMMENT '邮箱',
  `parent_id` int DEFAULT NULL COMMENT '父级部门ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_dept_uuid` (`uuid`),
  KEY `ix_sys_dept_id` (`id`),
  KEY `ix_sys_dept_code` (`code`),
  KEY `ix_sys_dept_updated_time` (`updated_time`),
  KEY `ix_sys_dept_parent_id` (`parent_id`),
  KEY `ix_sys_dept_created_id` (`created_id`),
  KEY `ix_sys_dept_status` (`status`),
  KEY `ix_sys_dept_updated_id` (`updated_id`),
  KEY `ix_sys_dept_created_time` (`created_time`),
  CONSTRAINT `sys_dept_ibfk_1` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_dept_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_dept_ibfk_3` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES ('集团总公司',1,'GROUP','部门负责人','1582112620','deptadmin@example.com',NULL,1,'a6edda6b-1430-4dc3-982a-711689f2f2f1','0','集团总公司','2025-12-31 18:43:00','2025-12-31 18:43:00',NULL,NULL);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_sort` int NOT NULL COMMENT '字典排序',
  `dict_label` varchar(255) NOT NULL COMMENT '字典标签',
  `dict_value` varchar(255) NOT NULL COMMENT '字典键值',
  `css_class` varchar(255) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(255) DEFAULT NULL COMMENT '表格回显样式',
  `is_default` tinyint(1) NOT NULL COMMENT '是否默认（True是 False否）',
  `dict_type` varchar(255) NOT NULL COMMENT '字典类型',
  `dict_type_id` int NOT NULL COMMENT '字典类型ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_dict_data_uuid` (`uuid`),
  KEY `dict_type_id` (`dict_type_id`),
  KEY `ix_sys_dict_data_created_time` (`created_time`),
  KEY `ix_sys_dict_data_status` (`status`),
  KEY `ix_sys_dict_data_updated_time` (`updated_time`),
  KEY `ix_sys_dict_data_id` (`id`),
  CONSTRAINT `sys_dict_data_ibfk_1` FOREIGN KEY (`dict_type_id`) REFERENCES `sys_dict_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,'男','0','blue',NULL,1,'sys_user_sex',1,1,'1f24361f-7686-4a26-9e07-3e4d1efbb72d','0','性别男','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'女','1','pink',NULL,0,'sys_user_sex',1,2,'e0927366-fc64-4181-ad25-eb9ad8b88c0c','0','性别女','2025-12-31 18:43:00','2025-12-31 18:43:00'),(3,'未知','2','red',NULL,0,'sys_user_sex',1,3,'299809dd-2920-4bf8-89da-ad7b4ea0656a','0','性别未知','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'是','1','','primary',1,'sys_yes_no',2,4,'19966ee3-5711-46ff-a586-01af44113891','0','是','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'否','0','','danger',0,'sys_yes_no',2,5,'a3763e35-2400-46a2-b348-fec764d8d537','0','否','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'启用','1','','primary',0,'sys_common_status',3,6,'848ba310-f7b7-4b70-8a1d-ded1202df0c3','0','启用状态','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'停用','0','','danger',0,'sys_common_status',3,7,'e367a361-a33e-40d0-84ce-411714c4bf4d','0','停用状态','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'通知','1','blue','warning',1,'sys_notice_type',4,8,'3352c0d6-49ae-4214-a86e-631b33c8b879','0','通知','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'公告','2','orange','success',0,'sys_notice_type',4,9,'451c034e-9b1f-4364-a9fe-28148872f04b','0','公告','2025-12-31 18:43:00','2025-12-31 18:43:00'),(99,'其他','0','','info',0,'sys_oper_type',5,10,'16ec9efe-344a-44cb-9880-ec051b9f7d58','0','其他操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'新增','1','','info',0,'sys_oper_type',5,11,'d7faa6c4-4ef4-4d35-a3d8-9df2197396b5','0','新增操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'修改','2','','info',0,'sys_oper_type',5,12,'559e7a38-0f9f-47c6-97f7-98c16c1a659a','0','修改操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(3,'删除','3','','danger',0,'sys_oper_type',5,13,'9317b4a8-3958-4fd6-ba95-9932c4778b11','0','删除操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(4,'分配权限','4','','primary',0,'sys_oper_type',5,14,'7f000c17-18a9-4b5c-baf3-0a11f3eb75e4','0','授权操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(5,'导出','5','','warning',0,'sys_oper_type',5,15,'aea77c60-c29d-4b67-b269-1c314a8f3437','0','导出操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(6,'导入','6','','warning',0,'sys_oper_type',5,16,'59d992c8-5be7-4c29-b959-94421bc11dda','0','导入操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(7,'强退','7','','danger',0,'sys_oper_type',5,17,'c818fb0f-2c1a-49b1-aeac-9de267d0dcd0','0','强退操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(8,'生成代码','8','','warning',0,'sys_oper_type',5,18,'b2d98b43-92c7-436a-b519-5c75712ba8d7','0','生成操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(9,'清空数据','9','','danger',0,'sys_oper_type',5,19,'54067f1c-b514-48ba-8d26-52a45c4829eb','0','清空操作','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'默认(Memory)','default','',NULL,1,'sys_job_store',6,20,'0a19d103-a7f4-4df6-87d6-2f6dc2c2b9f2','0','默认分组','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'数据库(Sqlalchemy)','sqlalchemy','',NULL,0,'sys_job_store',6,21,'e1473279-63d1-4d47-abf8-c135297757e0','0','数据库分组','2025-12-31 18:43:00','2025-12-31 18:43:00'),(3,'数据库(Redis)','redis','',NULL,0,'sys_job_store',6,22,'3b8d56ef-c9ad-4c0b-ad48-cf9b15b22b4e','0','reids分组','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'线程池','default','',NULL,0,'sys_job_executor',7,23,'ce52ea44-2faf-485f-bb11-f42819f4d05f','0','线程池','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'进程池','processpool','',NULL,0,'sys_job_executor',7,24,'968a5bbd-24de-4987-aefc-739ce917bf2c','0','进程池','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'演示函数','scheduler_test.job','',NULL,1,'sys_job_function',8,25,'a6b50ce7-7015-4019-a53f-0456faa15a69','0','演示函数','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'指定日期(date)','date','',NULL,1,'sys_job_trigger',9,26,'2637beb2-cc96-4128-82f2-4d819ff1d7e1','0','指定日期任务触发器','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'间隔触发器(interval)','interval','',NULL,0,'sys_job_trigger',9,27,'ed4efeed-ad5c-410b-8745-30e928dafe95','0','间隔触发器任务触发器','2025-12-31 18:43:00','2025-12-31 18:43:00'),(3,'cron表达式','cron','',NULL,0,'sys_job_trigger',9,28,'c2b3d7f8-b237-4440-8b74-ce20167d7058','0','间隔触发器任务触发器','2025-12-31 18:43:00','2025-12-31 18:43:00'),(1,'默认(default)','default','',NULL,1,'sys_list_class',10,29,'cca49cc8-f39d-4261-8f6c-1ad8e8371dfd','0','默认表格回显样式','2025-12-31 18:43:00','2025-12-31 18:43:00'),(2,'主要(primary)','primary','',NULL,0,'sys_list_class',10,30,'ddad7b3c-d4e5-4ca4-8533-55a16e73d491','0','主要表格回显样式','2025-12-31 18:43:00','2025-12-31 18:43:00'),(3,'成功(success)','success','',NULL,0,'sys_list_class',10,31,'525a98d1-cf90-4f3d-82bb-66083622e82b','0','成功表格回显样式','2025-12-31 18:43:00','2025-12-31 18:43:00'),(4,'信息(info)','info','',NULL,0,'sys_list_class',10,32,'d909d258-f630-4225-9175-7f399bec97a6','0','信息表格回显样式','2025-12-31 18:43:00','2025-12-31 18:43:00'),(5,'警告(warning)','warning','',NULL,0,'sys_list_class',10,33,'36414fab-4213-468e-9821-f1423c4ea12f','0','警告表格回显样式','2025-12-31 18:43:00','2025-12-31 18:43:00'),(6,'危险(danger)','danger','',NULL,0,'sys_list_class',10,34,'867e7200-e26c-4c2e-940a-2912d2b735ee','0','危险表格回显样式','2025-12-31 18:43:00','2025-12-31 18:43:00');
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_name` varchar(64) NOT NULL COMMENT '字典名称',
  `dict_type` varchar(255) NOT NULL COMMENT '字典类型',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `dict_type` (`dict_type`),
  UNIQUE KEY `ix_sys_dict_type_uuid` (`uuid`),
  KEY `ix_sys_dict_type_id` (`id`),
  KEY `ix_sys_dict_type_updated_time` (`updated_time`),
  KEY `ix_sys_dict_type_status` (`status`),
  KEY `ix_sys_dict_type_created_time` (`created_time`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES ('用户性别','sys_user_sex',1,'6255832f-f237-45a7-a073-deda25c9ea26','0','用户性别列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('系统是否','sys_yes_no',2,'22be7b29-f573-41b7-b0d9-56a2227957c6','0','系统是否列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('系统状态','sys_common_status',3,'2aa43f1d-9982-485f-bb4f-c3ed904e6225','0','系统状态','2025-12-31 18:43:00','2025-12-31 18:43:00'),('通知类型','sys_notice_type',4,'51289e53-2bc3-4c7f-b997-116701e3cc8b','0','通知类型列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('操作类型','sys_oper_type',5,'4dee7e83-8656-4f1b-ab4e-d0cb93b748de','0','操作类型列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('任务存储器','sys_job_store',6,'3d386026-b138-41d1-9340-e08f0e9f279c','0','任务分组列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('任务执行器','sys_job_executor',7,'4fa0ed1f-b530-4518-8f1c-cc1ea0c01c0e','0','任务执行器列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('任务函数','sys_job_function',8,'14a201b4-cfe0-48ce-8916-bf0f96cb60de','0','任务函数列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('任务触发器','sys_job_trigger',9,'d568097d-4086-4793-9d36-8815d1e2e4f5','0','任务触发器列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('表格回显样式','sys_list_class',10,'52b1e307-15cb-4062-ab98-6d2225c80e4f','0','表格回显样式列表','2025-12-31 18:43:00','2025-12-31 18:43:00');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;

--
-- Table structure for table `sys_log`
--

DROP TABLE IF EXISTS `sys_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log` (
  `type` int NOT NULL COMMENT '日志类型(1登录日志 2操作日志)',
  `request_path` varchar(255) NOT NULL COMMENT '请求路径',
  `request_method` varchar(10) NOT NULL COMMENT '请求方式',
  `request_payload` text COMMENT '请求体',
  `request_ip` varchar(50) DEFAULT NULL COMMENT '请求IP地址',
  `login_location` varchar(255) DEFAULT NULL COMMENT '登录位置',
  `request_os` varchar(64) DEFAULT NULL COMMENT '操作系统',
  `request_browser` varchar(64) DEFAULT NULL COMMENT '浏览器',
  `response_code` int NOT NULL COMMENT '响应状态码',
  `response_json` text COMMENT '响应体',
  `process_time` varchar(20) DEFAULT NULL COMMENT '处理时间',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_log_uuid` (`uuid`),
  KEY `ix_sys_log_id` (`id`),
  KEY `ix_sys_log_created_time` (`created_time`),
  KEY `ix_sys_log_status` (`status`),
  KEY `ix_sys_log_created_id` (`created_id`),
  KEY `ix_sys_log_updated_time` (`updated_time`),
  KEY `ix_sys_log_updated_id` (`updated_id`),
  CONSTRAINT `sys_log_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_log_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_log`
--

/*!40000 ALTER TABLE `sys_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_log` ENABLE KEYS */;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `name` varchar(50) NOT NULL COMMENT '菜单名称',
  `type` int NOT NULL COMMENT '菜单类型(1:目录 2:菜单 3:按钮/权限 4:链接)',
  `order` int NOT NULL COMMENT '显示排序',
  `permission` varchar(100) DEFAULT NULL COMMENT '权限标识(如:module_system:user:query)',
  `icon` varchar(50) DEFAULT NULL COMMENT '菜单图标',
  `route_name` varchar(100) DEFAULT NULL COMMENT '路由名称',
  `route_path` varchar(200) DEFAULT NULL COMMENT '路由路径',
  `component_path` varchar(200) DEFAULT NULL COMMENT '组件路径',
  `redirect` varchar(200) DEFAULT NULL COMMENT '重定向地址',
  `hidden` tinyint(1) NOT NULL COMMENT '是否隐藏(True:隐藏 False:显示)',
  `keep_alive` tinyint(1) NOT NULL COMMENT '是否缓存(True:是 False:否)',
  `always_show` tinyint(1) NOT NULL COMMENT '是否始终显示(True:是 False:否)',
  `title` varchar(50) DEFAULT NULL COMMENT '菜单标题',
  `params` json DEFAULT NULL COMMENT '路由参数(JSON对象)',
  `affix` tinyint(1) NOT NULL COMMENT '是否固定标签页(True:是 False:否)',
  `parent_id` int DEFAULT NULL COMMENT '父菜单ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_menu_uuid` (`uuid`),
  KEY `ix_sys_menu_updated_time` (`updated_time`),
  KEY `ix_sys_menu_status` (`status`),
  KEY `ix_sys_menu_created_time` (`created_time`),
  KEY `ix_sys_menu_id` (`id`),
  KEY `ix_sys_menu_parent_id` (`parent_id`),
  CONSTRAINT `sys_menu_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `sys_menu` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES ('仪表盘',1,1,'','client','Dashboard','/dashboard',NULL,'/dashboard/workplace',0,1,1,'仪表盘','null',0,NULL,1,'92ffc574-0a89-4148-9cdc-c6506493a603','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('系统管理',1,2,NULL,'system','System','/system',NULL,'/system/menu',0,1,0,'系统管理','null',0,NULL,2,'a4ec149e-ca12-4871-8612-e15d59bff533','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('应用管理',1,3,NULL,'el-icon-ShoppingBag','Application','/application',NULL,'/application/myapp',0,0,0,'应用管理','null',0,NULL,3,'27503b37-b92d-4d2c-bae2-811fd0128dc2','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('监控管理',1,4,NULL,'monitor','Monitor','/monitor',NULL,'/monitor/online',0,0,0,'监控管理','null',0,NULL,4,'be1cc2a9-b8d3-47d2-abdb-dd4cf529ebef','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('代码管理',1,5,NULL,'code','Generator','/generator',NULL,'/generator/gencode',0,0,0,'代码管理','null',0,NULL,5,'190697eb-9d03-479e-bb18-aba061b7eb7c','0','代码管理','2025-12-31 18:43:00','2025-12-31 18:43:00'),('接口管理',1,6,NULL,'document','Common','/common',NULL,'/common/docs',0,0,0,'接口管理','null',0,NULL,6,'fd79a02c-f704-4772-ada9-635c531a5149','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('案例管理',1,7,NULL,'menu','Example','/example',NULL,'/example/demo',0,0,0,'案例管理','null',0,NULL,7,'f344d5a9-e1db-4446-9c61-11215967f016','0','案例管理','2025-12-31 18:43:00','2025-12-31 18:43:00'),('工作台',2,1,'dashboard:workplace:query','el-icon-PieChart','Workplace','/dashboard/workplace','dashboard/workplace',NULL,0,1,0,'工作台','null',0,1,8,'d43c4a1e-f87a-43e9-9559-559acaf072fe','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('菜单管理',2,1,'module_system:menu:query','menu','Menu','/system/menu','module_system/menu/index',NULL,0,1,0,'菜单管理','null',0,2,9,'5c3fc283-6350-4887-ad61-2e95584a9a12','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('部门管理',2,2,'module_system:dept:query','tree','Dept','/system/dept','module_system/dept/index',NULL,0,1,0,'部门管理','null',0,2,10,'a7852e29-9b19-4b8b-9e32-2d185d052908','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('岗位管理',2,3,'module_system:position:query','el-icon-Coordinate','Position','/system/position','module_system/position/index',NULL,0,1,0,'岗位管理','null',0,2,11,'866985b5-f022-41d8-89f8-95f13626a0bd','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('角色管理',2,4,'module_system:role:query','role','Role','/system/role','module_system/role/index',NULL,0,1,0,'角色管理','null',0,2,12,'04eab4f1-44b9-49b6-940d-08e006dabde5','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('用户管理',2,5,'module_system:user:query','el-icon-User','User','/system/user','module_system/user/index',NULL,0,1,0,'用户管理','null',0,2,13,'f7926df8-73de-4226-95f8-5d8fab0b93b4','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('日志管理',2,6,'module_system:log:query','el-icon-Aim','Log','/system/log','module_system/log/index',NULL,0,1,0,'日志管理','null',0,2,14,'c38426c2-4aad-42ca-8145-721085f63cb7','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告管理',2,7,'module_system:notice:query','bell','Notice','/system/notice','module_system/notice/index',NULL,0,1,0,'公告管理','null',0,2,15,'4d7deaee-0590-413c-bbd7-d3c67a55a096','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('参数管理',2,8,'module_system:param:query','setting','Params','/system/param','module_system/param/index',NULL,0,1,0,'参数管理','null',0,2,16,'022b79c8-759b-4627-9185-513927112947','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('字典管理',2,9,'module_system:dict_type:query','dict','Dict','/system/dict','module_system/dict/index',NULL,0,1,0,'字典管理','null',0,2,17,'20e931e1-dee1-45eb-84f8-27302fe2d72d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('我的应用',2,1,'module_application:myapp:query','el-icon-ShoppingCartFull','MYAPP','/application/myapp','module_application/myapp/index',NULL,0,1,0,'我的应用','null',0,3,18,'a48138d5-0296-4830-bfc7-9821d1a1de05','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('任务管理',2,2,'module_application:job:query','el-icon-DataLine','Job','/application/job','module_application/job/index',NULL,0,1,0,'任务管理','null',0,3,19,'f559ff26-851f-4865-9231-c24003e8d23a','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('AI智能助手',2,3,'module_application:ai:chat','el-icon-ToiletPaper','AI','/application/ai','module_application/ai/index',NULL,0,1,0,'AI智能助手','null',0,3,20,'a95d3d90-c2ca-43bf-9fb2-5b75e3a03ce0','0','AI智能助手','2025-12-31 18:43:00','2025-12-31 18:43:00'),('流程管理',2,4,'module_application:workflow:query','el-icon-ShoppingBag','Workflow','/application/workflow','module_application/workflow/index',NULL,0,1,0,'我的流程','null',0,3,21,'86f200a1-a8f2-4c2e-bb9e-420924cf3fb4','0','我的流程','2025-12-31 18:43:00','2025-12-31 18:43:00'),('在线用户',2,1,'module_monitor:online:query','el-icon-Headset','MonitorOnline','/monitor/online','module_monitor/online/index',NULL,0,0,0,'在线用户','null',0,4,22,'e62957dc-ba30-4a2e-809f-18d144faf4e2','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('服务器监控',2,2,'module_monitor:server:query','el-icon-Odometer','MonitorServer','/monitor/server','module_monitor/server/index',NULL,0,0,0,'服务器监控','null',0,4,23,'60cf5174-aed1-4eda-8412-65eaa5edb2cc','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('缓存监控',2,3,'module_monitor:cache:query','el-icon-Stopwatch','MonitorCache','/monitor/cache','module_monitor/cache/index',NULL,0,0,0,'缓存监控','null',0,4,24,'cd3804f6-4c8b-4356-bf64-ae7b8ae54bb4','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件管理',2,4,'module_monitor:resource:query','el-icon-Files','Resource','/monitor/resource','module_monitor/resource/index',NULL,0,1,0,'文件管理','null',0,4,25,'f4743bbf-1cda-42ec-ab28-c140b9382df2','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('代码生成',2,1,'module_generator:gencode:query','code','GenCode','/generator/gencode','module_generator/gencode/index',NULL,0,1,0,'代码生成','null',0,5,26,'4bf8ae41-ca5b-4dba-afb0-c85fe88b32eb','0','代码生成','2025-12-31 18:43:00','2025-12-31 18:43:00'),('Swagger文档',4,1,'module_common:docs:query','api','Docs','/common/docs','module_common/docs/index',NULL,0,0,0,'Swagger文档','null',0,6,27,'96309d38-78d1-45ee-bd08-86ee65a1161a','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('Redoc文档',4,2,'module_common:redoc:query','el-icon-Document','Redoc','/common/redoc','module_common/redoc/index',NULL,0,0,0,'Redoc文档','null',0,6,28,'18a0ed14-828a-4ecd-a298-c1948f4d8dd9','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('示例管理',2,1,'module_example:demo:query','menu','Demo','/example/demo','module_example/demo/index',NULL,0,1,0,'示例管理','null',0,7,29,'3297a9a6-85d7-441e-8c7c-244329b3a3b8','0','示例管理','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建菜单',3,1,'module_system:menu:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建菜单','null',0,9,30,'2427a9c4-7c8d-43e9-afb0-b85c454578dd','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改菜单',3,2,'module_system:menu:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改菜单','null',0,9,31,'ccab69a8-6162-4b84-8663-a221831bd22d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除菜单',3,3,'module_system:menu:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除菜单','null',0,9,32,'fb4f7ce2-6c64-4fad-aa31-2e843e1550b3','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改菜单状态',3,4,'module_system:menu:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改菜单状态','null',0,9,33,'59d46996-fa85-4618-8db0-25745fc502f0','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情改菜',3,5,'module_system:menu:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情改菜','null',0,9,34,'3073d26a-cc8d-40e8-a155-99f15d56a5fa','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询菜单',3,6,'module_system:menu:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询菜单','null',0,9,35,'c4c99c52-a6b2-4af1-b799-a8a9d516f8af','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建部门',3,1,'module_system:dept:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建部门','null',0,10,36,'d7a1677c-a89e-4cd1-83ff-d2f06c1e6682','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改部门',3,2,'module_system:dept:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改部门','null',0,10,37,'78473709-9434-4df5-af0a-e3b081c5ef90','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除部门',3,3,'module_system:dept:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除部门','null',0,10,38,'6feb287f-5f6d-49c9-9a8b-ed906945aab1','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改部门状态',3,4,'module_system:dept:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改部门状态','null',0,10,39,'8452397f-2d73-4ce5-9f55-f8a924946124','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情部门',3,5,'module_system:dept:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情部门','null',0,10,40,'9fb32063-2810-4b03-96d9-d4dbe489e41c','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询部门',3,6,'module_system:dept:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询部门','null',0,10,41,'58c7d930-116c-4bda-aac8-ce1dfe7a999c','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建岗位',3,1,'module_system:position:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建岗位','null',0,11,42,'ce2a12a3-6ee7-4c8f-974e-7bae80df183f','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改岗位',3,2,'module_system:position:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改岗位','null',0,11,43,'8105d20b-f2c5-4044-a086-f63fbd6bca1b','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除岗位',3,3,'module_system:position:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改岗位','null',0,11,44,'06a892aa-3a3c-4320-ad68-21e144418554','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改岗位状态',3,4,'module_system:position:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改岗位状态','null',0,11,45,'bac27dcf-8c68-416c-9f32-8de10a403bfc','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('岗位导出',3,5,'module_system:position:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'岗位导出','null',0,11,46,'fd04377c-91e4-4006-bb03-c2390320b53e','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情岗位',3,6,'module_system:position:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情岗位','null',0,11,47,'b417f870-ec5d-4512-9759-a52ebcb90331','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询岗位',3,7,'module_system:position:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询岗位','null',0,11,48,'1e88a0c4-4a3f-4752-b1cd-c579ba175479','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建角色',3,1,'module_system:role:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建角色','null',0,12,49,'ff384eb6-c96d-48bc-af7b-c3ba57ee3d96','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改角色',3,2,'module_system:role:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改角色','null',0,12,50,'ddb46ab4-c77b-4cd5-a187-b2d8cfe88468','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除角色',3,3,'module_system:role:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除角色','null',0,12,51,'c6d5037c-fabd-4ae1-abe2-2387138a3cdd','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改角色状态',3,4,'module_system:role:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改角色状态','null',0,12,52,'73cd93ee-e9cc-4a1f-8c80-bca50070c5a7','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('角色导出',3,5,'module_system:role:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'角色导出','null',0,12,53,'b07a0e47-23f3-45e0-a776-8a690fc5cb2d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情角色',3,6,'module_system:role:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情角色','null',0,12,54,'584d5c42-2e30-4e6d-92d0-4cff6f21ac80','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询角色',3,7,'module_system:role:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询角色','null',0,12,55,'b3191537-b73b-45b2-a089-f9e271e09284','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建用户',3,1,'module_system:user:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建用户','null',0,13,56,'cdd1766d-4026-427b-8fb1-d8212ecd3897','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改用户',3,2,'module_system:user:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改用户','null',0,13,57,'7b8eec49-4ba1-451e-ba4c-9ac7ea1e2791','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除用户',3,3,'module_system:user:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除用户','null',0,13,58,'ce2a7285-5c78-48c0-a013-53cd20938b5b','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改用户状态',3,4,'module_system:user:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改用户状态','null',0,13,59,'48f5f69a-e06d-4edc-b9f1-2d93e9ce3c56','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出用户',3,5,'module_system:user:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出用户','null',0,13,60,'d3b9bc4c-80e7-4c0f-92e2-cc21b797b258','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导入用户',3,6,'module_system:user:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入用户','null',0,13,61,'f7f83cb2-fcd7-4afc-8316-fe81acdbdf9d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('下载用户导入模板',3,7,'module_system:user:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载用户导入模板','null',0,13,62,'f1558aa4-a855-4499-8da4-569f0bdb8fa1','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情用户',3,8,'module_system:user:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情用户','null',0,13,63,'39fd866e-142f-451c-8eba-4647a0c93d5e','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询用户',3,9,'module_system:user:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询用户','null',0,13,64,'ff9c456d-b02d-473a-bb72-517660b48cc8','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('日志删除',3,1,'module_system:log:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'日志删除','null',0,14,65,'f860d695-a178-46a1-9012-658e2c5201f5','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('日志导出',3,2,'module_system:log:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'日志导出','null',0,14,66,'2d54281d-6b28-4e49-86d1-6d20c4d40410','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('日志详情',3,3,'module_system:log:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'日志详情','null',0,14,67,'c6e60b1b-6e0f-4f3f-974e-2f5831c9d3ca','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询日志',3,4,'module_system:log:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询日志','null',0,14,68,'c92aebad-3b68-4729-a315-8bb7e340badc','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告创建',3,1,'module_system:notice:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告创建','null',0,15,69,'e0ea2d06-ebb3-4bed-87c9-dbd443af0060','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告修改',3,2,'module_system:notice:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改用户','null',0,15,70,'5f465df3-12d0-4996-ae2c-2a7ce88d5a7b','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告删除',3,3,'module_system:notice:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告删除','null',0,15,71,'d2ed27fe-96a7-4d05-bbe6-7d7038500c71','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告导出',3,4,'module_system:notice:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告导出','null',0,15,72,'f77c6457-260f-4d2a-a84d-07df6f863b16','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告批量修改状态',3,5,'module_system:notice:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告批量修改状态','null',0,15,73,'d311dc79-0ed4-4973-91a4-86f4d37864c3','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('公告详情',3,6,'module_system:notice:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'公告详情','null',0,15,74,'0b764de4-6d02-44c5-a9c9-82861883e148','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询公告',3,5,'module_system:notice:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询公告','null',0,15,75,'cfba0aa8-de67-4605-a573-df0cb4886d1b','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建参数',3,1,'module_system:param:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建参数','null',0,16,76,'98e4f246-b406-4a39-b4e0-4929150e93d9','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改参数',3,2,'module_system:param:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改参数','null',0,16,77,'c0bfa725-761c-4096-bc2f-3337997e3c20','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除参数',3,3,'module_system:param:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除参数','null',0,16,78,'6da7250e-76b7-4154-8163-79188fec4ceb','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出参数',3,4,'module_system:param:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出参数','null',0,16,79,'28bcaf46-81dd-456f-af4f-1fe1b283ee47','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('参数上传',3,5,'module_system:param:upload',NULL,NULL,NULL,NULL,NULL,0,1,0,'参数上传','null',0,16,80,'41467478-5497-44b3-beb1-226691c06e76','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('参数详情',3,6,'module_system:param:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'参数详情','null',0,16,81,'8bd36810-bf6f-4529-beb6-b2f37304e100','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询参数',3,7,'module_system:param:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询参数','null',0,16,82,'70d8c98c-7204-47d3-9bd1-ef355dba2a7f','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建字典类型',3,1,'module_system:dict_type:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建字典类型','null',0,17,83,'aad0afaa-5e5f-47c0-b51d-0ba07f504a03','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改字典类型',3,2,'module_system:dict_type:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改字典类型','null',0,17,84,'72123c7e-beab-43d8-9778-ae6e5e7bc935','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除字典类型',3,3,'module_system:dict_type:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除字典类型','null',0,17,85,'e729dc8b-1739-40f6-8919-13c2473e453d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出字典类型',3,4,'module_system:dict_type:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出字典类型','null',0,17,86,'8769d73a-e43a-4b6c-984e-bd656af3b4bb','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改字典状态',3,5,'module_system:dict_type:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出字典类型','null',0,17,87,'689fb4c2-c1f6-4976-b9f6-bc298fad06b2','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('字典数据查询',3,6,'module_system:dict_data:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'字典数据查询','null',0,17,88,'34273044-e5ac-4cb5-8aa7-f4a470df154a','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建字典数据',3,7,'module_system:dict_data:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建字典数据','null',0,17,89,'8bd5e480-6ddd-434d-812a-c050f4350724','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改字典数据',3,8,'module_system:dict_data:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改字典数据','null',0,17,90,'d06019cc-71a0-4f2b-8b4d-6c7bf099c000','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除字典数据',3,9,'module_system:dict_data:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除字典数据','null',0,17,91,'aac9f596-a80e-4a52-9587-dea77c012748','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出字典数据',3,10,'module_system:dict_data:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出字典数据','null',0,17,92,'ce3d760c-b578-486c-b6f9-eb4659a99d9d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改字典数据状态',3,11,'module_system:dict_data:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改字典数据状态','null',0,17,93,'b19ec939-e050-48b8-910a-b558eb5bfb0e','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情字典类型',3,12,'module_system:dict_type:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情字典类型','null',0,17,94,'dcf1e08b-3bcb-4a07-8c20-2b21d85fef99','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询字典类型',3,13,'module_system:dict_type:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询字典类型','null',0,17,95,'acbc8959-c3da-4460-b9fc-883a5ad06be6','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情字典数据',3,14,'module_system:dict_data:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情字典数据','null',0,17,96,'15446aee-d76d-414c-b5d2-7540e5326cda','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建应用',3,1,'module_application:myapp:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建应用','null',0,18,97,'d6dc91c2-455b-4668-93a9-8f155c68c583','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改应用',3,2,'module_application:myapp:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改应用','null',0,18,98,'52670419-53b5-4f9a-8337-8bea256c0134','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除应用',3,3,'module_application:myapp:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除应用','null',0,18,99,'65c45196-5ba3-43a7-9e8b-003a2d267b41','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改应用状态',3,4,'module_application:myapp:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改应用状态','null',0,18,100,'749ec5c7-b153-4ab5-9cfc-37772fdccd41','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情应用',3,5,'module_application:myapp:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情应用','null',0,18,101,'21016807-15a1-4d63-b0fb-586ff1020fd4','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询应用',3,6,'module_application:myapp:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询应用','null',0,18,102,'477cdf7a-be63-4bce-9e29-eb358ea7e1c7','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建任务',3,1,'module_application:job:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建任务','null',0,19,103,'7ef64585-a0cc-46ab-85bd-cd7a4a2efc34','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('修改和操作任务',3,2,'module_application:job:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'修改和操作任务','null',0,19,104,'c1a34a32-15d9-41a5-a164-f377bab6fe41','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除和清除任务',3,3,'module_application:job:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除和清除任务','null',0,19,105,'c696ad7b-cbb9-4619-a93d-c4ff9a8f6119','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出定时任务',3,4,'module_application:job:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出定时任务','null',0,19,106,'6b4ee23f-d928-4a9c-9f3c-37deea4a8304','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情定时任务',3,5,'module_application:job:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情任务','null',0,19,107,'7dc2b4af-dece-4b47-a338-f339eb235d3b','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询定时任务',3,6,'module_application:job:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询定时任务','null',0,19,108,'ab8fc3ee-7dc3-4ddd-b980-5e156658adc1','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('智能对话',3,1,'module_application:ai:chat',NULL,NULL,NULL,NULL,NULL,0,1,0,'智能对话','null',0,20,109,'f2304e3b-3303-4c48-845d-3c961e1972b0','0','智能对话','2025-12-31 18:43:00','2025-12-31 18:43:00'),('在线用户强制下线',3,1,'module_monitor:online:delete',NULL,NULL,NULL,NULL,NULL,0,0,0,'在线用户强制下线','null',0,22,110,'efc507ea-c9ac-4f3f-a4f7-94eff2607cb5','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('清除缓存',3,1,'module_monitor:cache:delete',NULL,NULL,NULL,NULL,NULL,0,0,0,'清除缓存','null',0,24,111,'2a77bdfa-c4bf-4bc8-8a64-d2536960a73f','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件上传',3,1,'module_monitor:resource:upload',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件上传','null',0,25,112,'4a4ffc5b-3799-43f0-9457-f17b40751da0','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件下载',3,2,'module_monitor:resource:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件下载','null',0,25,113,'0e294667-7a44-4f6a-8ee6-bc9c2f41f3f0','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件删除',3,3,'module_monitor:resource:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件删除','null',0,25,114,'d372c4a7-55af-4027-84ce-81c875e37cd4','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件移动',3,4,'module_monitor:resource:move',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件移动','null',0,25,115,'cdd06074-bbeb-4ceb-9572-ae8365ea4e16','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件复制',3,5,'module_monitor:resource:copy',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件复制','null',0,25,116,'feb8890c-2dfe-4be3-9760-7334f659bb96','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('文件重命名',3,6,'module_monitor:resource:rename',NULL,NULL,NULL,NULL,NULL,0,1,0,'文件重命名','null',0,25,117,'359df56b-b01b-40d2-947c-dba974ddce17','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建目录',3,7,'module_monitor:resource:create_dir',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建目录','null',0,25,118,'766068e2-79aa-412b-bfe4-55ebcdf1dcbc','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出文件列表',3,9,'module_monitor:resource:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出文件列表','null',0,25,119,'eb2f6d5c-9551-4e6d-8e72-1d29a4486f1b','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询代码生成业务表列表',3,1,'module_generator:gencode:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询代码生成业务表列表','null',0,26,120,'526fa6ba-d74d-46ea-9647-0f243c32bdfd','0','查询代码生成业务表列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建表结构',3,2,'module_generator:gencode:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建表结构','null',0,26,121,'6b4c9211-7193-4a7a-a16f-718500b35bfa','0','创建表结构','2025-12-31 18:43:00','2025-12-31 18:43:00'),('编辑业务表信息',3,3,'module_generator:gencode:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑业务表信息','null',0,26,122,'69736846-028c-47a2-b28b-71f2f8869e18','0','编辑业务表信息','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除业务表信息',3,4,'module_generator:gencode:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除业务表信息','null',0,26,123,'ef56dc70-5cc0-4654-8f16-3dab014c69e1','0','删除业务表信息','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导入表结构',3,5,'module_generator:gencode:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入表结构','null',0,26,124,'d8ace227-b0aa-4371-86c8-9e779c252e2a','0','导入表结构','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量生成代码',3,6,'module_generator:gencode:operate',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量生成代码','null',0,26,125,'5636aef5-b46c-4d92-a8ad-e0e72a47f2fd','0','批量生成代码','2025-12-31 18:43:00','2025-12-31 18:43:00'),('生成代码到指定路径',3,7,'module_generator:gencode:code',NULL,NULL,NULL,NULL,NULL,0,1,0,'生成代码到指定路径','null',0,26,126,'3dabe5fb-6938-4e78-b7f6-87f55c8e033c','0','生成代码到指定路径','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询数据库表列表',3,8,'module_generator:dblist:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询数据库表列表','null',0,26,127,'0f86265b-9573-4420-820c-98f73bab7fd7','0','查询数据库表列表','2025-12-31 18:43:00','2025-12-31 18:43:00'),('同步数据库',3,9,'module_generator:db:sync',NULL,NULL,NULL,NULL,NULL,0,1,0,'同步数据库','null',0,26,128,'90e54cc8-69ac-4abd-9658-6df52ded244f','0','同步数据库','2025-12-31 18:43:00','2025-12-31 18:43:00'),('创建示例',3,1,'module_example:demo:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'创建示例','null',0,29,129,'5ae00ed8-3bbc-441a-b957-ae8c1bec18f6','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('更新示例',3,2,'module_example:demo:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'更新示例','null',0,29,130,'1b292df6-8efc-4d37-b457-c6229c569537','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('删除示例',3,3,'module_example:demo:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除示例','null',0,29,131,'b4c14477-747e-412e-a4a8-86db7901889c','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('批量修改示例状态',3,4,'module_example:demo:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量修改示例状态','null',0,29,132,'c9c95e3c-f561-4ed0-a9e6-5a9c80399c90','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导出示例',3,5,'module_example:demo:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出示例','null',0,29,133,'fa65f4f6-d7a3-4649-8b6f-500b0a6ff47f','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('导入示例',3,6,'module_example:demo:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入示例','null',0,29,134,'c831ca08-3d39-44b2-85ed-61266f6c85b7','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('下载导入示例模版',3,7,'module_example:demo:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载导入示例模版','null',0,29,135,'ad4d47c9-8bbd-41e4-b484-782810946b53','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('详情示例',3,8,'module_example:demo:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情示例','null',0,29,136,'9c74b89c-884e-494f-8137-48da2bcba10d','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('查询示例',3,9,'module_example:demo:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询示例','null',0,29,137,'a32777aa-ce05-4870-825f-125c14b81f01','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_title` varchar(64) NOT NULL COMMENT '公告标题',
  `notice_type` varchar(1) NOT NULL COMMENT '公告类型(1通知 2公告)',
  `notice_content` text COMMENT '公告内容',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_notice_uuid` (`uuid`),
  KEY `ix_sys_notice_updated_time` (`updated_time`),
  KEY `ix_sys_notice_created_id` (`created_id`),
  KEY `ix_sys_notice_id` (`id`),
  KEY `ix_sys_notice_status` (`status`),
  KEY `ix_sys_notice_updated_id` (`updated_id`),
  KEY `ix_sys_notice_created_time` (`created_time`),
  CONSTRAINT `sys_notice_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_notice_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;

--
-- Table structure for table `sys_param`
--

DROP TABLE IF EXISTS `sys_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_param` (
  `config_name` varchar(64) NOT NULL COMMENT '参数名称',
  `config_key` varchar(500) NOT NULL COMMENT '参数键名',
  `config_value` varchar(500) DEFAULT NULL COMMENT '参数键值',
  `config_type` tinyint(1) DEFAULT NULL COMMENT '系统内置(True:是 False:否)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_param_uuid` (`uuid`),
  KEY `ix_sys_param_updated_time` (`updated_time`),
  KEY `ix_sys_param_status` (`status`),
  KEY `ix_sys_param_id` (`id`),
  KEY `ix_sys_param_created_time` (`created_time`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统参数表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_param`
--

/*!40000 ALTER TABLE `sys_param` DISABLE KEYS */;
INSERT INTO `sys_param` VALUES ('网站名称','sys_web_title','FastApiAdmin',1,1,'594ade47-6bdd-44fb-b73c-8cff13024cc3','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('网站描述','sys_web_description','FastApiAdmin 是完全开源的权限管理系统',1,2,'e95e08e1-08af-42e9-a580-a5bf3d965fe4','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('网页图标','sys_web_favicon','https://service.fastapiadmin.com/api/v1/static/image/favicon.png',1,3,'c4d8c001-0d5a-4249-a5dd-f20dbd10b70a','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('网站Logo','sys_web_logo','https://service.fastapiadmin.com/api/v1/static/image/logo.png',1,4,'104405dd-c490-437b-8a38-8dbcecfb913a','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('登录背景','sys_login_background','https://service.fastapiadmin.com/api/v1/static/image/background.svg',1,5,'59184835-bf71-4167-96d3-e1566f2a55e2','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('版权信息','sys_web_copyright','Copyright © 2025-2026 service.fastapiadmin.com 版权所有',1,6,'581e55c2-32a9-44e9-af47-2bf8127b4ca7','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('备案信息','sys_keep_record','陕ICP备2025069493号-1',1,7,'3e435305-b67e-4cfc-bc13-3b850db96fc5','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('帮助文档','sys_help_doc','https://service.fastapiadmin.com',1,8,'42d4cdaa-341f-4487-a4c8-5790e917e1c2','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('隐私政策','sys_web_privacy','https://github.com/1014TaoTao/FastapiAdmin/blob/master/LICENSE',1,9,'a32c7c5e-2100-4f92-85f3-5a9c9dfc61ef','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('用户协议','sys_web_clause','https://github.com/1014TaoTao/FastapiAdmin/blob/master/LICENSE',1,10,'8b914e2d-cf72-49fa-9983-dcf9de75c629','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('源码代码','sys_git_code','https://github.com/1014TaoTao/FastapiAdmin.git',1,11,'7f9dfaab-feae-4a56-98a6-387a3b777554','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('项目版本','sys_web_version','2.0.0',1,12,'8eaed3b2-6f7d-4653-b732-a5528eb324a4','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('演示模式启用','demo_enable','false',1,13,'27495c2a-a7e2-43c2-bb34-2f15dc9ed8ec','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('演示访问IP白名单','ip_white_list','[\"127.0.0.1\"]',1,14,'b4980f8e-fd5e-4a78-aac8-8b850c0ac987','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('接口白名单','white_api_list_path','[\"/api/v1/system/auth/login\", \"/api/v1/system/auth/token/refresh\", \"/api/v1/system/auth/captcha/get\", \"/api/v1/system/auth/logout\", \"/api/v1/system/config/info\", \"/api/v1/system/user/current/info\", \"/api/v1/system/notice/available\"]',1,15,'b8ac8eb3-4ae7-4f29-a51e-f56a92fc9a17','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00'),('访问IP黑名单','ip_black_list','[]',1,16,'45512453-e4c9-4a57-abca-a7fbd9e19920','0','初始化数据','2025-12-31 18:43:00','2025-12-31 18:43:00');
/*!40000 ALTER TABLE `sys_param` ENABLE KEYS */;

--
-- Table structure for table `sys_position`
--

DROP TABLE IF EXISTS `sys_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_position` (
  `name` varchar(64) NOT NULL COMMENT '岗位名称',
  `order` int NOT NULL COMMENT '显示排序',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_position_uuid` (`uuid`),
  KEY `ix_sys_position_id` (`id`),
  KEY `ix_sys_position_updated_time` (`updated_time`),
  KEY `ix_sys_position_created_id` (`created_id`),
  KEY `ix_sys_position_status` (`status`),
  KEY `ix_sys_position_updated_id` (`updated_id`),
  KEY `ix_sys_position_created_time` (`created_time`),
  CONSTRAINT `sys_position_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_position_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='岗位表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_position`
--

/*!40000 ALTER TABLE `sys_position` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_position` ENABLE KEYS */;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `name` varchar(64) NOT NULL COMMENT '角色名称',
  `code` varchar(16) DEFAULT NULL COMMENT '角色编码',
  `order` int NOT NULL COMMENT '显示排序',
  `data_scope` int NOT NULL COMMENT '数据权限范围(1:仅本人 2:本部门 3:本部门及以下 4:全部 5:自定义)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_role_uuid` (`uuid`),
  KEY `ix_sys_role_updated_time` (`updated_time`),
  KEY `ix_sys_role_created_time` (`created_time`),
  KEY `ix_sys_role_id` (`id`),
  KEY `ix_sys_role_code` (`code`),
  KEY `ix_sys_role_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES ('管理员角色','ADMIN',1,4,1,'4078b9ed-0d0b-4747-8f99-b092818a1616','0','初始化角色','2025-12-31 18:43:00','2025-12-31 18:43:00');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;

--
-- Table structure for table `sys_role_depts`
--

DROP TABLE IF EXISTS `sys_role_depts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_depts` (
  `role_id` int NOT NULL COMMENT '角色ID',
  `dept_id` int NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`),
  KEY `dept_id` (`dept_id`),
  CONSTRAINT `sys_role_depts_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_role_depts_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_depts`
--

/*!40000 ALTER TABLE `sys_role_depts` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_depts` ENABLE KEYS */;

--
-- Table structure for table `sys_role_menus`
--

DROP TABLE IF EXISTS `sys_role_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menus` (
  `role_id` int NOT NULL COMMENT '角色ID',
  `menu_id` int NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `sys_role_menus_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_role_menus_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `sys_menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menus`
--

/*!40000 ALTER TABLE `sys_role_menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_menus` ENABLE KEYS */;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `username` varchar(64) NOT NULL COMMENT '用户名/登录账号',
  `password` varchar(255) NOT NULL COMMENT '密码哈希',
  `name` varchar(32) NOT NULL COMMENT '昵称',
  `mobile` varchar(11) DEFAULT NULL COMMENT '手机号',
  `email` varchar(64) DEFAULT NULL COMMENT '邮箱',
  `gender` varchar(1) DEFAULT NULL COMMENT '性别(0:男 1:女 2:未知)',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL地址',
  `is_superuser` tinyint(1) NOT NULL COMMENT '是否超管',
  `last_login` datetime DEFAULT NULL COMMENT '最后登录时间',
  `gitee_login` varchar(32) DEFAULT NULL COMMENT 'Gitee登录',
  `github_login` varchar(32) DEFAULT NULL COMMENT 'Github登录',
  `wx_login` varchar(32) DEFAULT NULL COMMENT '微信登录',
  `qq_login` varchar(32) DEFAULT NULL COMMENT 'QQ登录',
  `dept_id` int DEFAULT NULL COMMENT '部门ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) NOT NULL COMMENT 'UUID全局唯一标识',
  `status` varchar(10) NOT NULL COMMENT '是否启用(0:启用 1:禁用)',
  `description` text COMMENT '备注/描述',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `ix_sys_user_uuid` (`uuid`),
  UNIQUE KEY `mobile` (`mobile`),
  UNIQUE KEY `email` (`email`),
  KEY `ix_sys_user_updated_time` (`updated_time`),
  KEY `ix_sys_user_dept_id` (`dept_id`),
  KEY `ix_sys_user_id` (`id`),
  KEY `ix_sys_user_status` (`status`),
  KEY `ix_sys_user_created_id` (`created_id`),
  KEY `ix_sys_user_created_time` (`created_time`),
  KEY `ix_sys_user_updated_id` (`updated_id`),
  CONSTRAINT `sys_user_ibfk_1` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_3` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES ('admin','$2b$12$e2IJgS/cvHgJ0H3G7Xa08OXoXnk6N/NX3IZRtubBDElA0VLZhkNOa','超级管理员',NULL,NULL,'0','https://service.fastapiadmin.com/api/v1/static/image/avatar.png',1,NULL,NULL,NULL,NULL,NULL,1,1,'d2891824-58ec-480b-a5c4-2bf75647d1f4','0','超级管理员','2025-12-31 18:43:00','2025-12-31 18:43:00',NULL,NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;

--
-- Table structure for table `sys_user_positions`
--

DROP TABLE IF EXISTS `sys_user_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_positions` (
  `user_id` int NOT NULL COMMENT '用户ID',
  `position_id` int NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`position_id`),
  KEY `position_id` (`position_id`),
  CONSTRAINT `sys_user_positions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_user_positions_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `sys_position` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户岗位关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_positions`
--

/*!40000 ALTER TABLE `sys_user_positions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_user_positions` ENABLE KEYS */;

--
-- Table structure for table `sys_user_roles`
--

DROP TABLE IF EXISTS `sys_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_roles` (
  `user_id` int NOT NULL COMMENT '用户ID',
  `role_id` int NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `sys_user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_roles`
--

/*!40000 ALTER TABLE `sys_user_roles` DISABLE KEYS */;
INSERT INTO `sys_user_roles` VALUES (1,1);
/*!40000 ALTER TABLE `sys_user_roles` ENABLE KEYS */;

--
-- Dumping routines for database 'fastapiadmin'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-31 18:43:08
