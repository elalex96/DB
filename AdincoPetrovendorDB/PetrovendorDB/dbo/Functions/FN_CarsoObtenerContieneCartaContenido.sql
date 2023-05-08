-- =============================================
-- Author:		Pedro Acuña
-- Create date: 08/JUL/2019
-- Description: Retorna si la aceptacion de servicio ya se presiono el btn de notificacion la carta de contenido
-- =============================================

CREATE FUNCTION FN_CarsoObtenerContieneCartaContenido
(
    @IdOC VARCHAR(8000),
    @Asiento VARCHAR(8000),
    @DataAreaId VARCHAR(400),
    @RecId NVARCHAR(MAX)
)
RETURNS NVARCHAR(250)
AS
BEGIN
    DECLARE @TextoRetorno NVARCHAR(250) = N''


    IF EXISTS
    (
        SELECT 1
        FROM dbo.MM_AceptacionPedido ap
            INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
        WHERE ap.IdOcCarso = @IdOC
              AND ap.Asiento = @Asiento
              AND ISNULL(ap.BtnCartaCarso, 0) = 1
              AND ISNULL(ap.IdEstatusEliminado, 0) <> 1
              AND UPPER(apd.DataAreaId) = UPPER(@DataAreaId)
              AND ISNULL(apd.RecId, '0') = @RecId
    )
        SET @TextoRetorno
            = N'No es posible generar la remisión por que fue notificado el proveedor para subir Carta Contenido'


    RETURN @TextoRetorno
END

