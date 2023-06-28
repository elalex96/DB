USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_APP_ConsultarConfiguracionHeaderExcel'
)
    DROP PROCEDURE SP_APP_ConsultarConfiguracionHeaderExcel;   
	
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_RPT_ConsultaFacturas]    Script Date: 26/06/2023 03:36:00 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel AC
-- Create date: 26-06-2023
-- Description:	Consultar configuración de header de los descargar en excel 
-- =============================================
CREATE PROCEDURE [dbo].[SP_APP_ConsultarConfiguracionHeaderExcel] 
@Clave VARCHAR(100)
-- Add the parameters for the stored procedure here
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;
		SELECT Clave,Titulo,RutaLogo
		FROM APP_ConfiguracionHeaderExcel (NOLOCK)
		WHERE Clave = @Clave

	END
