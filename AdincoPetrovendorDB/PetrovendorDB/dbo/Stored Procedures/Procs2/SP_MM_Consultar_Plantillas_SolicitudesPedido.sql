use petrovendor
go
drop proc if exists SP_MM_Consultar_Plantillas_SolicitudesPedido
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/11/2019>
-- Description:	<Consultar plantillas de solicitudes de pedido pendientes de enviar>
-- =============================================
-- Author:		<Luis David>
-- Create date: <02/24/2024>
-- Description:	<Se agrega el filtro por @FechaInicio y @FechaFin, Petrovendor #2737>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Consultar_Plantillas_SolicitudesPedido] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@IdContrato INT,
	@FechaInicio datetime,
	@FechaFin datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CAST(SP.IdPlantillaSolicitudPedido AS NVARCHAR(10)) + '-P' AS Folio,
		SP.IdPlantillaSolicitudPedido,
		SP.MotivoUrgencia,
		TSP.TipoSolicitudPedido,
		SP.CreadoEl AS FechaAlta,
		US.Nombre AS NombreUsuario,
		AC.NombreAreaContractual
	FROM dbo.MM_Plantillas_SolicitudPedido AS SP
		LEFT JOIN dbo.MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = SP.CreadoPor
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
	WHERE SP.IdUsuarioSolicitante = @IdUsuario
		AND SP.IdProveedor = @IdProveedor
		AND SP.IdContrato = @IdContrato
		AND ISNULL(SP.Enviada,0) = 0
		AND CAST(SP.CreadoEl AS date) BETWEEN CAST(@FechaInicio AS date) AND CAST(@FechaFin AS date)
	ORDER BY SP.CreadoEl DESC
END
