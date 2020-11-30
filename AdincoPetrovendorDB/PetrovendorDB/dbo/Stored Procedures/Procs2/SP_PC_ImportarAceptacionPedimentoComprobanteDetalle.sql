-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	IMPORTAR LOS MATERIALES QUE FUERON REGISTARDOS EN UNA ACEPTACIÓN DE PEDIDO
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ImportarAceptacionPedimentoComprobanteDetalle]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdAceptacionPedido INT,
    @IdPedimentoComprobante INT,
    @IdContrato INT,
    @IdUsuario INT,
    @TipoRegistro NVARCHAR(50)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

    IF @IdPedimentoComprobante = 0
	BEGIN 

        SET @IdPedimentoComprobante = NULL;
	END 


    INSERT INTO dbo.FI_PedimentoComprobanteDetalle
    (
        IdPedimentoComprobante,
        IdUnidadMedida,
        NumeroSerieMercancia,
        DescripcionMercancia,
        PrecioUnitario,
        Cantidad,
        ImporteTotal,
        CreadoPor,
        CreadoEn,
        IsEliminado,
        IsActivo,
        IsBorrador,
        IdAceptacionPedido,
        IdMaterialImportado,
        IdAceptacionPedidoDetalle
    )

    SELECT @IdPedimentoComprobante,
           POD.IdUnidadProveedor,
           '',
           POD.MaterialCotizadoTextoC AS DescripcionMercancia,
           PD.PrecioUnitario,
           APD.Cantidad,
           (ISNULL(PD.PrecioUnitario, 0) * ISNULL(APD.Cantidad, 0)),
           @IdUsuario,
           GETDATE(),
           0,
           1,
           1,
           @IdAceptacionPedido,
           PD.IdMaterialVendedor AS IdMaterial,
           APD.IdAceptacionPedidoDetalle
    FROM MM_AceptacionPedidoDetalle AS APD
        INNER JOIN MM_AceptacionPedido AS A
            ON A.IdAceptacionPedido = APD.IdAceptacionPedido
        INNER JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = A.IdPedido
        INNER JOIN MM_PeticionOferta AS PO
            ON PO.IdPeticionOferta = P.IdPeticionOferta
        INNER JOIN MM_PeticionOfertaDetalle AS POD
            ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
        INNER JOIN PV_TipoMoneda AS TM
            ON TM.IdMoneda = PD.IdMoneda
    WHERE P.IdSubcontratista = @IdProveedor
          AND A.IdAceptacionPedido = @IdAceptacionPedido
    GROUP BY APD.IdAceptacionPedidoDetalle,
             PD.IdMaterialVendedor,
             POD.MaterialCotizadoTextoC,
             POD.IdUnidadProveedor,
             APD.Cantidad,
             PD.PrecioUnitario;


	 SELECT 'SUCCESS'

END;


