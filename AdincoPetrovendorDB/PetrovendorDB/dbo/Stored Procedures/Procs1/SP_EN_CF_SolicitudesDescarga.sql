USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_CF_SolicitudesDescarga'
)
    DROP PROCEDURE SP_EN_CF_SolicitudesDescarga;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/02/2023>
-- Description:	<Consulta de las solicitudes de descarga de PROCRUA>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/03/2024>
-- Description:	<filtro de contratos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_CF_SolicitudesDescarga]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT,
	@Tipo VARCHAR(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT
		SD.FechaRegistroSolicitud,
		CAST(SD.FechaInicio AS NVARCHAR) + ' - ' + CAST(SD.FechaFin AS NVARCHAR) AS RangoFechas,
		US.Nombre AS SolicitadoPor,
		CASE	
			WHEN ISNULL(SD.Procesado,0) = 0 THEN 'Procesando Archivos..'
			WHEN ISNULL(SD.Procesado,0) = 1 THEN 'Listo para Descargar'
		END AS Estatus,
		CASE  
		WHEN ISNULL(SD.Procesado,0) = 0 THEN 'label label-warning'
		WHEN ISNULL(SD.Procesado,0) = 1 THEN 'label label-success'
	END AS span,
		SD.Folder,
		SD.UUIDAmazon,
		SD.NombreArchivo,
		SD.Meta,
		C.NumeroContrato + ' - ' + A.NombreAreaContractual AS Contrato
	FROM MM_SolicitudesDescargaProcesos AS SD (NOLOCK)
	JOIN S_Usuario AS US (NOLOCK)
		ON SD.IdUsuarioSolicitante = US.IdUsuario
	JOIN Adinco..CO_Contrato AS C (NOLOCK)
		ON SD.IdContrato = C.IdContrato
	JOIN Adinco..CO_AreaContractual AS A (NOLOCK)
		ON C.IdAreaContractual = A.IdAreaContractual
	WHERE SD.Tipo = @Tipo
		AND SD.IdContrato = @IdContrato
	ORDER BY FechaRegistroSolicitud DESC;

END