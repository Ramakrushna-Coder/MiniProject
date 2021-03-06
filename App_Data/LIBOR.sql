USE [master]
GO
/****** Object:  Database [LIBOR]    Script Date: 05/15/2020 02:03:08 ******/
CREATE DATABASE [LIBOR] ON  PRIMARY 
( NAME = N'LIBOR', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\LIBOR.mdf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'LIBOR_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\LIBOR_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [LIBOR] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LIBOR].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LIBOR] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [LIBOR] SET ANSI_NULLS OFF
GO
ALTER DATABASE [LIBOR] SET ANSI_PADDING OFF
GO
ALTER DATABASE [LIBOR] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [LIBOR] SET ARITHABORT OFF
GO
ALTER DATABASE [LIBOR] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [LIBOR] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [LIBOR] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [LIBOR] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [LIBOR] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [LIBOR] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [LIBOR] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [LIBOR] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [LIBOR] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [LIBOR] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [LIBOR] SET  DISABLE_BROKER
GO
ALTER DATABASE [LIBOR] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [LIBOR] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [LIBOR] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [LIBOR] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [LIBOR] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [LIBOR] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [LIBOR] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [LIBOR] SET  READ_WRITE
GO
ALTER DATABASE [LIBOR] SET RECOVERY SIMPLE
GO
ALTER DATABASE [LIBOR] SET  MULTI_USER
GO
ALTER DATABASE [LIBOR] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [LIBOR] SET DB_CHAINING OFF
GO
USE [LIBOR]
GO
/****** Object:  Table [dbo].[SOFR]    Script Date: 05/15/2020 02:03:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SOFR](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NULL,
	[SOFR_Index] [decimal](18, 7) NULL,
	[Average_30Days] [decimal](18, 7) NULL,
	[Average_90Days] [decimal](18, 7) NULL,
	[Average_180Days] [decimal](18, 7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[SP_INS_SOFR]    Script Date: 05/15/2020 02:03:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_INS_SOFR]
@Id int = 0,
@Date date,
@SOFR_Index decimal(18,8),
@Average_30Days decimal= 0,
@Average_90Days decimal= 0,
@Average_180Days decimal = 0

AS BEGIN

        DECLARE 
		@StartID30 int,
		@EndID30 int,
		@SOFRSum30 decimal(18,8),
		@SOFRAvg30 decimal(18,8),	
		
		@StartID90 int,
		@EndID90 int,
		@SOFRSum90 decimal(18,8),
		@SOFRAvg90 decimal(18,8),		
		
		@StartID180 int,
		@EndID180 int,
		@SOFRSum180 decimal(18,8),
		@SOFRAvg180 decimal(18,8),
		
		@IDENTITY int,
		@TOTOAlSUM decimal(18,8)
		
		SET @StartID30 = 0
		SET @EndID30 = 0
		SET @StartID90 = 0
		SET @EndID90 = 0
		SET @StartID180 = 0
		SET @EndID180 = 0
		
		SET @SOFRSum30 = 0.0
		SET @SOFRSum90 = 0.0		
		SET @SOFRSum180 = 0.0

	BEGIN
		SET NOCOUNT ON
		SET @TOTOAlSUM = 0.0		
		
		IF NOT EXISTS(SELECT Id FROM SOFR WHERE Date = @Date)
		BEGIN
			INSERT INTO SOFR(Date, SOFR_Index, Average_30Days, Average_90Days, Average_180Days) 
			VALUES(@Date, @SOFR_Index, @Average_30Days, @Average_90Days, @Average_180Days)
			
			SET @IDENTITY = (SELECT @@IDENTITY)
			
   ----------  Average for 30days ----------------------
			
			    SET @StartID30 = @IDENTITY - 29
				SET @EndID30 = @IDENTITY
				
				IF(@StartID30 > 0)
				BEGIN
					WHILE(@StartID30 <= @EndID30)
					BEGIN
						SET @SOFRSum30 = (select SOFR_Index from dbo.SOFR where Id = @StartID30)			
						SET @TOTOAlSUM = @TOTOAlSUM + @SOFRSum30
						SET @StartID30 = @StartID30 + 1						
					END
				    SET @SOFRAvg30 = @TOTOAlSUM/30
				    UPDATE SOFR SET Average_30Days = @SOFRAvg30 WHERE Id = @EndID30    
				END		
			
	----------  Average for 90days ----------------------
               
               SET @StartID90 = @IDENTITY - 89
				SET @EndID90 = @IDENTITY
				
				IF(@StartID90 > 0)
				BEGIN
					WHILE(@StartID90 <= @EndID90)
					BEGIN
						SET @SOFRSum90 = (select SOFR_Index from dbo.SOFR where Id = @StartID90)			
						SET @TOTOAlSUM = @TOTOAlSUM + @SOFRSum90
						SET @StartID90 = @StartID90 + 1						
					END
				    SET @SOFRAvg90 = @TOTOAlSUM/90
				    UPDATE SOFR SET Average_90Days = @SOFRAvg90 WHERE Id = @EndID90    
				END		
			

	----------  Average for 180days ----------------------

			SET @StartID180 = @IDENTITY - 179
				SET @EndID180 = @IDENTITY
				
				IF(@StartID180 > 0)
				BEGIN
					WHILE(@StartID180 <= @EndID180)
					BEGIN
						SET @SOFRSum180 = (select SOFR_Index from dbo.SOFR where Id = @StartID180)			
						SET @TOTOAlSUM = @TOTOAlSUM + @SOFRSum180
						SET @StartID180 = @StartID180 + 1						
					END
				    SET @SOFRAvg180 = @TOTOAlSUM/180
				    UPDATE SOFR SET Average_180Days = @SOFRAvg180 WHERE Id = @EndID180    
				END		

		END

    END
    Select * from dbo.SOFR order by id desc
END
GO
