-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<guardado de los archivos de s3 de carta cn de PEDIMENTOS/COMPROBANTES>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_GuardarArchivoCN]
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
	@nombreArchivo NVARCHAR(MAX),
	@Carpeta NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@IdUsuario INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	    INSERT INTO dbo.CN_ArchivoCartaCompraDirecta
	(
	    nombreArchivo,
	    Carpeta,
	    Mime,
	    Extension,
	    Identificador,
	    CreadoPor,
	    CreadoEl,
	    IdProveedor,
		Activo,
		IdPedimentoComprobante
	)
	VALUES
	(   
	    @nombreArchivo,         -- nombreArchivo - int
	    @Carpeta,       -- Carpeta - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @Identificador,       -- Identificador - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    @IdProveedor,          -- IdProveedor - int
		1,
		@IdPedimentoComprobante

	  );

	  SELECT SCOPE_IDENTITY() AS id
	
	

END
