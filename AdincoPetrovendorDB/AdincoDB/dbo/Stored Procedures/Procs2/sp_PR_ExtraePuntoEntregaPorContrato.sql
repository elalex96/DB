-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180824
-- Description:	<Description,,>
-- =============================================
create PROCEDURE sp_PR_ExtraePuntoEntregaPorContrato
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT CO_PuntosdeEntrega.PuntoEntregaID AS PuntoEntregaID,
           dbo.CO_PuntosdeEntrega.Nombre AS Nombre,
           TagPatinMedicion,
           TipoMedidor,
           TagMedidor,
           Clasificacion,
		   CO_PuntosdeEntrega.Activo AS Activo
    FROM dbo.CO_PuntosdeEntrega
        JOIN dbo.CO_PuntosdeEntregaContrato
            ON CO_PuntosdeEntregaContrato.PuntoEntregaID = CO_PuntosdeEntrega.PuntoEntregaID
    WHERE idContrato = @IdContrato;
END;