USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_IAMConsultarUsuario'
)
    DROP PROCEDURE SP_IAMConsultarUsuario;
GO
/****** Object:  StoredProcedure [dbo].[SP_IAMConsultarUsuario]    Script Date: 09/11/2022 11:00:13 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-18
-- DAC 09/11/2022 --> Se agrega CTE de DurationPreSignedURL
-- =============================================
CREATE PROCEDURE [dbo].[SP_IAMConsultarUsuario]
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdIAM,
                    Nombre,
                    RTRIM(LTRIM(AccessKey)) AS AccessKey,
                    RTRIM(LTRIM(SecretAccessKey)) AS SecretAccessKey,
                    IdContrato,
					1 as DurationPreSignedURL --> CTE EN HORAS
             FROM AWS_UserIAM
			 WHERE IdIAM = 10001 --CTE S3User
         END;