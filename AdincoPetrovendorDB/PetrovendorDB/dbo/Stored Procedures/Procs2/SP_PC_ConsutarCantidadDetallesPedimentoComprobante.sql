-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Consultar las lineas de comprobante o pedimento 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsutarCantidadDetallesPedimentoComprobante]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT
   
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	SELECT COUNT(PCD.IdPedimentoComprobanteDetalle)
	FROM dbo.FI_PedimentoComprobanteDetalle PCD
	INNER JOIN dbo.MM_AceptacionPedido AP ON PCD.IdAceptacionPedido=AP.IdAceptacionPedido
	WHERE PCD.IdAceptacionPedido=@IdAceptacionPedido AND PCD.IsActivo=1
END;
 