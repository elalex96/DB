CREATE PROC [dbo].[p_EN_EliminarEntregable]--13139,10061
@pIdEntregable int,
@pCreadoPor int
AS
--select * from EN_Entregable where IdEntregable=13139

DECLARE @Activo	INT;

SELECT  @Activo	= IsActivo FROM EN_Entregable WHERE IdEntregable = @pIdEntregable;

IF(@Activo=1)
BEGIN
	UPDATE EN_Entregable
	SET isEliminado	=	1,
		IsActivo	=	0,
		ModificadoPor	=	@pCreadoPor
	WHERE	IdEntregable	=	@pIdEntregable

END
ELSE
BEGIN
	UPDATE EN_Entregable
		SET isEliminado	=	0,
			IsActivo	=	1,
			ModificadoPor	=	@pCreadoPor
		WHERE	IdEntregable	=	@pIdEntregable
END
