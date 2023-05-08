-- =============================================
-- Author: Pedro Acuña
-- Create date: 28/08/2018
-- Description: obtener el numero de presupuesto y la actividad
-- =============================================

CREATE FUNCTION Fn_ObtenerNumPresupuestoActividad
	( @IdSolicitudPedido INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		DECLARE @tablaAux TABLE
			( IdLineaPresupuesto INT ,
			  Nombre NVARCHAR(MAX))

		INSERT INTO @tablaAux
			( IdLineaPresupuesto )
		SELECT		DISTINCT
					SPDLP.IdLineaPresupuesto
		FROM		dbo.MM_SolicitudPedidoDetalle AS SPD
		LEFT JOIN	dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP
			ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		WHERE		SPD.IdSolicitudPedido = @IdSolicitudPedido

		--obtengo el nombre
		UPDATE		t
		SET			t.Nombre = activi.DescripcionActividadPetrolera
		FROM		@tablaAux t
		LEFT JOIN	adinco.dbo.CO_LineaPresupuestoMes lpm
			ON t.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
		LEFT JOIN	adinco.dbo.CO_ActividadPetroleraCNH activi
			ON lpm.IdActividadPetrolera = activi.IdActividadPetrolera

		--y ahora si lo divido por comas los resultados
		SELECT	@retorno
			= STUFF (
				  (	  SELECT	CAST(', ' AS VARCHAR(MAX)) + LTRIM ( IdLineaPresupuesto ) + ' - ' + LTRIM ( Nombre )
					  FROM		@tablaAux
					  GROUP BY	IdLineaPresupuesto, Nombre
					  FOR XML PATH ( '' )), 1, 1, '' )

		RETURN @retorno
	END