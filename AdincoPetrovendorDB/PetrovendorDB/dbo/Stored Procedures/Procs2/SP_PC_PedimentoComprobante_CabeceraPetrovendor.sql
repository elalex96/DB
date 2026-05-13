-- =============================================
-- Author:	Daniel Cruz
-- Create date: 27-03-18
-- Description:	Consultar encabezado de aceptación de pedimento comprobante para petrovendor 
-- =============================================
CREATE   PROCEDURE [dbo].[SP_PC_PedimentoComprobante_CabeceraPetrovendor] 
	-- Add the parameters for the stored procedure here
@IdProveedor        INT,
@IdAceptacionPedido INT,
@IdContrato INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
          DECLARE @EXISTE_APROBACION INT 
		  DECLARE @MOTIVO_RECHAZO NVARCHAR(MAX) 
		 
		  ---Validación de Estatus de documentos
		  /*OBTENER EL MOTIVO DE RECHAZO SI LA OPERACION FUE RECHZADA*/
		  SELECT @MOTIVO_RECHAZO = T.Comentario
		  FROM dbo.FI_PedimentoComprobante PC
		  INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante PCA ON PCA.IdPedimentoComprobante=PC.IdPedimentoComprobante
		  INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = PCA.IdAceptacionPedido
		  INNER JOIN TA_Operacion O ON O.IdDocumento = PC.IdPedimentoComprobante 
		  INNER JOIN dbo.TA_Tarea T ON T.IdOperacion=O.IdOperacion
		  WHERE AP.IdAceptacionPedido= @IdAceptacionPedido AND O.IdTipoOperacion=16 AND O.IdEstatusOperacion=3 AND T.IdEstatus=3
		  GROUP BY T.Comentario
		  /*DONDE 3 ES ESTATUS RECHAZADO*/

		   
		  
		  SELECT 
		  AP.IdAceptacionPedido, --0
		  AP.IdPedido, --1
		  AP.NombreRecibidoPor, --2
		  AP.NombreUsuarioEntrega,--3
		  AP.Creado,--4
		  ISNULL(PR.RazonSocial,'')+' '+ ISNULL(PR.RegimenCapital,'') AS Proveedor,	--5
		  CONCAT(   CASE
                         WHEN DG.Calle IS NULL THEN
                             ''
                         ELSE
                             'Calle ' + DG.Calle
                     END,
                     CASE
                         WHEN DG.NoExterior IS NULL THEN
                             ''
                         ELSE
                             ' No Ext ' + DG.NoExterior
                     END,
                     CASE
                         WHEN DG.NoInterior IS NULL THEN
                             ''
                         ELSE
                             ' No Int ' + DG.NoInterior
                     END,
                     CASE
                         WHEN DG.Colonia IS NULL THEN
                             ''
                         ELSE
                             ' Colonia ' + DG.Colonia + ' '
                     END,
                     CASE
                         WHEN DG.Municipio IS NULL THEN
                             ''
                         ELSE
                             DG.Municipio + ' ,'
                     END,
                     CASE
                         WHEN DG.Estado IS NULL THEN
                             ''
                         ELSE
                             DG.Estado + ' ,'
                     END,
                     CASE
                         WHEN DG.Pais IS NULL THEN
                             ''
                         ELSE
                             DG.Pais + ' ,'
                     END,
                     CASE
                         WHEN DG.CodigoPostal IS NULL THEN
                             ''
                         ELSE
                             ' CP ' + DG.CodigoPostal
                     END
                 ) AS Direccion, --6
		  PG.IdPedido AS IdPedidoGeneral,--7
		  TP.IdTipoPedido,--8
		  PV.IdNacionalidad,--9
		  N.Nacionalidad,--10
		  ISNULL(PC.IdPedimentoComprobante,0) AS IdPedimentoComprobante,--11
		  ISNULL(O.IdOperacion,0) AS IdOperacion,--12
		  ISNULL(O.IdEstatusOperacion,0)AS IdEstatusOperacion,--13
		  ISNULL(PC.CvTipoDocFacturacion,0) AS TipoDocumentoExtranjero,--14
		  ISNULL(O.MostrarOperacion,0) AS Activo,--15
		  ISNULL(@MOTIVO_RECHAZO,'') AS MotivoRechazo --16
		  FROM MM_AceptacionPedido AS AP
		  LEFT JOIN DG_Domicilio AS DG ON DG.IdDomicilio = AP.IdDomicilioEntrega
		  LEFT JOIN PV_PaisRepublica AS PS ON PS.id = DG.IdPais
		  LEFT JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido
		  LEFT JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras
		  LEFT JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
		  LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		  
		  LEFT JOIN MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		  LEFT JOIN S_Nacionalidad AS N ON N.IdNacionalidad = PV.IdNacionalidad
		  LEFT JOIN FI_AceptacionPedido_PedimentoComprobante AS AP_PC ON AP_PC.IdAceptacionPedido=AP.IdAceptacionPedido
		  LEFT JOIN FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante=AP_PC.IdPedimentoComprobante
		  LEFT JOIN TA_Operacion O ON O.IdDocumento = PC.IdPedimentoComprobante AND O.IdTipoOperacion=16
		  WHERE P.IdSubcontratista =@IdProveedor  AND AP.IdAceptacionPedido =@IdAceptacionPedido  



		     
     END; 
