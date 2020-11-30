-- =============================================  
-- Author:  Daniel Cruz  
-- Create date: 05-02-18  
-- Description: Consultar encabezado de aceptación de pedido en genración de carta de contenido nacional  
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
    -- Insert statements for procedure here  
            
    ---Validación de Estatus de documentos  
    SET @IdEstatusUltimoAprobacionCN = (SELECT TOP 1 IdEstatus FROM MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido ORDER BY CreadoEl DESC)  
    SET @Editado = (SELECT TOP 1 Editado FROM MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido ORDER BY CreadoEl DESC)  
       
      
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
    TP.IdTipoPedido,  
    ISNULL(@Editado,0),  
    PR.IdProveedor AS ProveedorCliente      
    FROM MM_AceptacionPedido AS AP  
    INNER JOIN DG_Domicilio AS DG ON DG.IdDomicilio = AP.IdDomicilioEntrega  
    LEFT JOIN PV_PaisRepublica AS PS ON PS.id = DG.IdPais  
    INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido  
    INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras  AND PG.IdTipoPedido in (2,4, 6)
    INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras  
    LEFT JOIN MM_AceptacionCartaPCN AS AC_PCN ON AC_PCN.IdAceptacionPedido = AP.IdAceptacionPedido   
    LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido  
    WHERE P.IdSubcontratista =@IdProveedor  AND AP.IdAceptacionPedido =@IdAceptacionPedido   
  
         
     END;   
  