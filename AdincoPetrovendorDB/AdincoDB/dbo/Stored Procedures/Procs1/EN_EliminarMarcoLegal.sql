CREATE PROCEDURE [dbo].[EN_EliminarMarcoLegal]
	@idUsuario INT,
	@idContrato INT,
	@IdMarcoLegal int
AS
BEGIN
	-- =================================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 03/01/2019
	-- Description:	Eliminar datos en la tabla EN_MarcoLegal
	-- =================================================================
   -- Author:	Reyna Olvera
	-- Create date: 27/09/2019
	-- Description:	Desactiva los marcos legales
	-- =================================================================
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	UPDATE  dbo.EN_MarcoLegal 
	SET Activo=0,
	ModificadoEn=GETDATE(),
	ModificadoPor=@idUsuario
	WHERE (IdMarcoLegal = @IdMarcoLegal)
END

