
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <04-12-2018>
-- Description:	<Se guarda los datos del archivo PDF del complemento>
-- =============================================

CREATE PROCEDURE FI_SP_GuardarPDFComplemento	
	@IdFacturaComplemento INT,
	@NombreDoc NVARCHAR(100),
	@Mime NVARCHAR(100),
	@Identificador NVARCHAR(100),
	@Carpeta NVARCHAR(100),
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	DECLARE @ExistePDF INT

	SET @ExistePDF = (SELECT COUNT(IdPDFComplemento) FROM dbo.FI_PDFComplemento WHERE IdFacturaComplemento = @IdFacturaComplemento AND Activo = 1)

	IF(@ExistePDF > 0)
	BEGIN
		UPDATE dbo.FI_PDFComplemento
		SET Activo = 0
		WHERE IdFacturaComplemento = @IdFacturaComplemento
	END
	
	INSERT INTO dbo.FI_PDFComplemento
	(
	    IdFacturaComplemento,
	    NombreDoc,
	    Mime,
	    Identificador,
	    Carpeta,
	    Activo,
	    SubidoPor,
	    SubidoEl
	)
	VALUES
	(   @IdFacturaComplemento,        -- IdFacturaComplemento - int
	    @NombreDoc,      -- NombreDoc - nvarchar(100)
	    @Mime,      -- Mime - nvarchar(50)
	    @Identificador,      -- Identificador - nvarchar(100)
	    @Carpeta,      -- Carpeta - nvarchar(100)
	    1,     -- Activo - bit
	    @IdUsuario,        -- SubidoPor - int
	    GETDATE() -- SubidoEl - datetime
	)
END