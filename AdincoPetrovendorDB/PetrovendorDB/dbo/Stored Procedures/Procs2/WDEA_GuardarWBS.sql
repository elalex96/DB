USE Petrovendor
GO
DROP PROCEDURE IF EXISTS WDEA_GuardarWBS
GO
CREATE PROCEDURE WDEA_GuardarWBS
@WBS varchar(300),
@IdContrato int,
@IdUsuario int
AS
BEGIN
	IF exists (SELECT 1
	FROM petrovendor..WDEA_WBS
	WHERE 
	idcontrato = @IdContrato 
	and WBS = @WBS
	and activo = 1) 
	BEGIN
		SELECT 'YA_EXISTE' as Error
	END
	ELSE 
	BEGIN
	IF EXISTS (SELECT 1
		FROM petrovendor..WDEA_WBS
		WHERE
		idcontrato = @IdContrato 
		and LTRIM(RTRIM(WBS)) = LTRIM(RTRIM(@WBS))
		and activo = 0)
		BEGIN
			UPDATE petrovendor..WDEA_WBS
			SET ACTIVO = 1
			WHERE WBS = LTRIM(RTRIM(@WBS))
			AND IdContrato = @IdContrato
		END
		ELSE 
		BEGIN
			INSERT INTO WDEA_WBS 
			(WBS,				CreadoEl,	CreadoPor,	IdContrato,Activo) 
			VALUES
			(LTRIM(RTRIM(@WBS)),GETDATE(),	@IdUsuario,	@IdContrato,1)
		END	
	end
END
