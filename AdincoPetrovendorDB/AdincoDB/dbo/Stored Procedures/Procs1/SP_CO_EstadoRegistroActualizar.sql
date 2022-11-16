-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- ========================================================================
-- Modificado Por:		Neri del Angel
-- Fecha Modificación:	07 de Septiembre del 2022
-- Descripción:			Se cambia guardado de IdEstado a CO_RegistroMarkup y se agrega variable de @MesEstadoPemex 
-- ========================================================================
-- Modificado Por:		Reyna Olvera
-- Fecha Modificación:	16 de Noviembre del 2022
-- Descripción:			Se modifica el guardado para agregar el Importe Estimado Parcial 
-- ========================================================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoRegistroActualizar]
    @IdRegistro INT,
    @IdEstado INT,
    @IdUsuario INT,
	@MesEstadoPemex DATE,
	@ImporteEstimadoParcial FLOAT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @MultiplicacionPosNeg FLOAT = 1;
	SELECT @MultiplicacionPosNeg = 
	CASE 
	WHEN MontoRegistro < 0
		THEN -1
		ELSE 1
	END
	FROM CO_REGISTRO WHERE IdRegistro = @IdRegistro;
	
	SET @ImporteEstimadoParcial =ABS(ISNULL(@ImporteEstimadoParcial,0))*@MultiplicacionPosNeg;

	INSERT INTO CO_RegistroMarkupBitacora(IdRegistro, IdEstadoAnterior,IdEstadoActual, MesEstadoPemexAnterior, MesEstadoPemexActual, 
	CreadoPor, CreadoEn,ImporteEstimadoParcialAnterior,ImporteEstimadoParcialActual)
	SELECT @IdRegistro, IdEstadoPemex, @IdEstado, MesEstadoPemex, @MesEstadoPemex, @IdUsuario, GETDATE(),ImporteEstimadoParcial, @ImporteEstimadoParcial
	FROM CO_RegistroMarkup 
	WHERE GastoId = @IdRegistro

    UPDATE CO_RegistroMarkup
    SET IdEstadoPemex = @IdEstado,
        MesEstadoPemex = @MesEstadoPemex,
		ImporteEstimadoParcial = 
		CASE 
				WHEN @ImporteEstimadoParcial = 0
				THEN NULL
				ELSE @ImporteEstimadoParcial
		END
    WHERE GastoId = @IdRegistro
    --
    IF @@ERROR <> 0
        SELECT 'false' AS msj
    ELSE
        SELECT 'true' AS msj
END