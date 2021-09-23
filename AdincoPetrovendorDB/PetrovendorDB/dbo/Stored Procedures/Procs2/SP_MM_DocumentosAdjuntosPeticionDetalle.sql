drop procedure if exists SP_MM_DocumentosAdjuntosPeticionDetalle
go
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Oferta 
-- Author: Daniel AC
-- Update date: 10/05/2018
-- Description: SE AGREGO FILTRO DE ACTIVO Y AGREGO COLUMNAS DE RETORNO DE INFORMACIÓN DE ARCHIVO S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_DocumentosAdjuntosPeticionDetalle]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@IdPeticionOfertaDetalle int,
	@CONSULTA NVARCHAR(300),
	@IdDocumentoAnexo int 
 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

	IF @CONSULTA='DOCUMENTOS_LISTA'
		 BEGIN 
			SELECT IdDocumentoAnexo,Nombre
			FROM dbo.MM_DocumentosAnexos
			WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			AND Activo=1
		 END 
	 
	 IF @CONSULTA='DOCUMENTO'
		 BEGIN 
			SELECT IdDocumentoAnexo,Nombre,'' AS Documento, Carpeta, Identificador, Extension, Mime,isnull(Bucket,'')as Bucket
			FROM dbo.MM_DocumentosAnexos
			WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
			AND IdDocumentoAnexo = @IdDocumentoAnexo
		 END 

END
