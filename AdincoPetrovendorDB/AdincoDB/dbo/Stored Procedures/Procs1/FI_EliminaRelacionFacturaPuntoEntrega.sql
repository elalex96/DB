CREATE PROCEDURE [dbo].[FI_EliminaRelacionFacturaPuntoEntrega]
    @idContrato            INT,
    @idUsuario             INT,
    @idFacturaPuntoEntrega INT
AS
BEGIN
-- =============================================
-- Author:		reyna Olvera
-- Create date: 16/04/18
-- Description:Solo elimina las relaciones de las facturas con os puntos de entrega
-- =============================================
    SET NOCOUNT ON

    DECLARE @MesReporte DATE

    SELECT
        @MesReporte = MesReporte
    FROM
        dbo.FI_FacturaPuntoEntrega
    WHERE
        idfacturaPuntoEntrega = @idFacturaPuntoEntrega

    UPDATE	com
    SET
            IdFactura = 0,
			ModificadoEl	=	GETDATE(),
			ModificadoPor	=	@idUsuario
    FROM
            COM_OperacionComercializacion com
    JOIN
        FI_FacturaPuntoEntrega        FPE
        ON com.IdFactura = FPE.idFactura
        AND com.PuntoEntregaID = FPE.PuntoEntregaId
        AND com.MesReporte = FPE.MesReporte
    WHERE
		FPE.idfacturaPuntoEntrega = @idFacturaPuntoEntrega
		AND com.MesReporte = @MesReporte

    DELETE
        FI_FacturaPuntoEntrega
    WHERE
        idfacturaPuntoEntrega = @idFacturaPuntoEntrega
END
