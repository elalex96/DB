CREATE PROC [dbo].[sp_JOA_Desactiva]
@IdEntregable int,
@CreadoPor int
AS

DECLARE @Activo	INT;

SELECT  @Activo	= IsActivo FROM EN_Entregable WHERE IdEntregable = @IdEntregable;

IF(@Activo=1)
BEGIN
	UPDATE EN_Entregable
	SET isEliminado	=	1,
		IsActivo	=	0,
		ModificadoPor	=	@CreadoPor
	WHERE	IdEntregable	=	@IdEntregable

END
ELSE
BEGIN
	UPDATE EN_Entregable
		SET isEliminado	=	0,
			IsActivo	=	1,
			ModificadoPor	=	@CreadoPor
		WHERE	IdEntregable	=	@IdEntregable
END

