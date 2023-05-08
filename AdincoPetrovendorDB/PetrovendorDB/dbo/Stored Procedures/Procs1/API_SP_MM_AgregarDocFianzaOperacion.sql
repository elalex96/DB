-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================

CREATE PROCEDURE [dbo].[API_SP_MM_AgregarDocFianzaOperacion] @IdProveedor INT, @NombreDoc VARCHAR(MAX) ,
															 @Documento NVARCHAR(MAX), @IdOperacion INT ,
															 @Mime NVARCHAR(MAX) = NULL ,
															 @Indentificador NVARCHAR(MAX) = NULL ,
															 @Carpeta NVARCHAR(MAX) = NULL ,
															 @Extension NVARCHAR(MAX) = NULL
AS
	BEGIN
		INSERT INTO dbo.TA_DocFianzaOperacion
			( IdProveedor, NombreDoc, Documento, IdOperacion, Activo )
		VALUES
			( @IdProveedor ,	-- IdProveedor - int
			  @NombreDoc ,		-- NombreDoc - varchar(max)
			  @Documento ,		-- Documento - nvarchar(max)
			  @IdOperacion ,	-- IdOperacion - int
			  1 )
	END