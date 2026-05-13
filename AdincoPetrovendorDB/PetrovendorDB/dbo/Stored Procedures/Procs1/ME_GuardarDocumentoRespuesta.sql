
CREATE procedure [dbo].[ME_GuardarDocumentoRespuesta]
	@IdRespuesta INT,
	@Nombre VARCHAR(max),
	@Documento NVARCHAR(max),
	@IdPedido INT

AS
BEGIN
	INSERT INTO dbo.ME_DocumentoRespuesta
	(
	    IdRespuesta,
	    Nombre,
	    Documento,
		IdPedido
	)
	VALUES
	(   @IdRespuesta,  -- IdRespuesta - int
	    @Nombre, -- Nombre - varchar(max)
	    @Documento,
		@IdPedido
	)
END
