CREATE PROCEDURE [dbo].[WDEA_EditarWBS]
@WBS varchar(300),
@IdContrato int,
@IdUsuario int,
@Id int
AS
BEGIN

	IF exists (SELECT 1
	FROM petrovendor..WDEA_WBS
	WHERE 
	idcontrato = @IdContrato 
	and LTRIM(RTRIM(WBS)) = LTRIM(RTRIM(@WBS))
	and activo = 1) 
	BEGIN

		SELECT 'YA_EXISTE' as Error

	END
	ELSE
	BEGIN

		Update WDEA_WBS
		set ModificadoEl = GETDATE(),
		ModificadoPor = @IdUsuario,
		WBS = @WBS
		where Id = @Id

	END
	
END