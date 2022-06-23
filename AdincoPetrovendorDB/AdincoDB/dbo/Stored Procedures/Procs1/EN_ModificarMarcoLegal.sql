USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[EN_ModificarMarcoLegal]    Script Date: 20/06/2022 05:24:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Valeria Rodríguez
-- Create date: 03/01/2019
-- Description:	Modificación de datos en la tabla EN_MarcoLegal
-- =================================================================
-- =================================================================
-- Author:	Luis David
-- Create date: 27/09/2019
-- Description:	se agrega el bitjoa y nombreeningles para el issue 419
-- =================================================================
-- Author:		Reyna Olvera
-- Create date: 27/09/2019
-- Description: Modifica datos del marco legal
-- =================================================================
-- =================================================================
-- Author: Alexander Gomez
-- Create date: 20/06/2022
-- Description:	se agrega el Alias
-- =================================================================
ALTER PROCEDURE [dbo].[EN_ModificarMarcoLegal]
	@MarcoLegal VARCHAR(MAX),
	@IdMarcoLegal INT,
    @idUsuario INT,
    @idContrato INT,
	@activo bit,
	@MarcoLegalIngles VARCHAR(MAX) = null,
	@BitJoa bit = null,
	@Alias VARCHAR(1000)
AS
BEGIN

	SET NOCOUNT ON;
	UPDATE EN_MarcoLegal
	SET MarcoLegal = @MarcoLegal,
	Activo=@activo,
	MarcoLegalIngles = @MarcoLegalIngles,
	BitJOA = @BitJoa,
	ModificadoPor = @idUsuario,
	ModificadoEn = GETDATE(),
	Alias = @Alias
	WHERE IdMarcoLegal = @IdMarcoLegal
END