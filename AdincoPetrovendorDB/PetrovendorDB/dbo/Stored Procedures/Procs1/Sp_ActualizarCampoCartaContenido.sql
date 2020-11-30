-- =============================================
-- Author:		Pedro Acuña
-- Create date: 21/10/2019
-- Description:	Actualiza el campo de carta de contenido nacional
-- =============================================
CREATE PROCEDURE [dbo].[Sp_ActualizarCampoCartaContenido]
    @CheckCarta BIT,
    @IdAceptacionPedido INT
AS
BEGIN
    DECLARE @IdPedido INT,
            @CheckAnterior BIT



    SELECT @IdPedido = IdPedido,
           @CheckAnterior = PedirCarta
    FROM dbo.RelacionCartaCNPedido

    UPDATE dbo.RelacionCartaCNPedido
    SET PedirCarta = @CheckCarta
    WHERE IdAceptacionPedido = @IdAceptacionPedido
	/*INICIA 
	JG: Se agrega validacion para que en caso de que SE EXCEPTUE la carta de CN, 
	se cambie el valor del rubro que pasa al gasto de ADINCO a 7 (7= EXCEPTUADO) Si se cambia el valor a true
	Se modifica el valor a null para que posteriormente se registre el rubro en la aprobacion de CN*/
	IF(@CheckCarta = 'false')
	BEGIN
		update MM_aceptacionPedidoDetalle set ClasificacionCN = 7 where idaceptacionpedido = @IdAceptacionPedido
	END
	ELSE
	BEGIN
		update MM_aceptacionPedidoDetalle set ClasificacionCN = NULL where idaceptacionpedido = @IdAceptacionPedido
	END
	/*TERMINA*/
	
    INSERT INTO dbo.RelacionCartaCNPedidoModificado
    (
        IdPedido,
        IdAceptacionPedido,
        PedirCartaAnterior,
        ModificadoEl
    )
    SELECT @IdPedido,
           @IdAceptacionPedido,
           @CheckAnterior,
           GETDATE()

	SELECT 1 -- retorno a la vista
END



