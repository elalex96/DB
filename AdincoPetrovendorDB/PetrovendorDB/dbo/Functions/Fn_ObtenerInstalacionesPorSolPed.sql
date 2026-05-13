-- =============================================
-- Author: Pedro Acuña
-- Create date: 28/08/2018
-- Description: obtener las instalaciones por solPed
-- =============================================

create FUNCTION Fn_ObtenerInstalacionesPorSolPed
	( @IdSolicitudPedido INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		DECLARE @tablaAux TABLE
			( IdInstalacion INT ,
			  Nombre NVARCHAR(MAX))

		INSERT INTO @tablaAux
			( IdInstalacion )
		SELECT		SPDLP.IdInstalacion
		FROM		dbo.MM_SolicitudPedidoDetalle AS SPD
		LEFT JOIN	dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP
			ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		WHERE		SPD.IdSolicitudPedido = @IdSolicitudPedido

		INSERT INTO @tablaAux
			( IdInstalacion )
		SELECT		IdInstalacion
		FROM		dbo.MM_SolicitudPedido solPed
		LEFT JOIN	dbo.MM_SolicitudPedidoDetalle AS SPD
			ON SPD.IdSolicitudPedido = solPed.IdSolicitudPedido
		LEFT JOIN	dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP
			ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		WHERE		solPed.IdSolicitudPedido = @IdSolicitudPedido

		--obtengo el nombre
		UPDATE		t
		SET			t.Nombre = i.NombreInstalacion
		FROM		@tablaAux t
		LEFT JOIN	Adinco.dbo.CO_Instalacion i
			ON i.IdInstalacion = t.IdInstalacion

		--y ahora si lo divido por comas los resultados
		SELECT	@retorno = STUFF (
							   (   SELECT	CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), Nombre )
								   FROM		@tablaAux
								   GROUP BY Nombre
								   FOR XML PATH ( '' )), 1, 1, '' )

		RETURN @retorno
	END