-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-02-2018
-- Description:	Actualice columna de Proveedor agregando isnull
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionFacturaProveedorVentas_Cabecera] --44,233
	-- Add the parameters for the stored procedure here consultarEncabezadoAceptacionFacturaDetalle
@IdProveedor        INT,
@IdAceptacionPedido INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @COMENTARIO_CANCELACION NVARCHAR(MAX) =''

		SET @COMENTARIO_CANCELACION = (SELECT TOP 1 Comentario
										FROM TA_Tarea AS T
										INNER JOIN TA_Operacion AS O ON O.IdOperacion = T.IdOperacion
										INNER JOIN MM_AceptacionFactura AS AF ON AF.IdAceptacionFactura = O.IdDocumento
										WHERE AF.IdAceptacionPedido  = @IdAceptacionPedido AND T.IdEstatus  = 3 
										ORDER BY T.FechaCambioEstatus DESC)

	      -- T.IdEstatus  = 3 Estatus Rechazado
			CREATE TABLE #TEMPRFC(
			idrfc int IDENTITY(1,1),
			rfc NVARCHAR(MAX)
			);

			INSERT INTO #TEMPRFC
			(
				rfc
			)
			VALUES ('PEP170906DI5'),('JEP1709042B1'),('JEP1502264H1'),('JEP170904B1'),('OEAR951113XYZ');

			
		  SELECT 
		  AP.IdAceptacionPedido, 
		  AP.IdPedido, 
		  AP.NombreRecibidoPor, 
		  AP.NombreUsuarioEntrega,
		  AP.Creado,
		  CONCAT(ISNULL(PR.RazonSocial,''),' ',ISNULL(PR.RegimenCapital,'')) AS Proveedor,
		  ISNULL(AP.PCN_Agregado,0) AS PCN_Agregado, 
		  ISNULL(AP.DocumentoDescargado,0) AS DocumentoCargado, 
		  CONCAT(DG.Calle,' ', DG.NoExterior, ' ', DG.NoInterior, ' ', DG.Municipio, ' ', DG.Estado, ' ',PS.pais,' C.P. ',DG.CodigoPostal) AS Direccion,
		  ISNULL(AC_PCN.IdEstatus,0) AS Estatus,
		  PR.RFC,
		  ISNULL(AF.IdEstatusXML,4) AS IdEstatusXML,
		  ISNULL(AF.IdEstatusPDF,4) AS IdEstatusPDF,
		  ISNULL(TAO.IdEstatusOperacion,1) AS IdEstatusOperacion,
		  TAO.FechaModificacion,
		  @COMENTARIO_CANCELACION,
		  ISNULL(TAO.IdOperacion,0),
		  PG.IdPedido AS IdPedidoGeneral,
		  TP.TipoPedido,
		  TP.IdTipoPedido,
		  CASE
			WHEN ISNULL(TR.idrfc,0) > 0 THEN 1
			ELSE 0
		  END AS MostrarPDF,
		  /** Realizar la consulta que devuelva un booleano, para verificar 
		  que el proveedor no tenga complementos de pago pendientes por registrar**/
		  0 AS ValidacionComplemento 
		  FROM dbo.MM_AceptacionPedido AS AP
		  INNER JOIN dbo.DG_Domicilio AS DG ON DG.IdDomicilio = AP.IdDomicilioEntrega
		  LEFT JOIN dbo.PV_PaisRepublica AS PS ON PS.id = DG.IdPais
		  INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
		  INNER JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
		  LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		  LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC_PCN ON AC_PCN.IdAceptacionPedido = AP.IdAceptacionPedido 
		  LEFT JOIN dbo.TA_Operacion AS TAO ON TAO.IdDocumento = AF.IdAceptacionFactura AND TAO.IdTipoOperacion=10
		  INNER JOIN dbo.MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras
		  LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		  LEFT JOIN #TEMPRFC AS TR ON TR.rfc COLLATE Modern_Spanish_CI_AS = PR.RFC COLLATE Modern_Spanish_CI_AS
		  LEFT JOIN dbo.RelacionCartaCNPedido rel ON rel.IdAceptacionPedido = AP.IdAceptacionPedido AND rel.IdPedido = P.IdPedido 
		  WHERE P.IdSubcontratista =@IdProveedor  AND AP.IdAceptacionPedido =@IdAceptacionPedido AND (AC_PCN.IdEstatus = 2 OR rel.PedirCarta = 0 )
		  GROUP BY 
		  AP.IdAceptacionPedido, 
		  AP.IdPedido, 
		  AP.NombreRecibidoPor, 
		  AP.NombreUsuarioEntrega,
		  AP.Creado,
		  PR.RazonSocial,
		  PR.RegimenCapital,
		  AP.PCN_Agregado,
		  AP.DocumentoDescargado,
		  DG.Calle,
		  DG.NoExterior,
		  DG.NoInterior, 
		  DG.Municipio,
		  DG.Estado,
		  PS.pais,
		  DG.CodigoPostal,
		  AC_PCN.IdEstatus,
		  PR.RFC,
		  AF.IdEstatusXML,
		  AF.IdEstatusPDF,
		  TAO.IdEstatusOperacion,
		  TAO.FechaModificacion,
		  TAO.IdOperacion,
		  PG.IdPedido,
		  TP.TipoPedido,
		  TP.IdTipoPedido,
		  TR.idrfc;

     END



