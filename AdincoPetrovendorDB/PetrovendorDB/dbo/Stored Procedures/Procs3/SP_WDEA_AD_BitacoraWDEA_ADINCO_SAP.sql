-- =============================================
-- Author:		Alexander Gomez
-- Create date: 27/10/2022
-- Description:	consulta de bitacora de procesamiento en WDEA ADINCO-SAP
-- =============================================
CREATE PROCEDURE [dbo].[SP_WDEA_AD_BitacoraWDEA_ADINCO_SAP]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATETIME,
	@FechaFin DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		[Id]
      ,[Fecha]
      ,[Mensaje]
      ,[NoConsecutivoProcesamiento]
      ,[IdBitacoraLectura]
      ,[IsImportacionExitosa]
	FROM WDEA_Bitacora_AdincoSAP (NOLOCK)
	WHERE Fecha BETWEEN @FechaInicio AND @FechaFin;

END
