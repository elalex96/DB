CREATE PROC p_CO_SAP_ImportMaxFila_INSUPD
@pIdContratista INT,
@pFilaMaxPO INT,
@pFilaMaxSES INT,
@pFilaMaxGR INT,
@pUsuarioId INT
AS
BEGIN

	IF EXISTS (
		SELECT 1
		FROM [dbo].[CO_SAP_ImportMaxFila]
		WHERE IdContratista = @pIdContratista
	)
	BEGIN
		UPDATE [CO_SAP_ImportMaxFila]
		SET FilaMaxSES = @pFilaMaxSES,
			FilaMaxPO = @pFilaMaxPO,
			FilaMaxGR = @pFilaMaxGR,
			ModificadoPor = @pUsuarioId,
			ModificadoEl = GETDATE()
		WHERE IdContratista = @pIdContratista
	END
	ELSE
	BEGIN
		INSERT INTO [CO_SAP_ImportMaxFila](
			IdContratista,FilaMaxSES,FilaMaxPO,FilaMaxGR,ModificadoPor,ModificadoEl
		)
		VALUES(@pIdContratista,@pFilaMaxSES,@pFilaMaxPO,@pFilaMaxGR,@pUsuarioId,GETDATE())
	END

END