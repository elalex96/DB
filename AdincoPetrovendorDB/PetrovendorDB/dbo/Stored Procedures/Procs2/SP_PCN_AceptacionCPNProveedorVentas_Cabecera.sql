-- =============================================  
-- Author:  Daniel Cruz  
-- Create date: 05-02-18  
-- Description: Consultar encabezado de aceptación de pedido en genración de carta de contenido nacional  
-- ============================================= 
-- =============================================  
-- Author:  Alexander Gomez 
-- Create date: 19-02-21 
-- Description: Validacion para verificar la reclasifiacion de aceptacion
-- =============================================  
-- Author:		Luis David
-- Create date: <02/09/2022>
-- Description:	<Se optimiza para el Issue #1986>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_AceptacionCPNProveedorVentas_Cabecera]   
 -- Add the parameters for the stored procedure here  
@IdProveedor        INT,  
@IdAceptacionPedido INT  
  
AS  
     BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
         SET NOCOUNT ON;  
   DECLARE @IdEstatusUltimoAprobacionCN INT;  
   DECLARE @Editado BIT;  
   DECLARE @RECLASIFICADO BIT = 0;
    -- Insert statements for procedure here  
            
    ---Validación de Estatus de documentos  
    SET @IdEstatusUltimoAprobacionCN = (SELECT TOP 1 IdEstatus FROM MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido ORDER BY CreadoEl DESC)  
    SET @Editado = (SELECT TOP 1 Editado FROM MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido ORDER BY CreadoEl DESC)  

	--VALIDACION DE RECLASIFICACION
    IF EXISTS(SELECT 1 FROM dbo.MM_AceptacionPedidoDetalle WHERE IdAceptacionPedido = @IdAceptacionPedido AND IdAnterior IS NOT NULL)
	BEGIN

		SET @RECLASIFICADO = 1;

	END
      
    SELECT   
    AP.IdAceptacionPedido,   
    AP.IdPedido,   
    AP.NombreRecibidoPor,   
    AP.NombreUsuarioEntrega,  
    AP.Creado,  
    ISNULL(PR.RazonSocial,'')+' '+ ISNULL(PR.RegimenCapital,'') AS Proveedor,  
    ISNULL(AP.PCN_Agregado,0) AS PCN_Agregado,   
    ISNULL(AP.DocumentoDescargado,0) AS DocumentoCargado,  
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
                 ) AS Direccion,        
    ISNULL(@IdEstatusUltimoAprobacionCN,0) AS Estatus,  
    PG.IdPedido AS IdPedidoGeneral,  
    PG.IdTipoPedido,  
 ISNULL(@Editado,0),  
    PR.IdProveedor AS ProveedorCliente      ,
	@RECLASIFICADO AS AceptacionReclasificada
    FROM MM_AceptacionPedido AS AP  
    INNER JOIN DG_Domicilio AS DG 
		ON AP.IdDomicilioEntrega = DG.IdDomicilio
    INNER JOIN MM_Pedido AS P 
		ON AP.IdPedido = P.IdPedido  
    INNER JOIN MM_Pedidos AS PG 
		ON P.IdPedido = PG.IdIdentificador 
		AND P.IdProveedorCompras = PG.IdProveedorCliente
		AND PG.IdTipoPedido in (2,4, 6)
    INNER JOIN S_Proveedor AS PR 
		ON P.IdProveedorCompras = PR.IdProveedor
    WHERE P.IdSubcontratista =@IdProveedor  AND AP.IdAceptacionPedido =@IdAceptacionPedido   
END; 