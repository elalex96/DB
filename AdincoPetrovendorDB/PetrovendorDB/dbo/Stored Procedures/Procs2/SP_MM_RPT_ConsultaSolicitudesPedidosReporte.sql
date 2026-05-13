-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/02/2023
-- Description:	consulta de solicitudes de pedido para reportes de solicitudes de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_RPT_ConsultaSolicitudesPedidosReporte]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATE,
	@FechaFin DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra   sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CON.NumeroContrato AS Contrato,
		SP.IdSolicitudPedido AS NumeroRequisicion,
		SP.MotivoUrgencia AS MotivoJustificacion,
		SP.FechaAlta,
		E.Nombre AS Estatus,
		'SolicitudPedido_' + CAST(SP.IdSolicitudPedido AS varchar) + '.pdf' AS Documento,
		SP.IdProveedor
	FROM MM_SolicitudPedido AS SP (NOLOCK)
		JOIN Adinco..CO_Contrato  AS CON  (NOLOCK)
			ON SP.IdContrato = CON.IdContrato
			AND SP.FechaAlta BETWEEN @FechaInicio AND @FechaFin
			AND SP.Activo = 1
			AND ISNULL(SP.IdEliminado,0) = 0
			AND SP.IdContrato IN (10045,10044,10046,10038,10144)
		JOIN TA_Operacion AS OP (NOLOCK)
			ON SP.IdSolicitudPedido = OP.IdDocumento
			AND OP.IdTipoOperacion = 2
		JOIN TA_Estatus AS E (NOLOCK)
			ON OP.IdEstatusOperacion = E.IdEstatus
	GROUP BY CON.NumeroContrato,
		SP.IdSolicitudPedido,
		SP.MotivoUrgencia,
		SP.FechaAlta,
		E.Nombre,
		SP.IdProveedor
	ORDER BY SP.IdSolicitudPedido DESC

END
