CREATE PROCEDURE [dbo].[Sp_CarsoBtnNotificarCarta] @IdAceptacionPedido INT
AS
    BEGIN
        UPDATE dbo.MM_AceptacionPedido
        SET    BtnCartaCarso = 1
        WHERE
               IdAceptacionPedido = @IdAceptacionPedido
    END
