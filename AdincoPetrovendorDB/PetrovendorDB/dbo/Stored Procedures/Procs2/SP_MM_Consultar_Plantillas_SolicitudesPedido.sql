-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/11/2019>
-- Description:	<Consultar plantillas de solicitudes de pedido pendientes de enviar>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Consultar_Plantillas_SolicitudesPedido] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@IdContrato INT
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
	ORDER BY SP.CreadoEl DESC




END
