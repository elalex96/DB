
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <02-03-2018>
-- Description:	<Se guarda documento para una SolPed>
-- =============================================

CREATE PROCEDURE MM_SP_GuardarDocumentoSolPed @IdSolPed INT, @Documento NVARCHAR(MAX), @Nombre VARCHAR(100) ,
												/*--------------------parametros contrato  --------------------*/
											  @IdContrato INT = NULL, @IdUsuario INT = NULL ,
											  @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN

		INSERT INTO dbo.MM_DocumentosSolPed
			( IdSolPed, Documento, NombreDoc, Activo )
		VALUES
			( @IdSolPed ,	-- IdSolPed - int
			  @Documento ,	-- Documento - nvarchar(max)
			  @Nombre ,		-- NombreDoc - varchar(100)
			  1 )
	END