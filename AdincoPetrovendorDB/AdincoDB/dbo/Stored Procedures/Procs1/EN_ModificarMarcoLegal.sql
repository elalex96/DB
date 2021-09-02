DROP PROCEDURE IF EXISTS EN_ModificarMarcoLegal
GO
-- =================================================================
-- Author:	Luis David
-- Create date: 27/09/2019
-- Description:	se agrega el bitjoa y nombreeningles para el issue 419
-- =================================================================
CREATE PROCEDURE [dbo].[EN_ModificarMarcoLegal]
	@MarcoLegal VARCHAR(MAX),
	@IdMarcoLegal INT,
    @idUsuario INT,
    @idContrato INT,
	@activo bit,
	@MarcoLegalIngles VARCHAR(MAX) = null,
	@BitJoa bit = null
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
	Activo=@activo,
	MarcoLegalIngles = @MarcoLegalIngles,
	BitJOA = @BitJoa,
	ModificadoPor = @idUsuario,
	ModificadoEn = GETDATE()
	WHERE IdMarcoLegal = @IdMarcoLegal
END
