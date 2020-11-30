-- =============================================
-- Author:		Pedro Acuña
-- Create date: 27/02/2019
-- Description:	obtener las aceptaciones de servicio realizadas para cargar el reporte de aceptaciones de servicio
-- =============================================

CREATE PROCEDURE SP_ReportesAceptacionServicio @IdProveedor INT, @MesAnio DATETIME
AS
	BEGIN
		DECLARE @DiaAnterior DATETIME, @MesSiguiente DATETIME

		SELECT @DiaAnterior	 = DATEADD ( MINUTE, -1, @MesAnio )

		SELECT @MesSiguiente  = DATEADD ( MONTH, 1, @MesAnio )

		SELECT	AP.IdAceptacionPedido, AP.IdProveedor, AP.CreadorPor
		  FROM	MM_AceptacionPedido AS AP
				INNER JOIN MM_Pedido AS MP
						   ON MP.IdPedido = AP.IdPedido
				INNER JOIN DG_Domicilio AS LE
						   ON LE.IdDomicilio = AP.IdDomicilioEntrega
				INNER JOIN DG_TipoDomicilio AS TD
						   ON TD.IdTipoDomicilio = LE.IdTipoDomicilio
				INNER JOIN PV_PaisRepublica AS PAIS
						   ON PAIS.id = LE.IdPais
				INNER JOIN S_Proveedor AS P
						   ON P.IdProveedor = MP.IdSubcontratista
				INNER JOIN MM_Pedidos AS PG
						   ON MP.IdPedido = PG.IdIdentificador
							  AND	PG.IdProveedorCliente = @IdProveedor
				LEFT JOIN dbo.MM_TipoPedido AS TP
						  ON TP.IdTipoPedido = PG.IdTipoPedido
		 WHERE
				AP.IdProveedor = @IdProveedor
				AND ISNULL ( AP.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS	
				AND AP.Creado BETWEEN @DiaAnterior
							  AND	  @MesSiguiente
		 ORDER BY IdAceptacionPedido 
	END
