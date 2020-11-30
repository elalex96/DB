CREATE PROCEDURE [dbo].[EN_ModificarMarcoLegal]
	@MarcoLegal VARCHAR(MAX),
	@IdMarcoLegal INT,
    @idUsuario INT,
    @idContrato INT,
	@activo bit
AS
BEGIN
	-- =================================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 03/01/2019
	-- Description:	Modificación de datos en la tabla EN_MarcoLegal
	-- =================================================================
	-- Author:		Reyna Olvera
	-- Create date: 27/09/2019
	-- Description: Modifica datos del marco legal
	-- =================================================================
	SET NOCOUNT ON;
	UPDATE EN_MarcoLegal
	SET MarcoLegal = @MarcoLegal,
	Activo=@activo
	WHERE IdMarcoLegal = @IdMarcoLegal
END

