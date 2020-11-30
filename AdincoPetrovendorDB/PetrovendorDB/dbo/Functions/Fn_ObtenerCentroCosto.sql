-- =============================================
-- Author: Pedro Acu�a
-- Create date: 28/08/2018
-- Description: obtener los centros de costos por solPed
-- =============================================

create FUNCTION Fn_ObtenerCentroCosto
	( @IdSolicitudPedido INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retornoCentroCosto NVARCHAR(MAX)

		DECLARE @tablaAux TABLE
			( IdCentroCosto INT ,
			  NombreCentroCosto NVARCHAR(MAX))

		INSERT INTO @tablaAux
			( IdCentroCosto )
		SELECT	IdCentroCosto
		FROM	dbo.MM_SolicitudPedido
		WHERE	IdSolicitudPedido = @IdSolicitudPedido

		INSERT INTO @tablaAux
			( IdCentroCosto )
		SELECT		SPDLP.IdCentroCosto
		FROM		dbo.MM_SolicitudPedido solPed
		LEFT JOIN	dbo.MM_SolicitudPedidoDetalle AS SPD
			ON SPD.IdSolicitudPedido = solPed.IdSolicitudPedido
		LEFT JOIN	dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP
			ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		WHERE		SPD.IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY	solPed.IdSolicitudPedido, SPDLP.IdCentroCosto

		--obtengo el nombre del centro de costo
		UPDATE		t
		SET			t.NombreCentroCosto = cc.CentroCosto
		FROM		@tablaAux t
		LEFT JOIN	dbo.CC_CentroCosto cc
			ON cc.IdCentroCosto = t.IdCentroCosto

		--y ahora si lo divido por comas los resultados
		SELECT	@retornoCentroCosto
			= STUFF (
				  (	  SELECT	CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), NombreCentroCosto )
					  FROM		@tablaAux
					  GROUP BY	NombreCentroCosto
					  FOR XML PATH ( '' )), 1, 1, '' )

		RETURN @retornoCentroCosto
	END
