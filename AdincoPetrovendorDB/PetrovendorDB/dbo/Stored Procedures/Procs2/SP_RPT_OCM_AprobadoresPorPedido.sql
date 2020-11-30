
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Consultar Aprobadores recibiendo el IdOperador
-- =============================================
-- Author:		Jose Roman
-- Create date: 24-04-18
-- Description:	 Se cambian los aprobadores mostrados por los aprobadores de pedido
-- =============================================
CREATE  PROCEDURE SP_RPT_OCM_AprobadoresPorPedido
	@IdPedido INT
AS
BEGIN
	SELECT
		'Aprobador ' + CAST(T.NoSecuencia AS NVARCHAR(max)) AS NoAprobador,
		T.NoSecuencia, 
		U.Nombre, 
		t.FechaCambioEstatus, 
		t.IdTarea,
		t.IdFirma
	FROM TA_Tarea AS T
		--INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdTarea =T.IdTarea
		INNER JOIN TA_Operacion AS TOO ON T.IdOperacion = TOO.IdOperacion
		INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = too.IdDocumento
		INNER JOIN dbo.MM_Pedido AS p ON p.IdSolicitudPedido = sp.IdSolicitudPedido AND p.Version = too.NoVersion
		INNER JOIN S_Usuario AS U on u.IdUsuario = T.IdAprobador
		INNER JOIN TA_Estatus AS TAE ON TAE.IdEstatus = T.IdEstatus
	WHERE p.IdPedido = @IdPedido 
		AND t.IdEstatus = 2
		AND TOO.IdTipoOperacion = 9
	ORDER BY NoSecuencia ASC 		
END


