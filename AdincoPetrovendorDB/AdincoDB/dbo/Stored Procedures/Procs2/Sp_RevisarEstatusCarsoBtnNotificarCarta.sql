

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09-07-19
-- Description:	cambiar el estatus del btnCarso
-- =============================================

CREATE PROCEDURE Sp_RevisarEstatusCarsoBtnNotificarCarta
    @IdAceptacionPedido INT
AS
    BEGIN
        SET NOCOUNT ON


        SELECT BtnCartaCarso
        FROM
               dbo.MM_AceptacionPedido
        WHERE
               IdAceptacionPedido = @IdAceptacionPedido
    END
