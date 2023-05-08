

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09-07-19
-- Description:	cambiar el estatus del btnCarso, se modifica la logica ya que cuando era nulo el campo en el codigo con que devuelva una linea se pone en verdadero la bandera
-- =============================================

CREATE PROCEDURE Sp_RevisarEstatusCarsoBtnNotificarCarta @IdAceptacionPedido INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @ExisteBtn BIT

    SELECT @ExisteBtn = ISNULL(BtnCartaCarso, 0)
    FROM dbo.MM_AceptacionPedido
    WHERE IdAceptacionPedido = @IdAceptacionPedido


    IF (@ExisteBtn = 1)
    BEGIN
        SELECT 1
    END
END
