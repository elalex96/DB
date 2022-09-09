-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- ========================================================================
-- Modificado Por:		Neri del Angel
-- Fecha Modificación:	07 de Septiembre del 2022
-- Descripción:			Se cambia guardado de IdEstado a CO_RegistroMarkup y se agrega variable de @MesEstadoPemex 
-- ========================================================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoRegistroActualizar]
    @IdRegistro INT,
    @IdEstado INT,
    @IdUsuario INT,
	@MesEstadoPemex DATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE CO_RegistroMarkup
    SET IdEstadoPemex = @IdEstado,
        MesEstadoPemex = @MesEstadoPemex
    WHERE GastoId = @IdRegistro
    --
    IF @@ERROR <> 0
        SELECT 'false' AS msj
    ELSE
        SELECT 'true' AS msj
END

