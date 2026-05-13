-- =============================================
-- Author:		<Jose Roman>
-- Create date: <03-07-2018>
-- Description:	<Se guarda el XML>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 11/01/2019
-- Description:	VALIDACION DE REEMPLAZO DE XML
-- =============================================

CREATE PROCEDURE [dbo].[FI_SP_InsertarXMLDocument]
    @ArchivoXML IMAGE,
    @HashSHA256 NVARCHAR(600),
    @IdFactura INT,
    @IdAceptacionPedido INT = NULL,
    @IdFacturaS INT = NULL,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    IF (@IdAceptacionPedido IS NOT NULL)
    BEGIN
        SET @IdContrato =
        (
            SELECT SP.IdContrato
            FROM MM_SolicitudPedido AS SP
                INNER JOIN MM_Pedido AS P
                    ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                INNER JOIN MM_AceptacionPedido AS AP
                    ON AP.IdPedido = P.IdPedido
            WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
        );
    END;
    ELSE
    BEGIN
        SET @IdContrato =
        (
            SELECT SP.IdContrato
            FROM MM_SolicitudPedido AS SP
                INNER JOIN MM_Pedido AS P
                    ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                INNER JOIN MM_AceptacionPedido AS AP
                    ON AP.IdPedido = P.IdPedido
                INNER JOIN dbo.MM_AceptacionFactura AS af
                    ON af.IdAceptacionPedido = AP.IdAceptacionPedido
            WHERE af.IdFactura = @IdFacturaS
        );
    END;

    DECLARE @COUNT_FACTURA INT = (
                                     SELECT COUNT(IdArchivoXml)
                                     FROM dbo.FI_ArchivoXml
                                     WHERE IdFactura = @IdFactura
                                 );

    IF @COUNT_FACTURA > 0
    BEGIN
        UPDATE dbo.FI_ArchivoXml
        SET ArchivoXml = @ArchivoXML,
            HashSHA256 = @HashSHA256,
            --IdFactura=@IdFactura,
            IdContrato = @IdContrato,
            CreadoPor = @IdUsuario,
            CreadoEl = GETDATE(),
            ModificadoPor = @IdUsuario,
            ModificadoEl = GETDATE(),
            Activo = 1
        WHERE IdFactura = @IdFactura;

		SELECT IdArchivoXml FROM dbo.FI_ArchivoXml WHERE IdFactura=@IdFactura

    END;
    ELSE
    BEGIN
        INSERT INTO dbo.FI_ArchivoXml
        (
            ArchivoXml,
            HashSHA256,
            IdFactura,
            IdContrato,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            Activo
        )
        VALUES
        (   @ArchivoXML, -- ArchivoXml - image
            @HashSHA256, -- HashSHA256 - nvarchar(600)
            @IdFactura,  -- IdFactura - int
            @IdContrato, -- IdContrato - int
            @IdUsuario,  -- CreadoPor - int
            GETDATE(),   -- CreadoEl - datetime
            NULL,        -- ModificadoPor - int
            NULL,        -- ModificadoEl - datetime
            1            -- Activo - bit
            );

        SELECT @@IDENTITY;
    END;

END;

