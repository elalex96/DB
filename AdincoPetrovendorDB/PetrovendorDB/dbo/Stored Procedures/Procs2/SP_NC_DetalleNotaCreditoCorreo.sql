-- =============================================
-- Author: Daniel AC
-- Create date: 02/0/8/2019
-- Description:	Consultar y actualizar estatus de la tarea de tipo serial
-- =============================================
CREATE  PROCEDURE [dbo].[SP_NC_DetalleNotaCreditoCorreo]  
    @IdProveedor INT,
    @IdNotaCredito INT,
    @IdOperacion INT

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;	    

    SELECT A.IdOperacion,--0          
           PG.IdPedido,--1
           AP.IdAceptacionPedido,--2
           NC.IdAceptacionNotaCredito,--3
           P.IdSolicitudPedido,--4
		   E.Nombre
    FROM dbo.TA_Operacion A 
        LEFT JOIN dbo.MM_AceptacionNotaCredito NC
            ON NC.IdAceptacionNotaCredito = A.IdDocumento
               
        LEFT JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        LEFT JOIN dbo.MM_Pedido P
            ON P.IdPedido = AP.IdPedido
        LEFT JOIN dbo.MM_Pedidos PG
            ON PG.IdIdentificador = P.IdPedido
               AND PG.IdProveedorCliente = P.IdProveedorCompras
		LEFT JOIN dbo.TA_Estatus E ON E.IdEstatus=A.IdEstatusOperacion
    WHERE A.IdOperacion = @IdOperacion 
          AND A.IdDocumento=@IdNotaCredito
		  AND A.IdTipoOperacion = 17 -->Aprobación de nota de crédito

END;

