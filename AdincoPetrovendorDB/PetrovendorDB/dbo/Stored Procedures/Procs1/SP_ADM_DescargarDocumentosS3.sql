DROP PROCEDURE IF EXISTS SP_ADM_DescargarDocumentosS3
GO
-- =============================================
-- Author: Pedro Acuña
-- Create date: 18/09/2018
-- Description:	Descarga de los documentos cargados en procura Tipo Documento (ADM_TipoDocumentosS3)
--1 Documentos por material SolPed
--2 Documentos Anexos SolPed 
--3 Fianza solOferta
--4 Bases solOferta
--5 Adj Directa Justificacion solOferta
--6 Mercadeo Justificacion solOferta
--7 Aceptacion de servicio
-- =============================================
-- =============================================
-- Author:	Luis David De La Cruz 
-- Create date: 07/09/2021
-- Description:	Se agrega el bucket en la descarga para la estandarización de descarga amazon s3
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: 06/01/2022
-- Description:	Revision del sp, ya que se mando un sp fix con variables estaticas a PR
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADM_DescargarDocumentosS3] @TipoDocumento INT, @IdDocumento INT
AS
	BEGIN
		--1 Documentos por material SolPed
		IF(@TipoDocumento=1)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreArchivoAdjunto,ISNULL(Bucket,'') AS Bucket
				FROM	MM_SolPedArchivoAdjuntoMaterial
				WHERE	IdSolPedMaterialDocumentoAdj=@IdDocumento
			END

		--2 Documentos Anexos SolPed 
		IF(@TipoDocumento=2)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreDoc, ISNULL(Bucket,'') AS Bucket
				FROM	MM_DocumentosSolPed
				WHERE	IdDocumento=@IdDocumento
			END

		--3 Fianza solOferta
		IF(@TipoDocumento=3)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreDoc,ISNULL(Bucket,'') AS Bucket
				FROM	TA_DocFianzaOperacion
				WHERE	IdDocFianza=@IdDocumento
			END

		--4 Bases solOferta
		IF(@TipoDocumento=4)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreDoc, ISNULL(Bucket,'') AS Bucket
				FROM	TA_DocBasesOperacion
				WHERE	IdDocBases=@IdDocumento
			END

		--5 Adj Directa Justificacion solOferta
		IF(@TipoDocumento=5)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreDocumento, ISNULL(Bucket,'') AS Bucket
				FROM	MM_PeticionOfertaADAdjunto
				WHERE	IdDocumento=@IdDocumento
			END

		--6 Mercadeo Justificacion solOferta
		IF(@TipoDocumento=6)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreDocumento,ISNULL(Bucket,'') AS Bucket
				FROM	MM_PeticionOfertaMercadeoAdjunto
				WHERE	Id=@IdDocumento
			END

		--7 Aceptacion de servicio
		IF(@TipoDocumento=7)
			BEGIN
				-- DW Se agregó columna Buccket
				SELECT	doc.Carpeta, doc.Identificador, doc.Mime, doc.NombreDocumento,isnull(doc.Bucket,''), doc.Extension
				FROM	MM_AceptacionDocumento acep
						INNER JOIN dbo.S_Documento_S3 doc ON doc.IdDocumento=acep.IdDocumento
				WHERE	doc.IdDocumento=@IdDocumento
			END

		--8 Cotizacion/Oferta por Material
		IF(@TipoDocumento=8)
			BEGIN
				SELECT	doc.Carpeta, doc.Identificador, doc.Mime, doc.Nombre, ISNULL(Bucket,'') AS Bucket
				FROM	MM_DocumentosAnexos doc
				WHERE	doc.IdDocumentoAnexo=@IdDocumento
			END

		--9 Cotizacion/Oferta Anexos
		IF(@TipoDocumento=9)
			BEGIN
				SELECT	doc.Carpeta, doc.Identificador, doc.Mime, doc.NomDocumento,ISNULL(Bucket,'') AS Bucket
				FROM	MM_DocAnexosPeticionOferta doc
				WHERE	doc.IdDocAnexoPeticionOferta=@IdDocumento
			END

		--10 Documentos Anexos Pedido
		IF(@TipoDocumento=10)
			BEGIN
				SELECT	doc.Carpeta, doc.Identificador, doc.Mime, doc.NombreDocumento,ISNULL(Bucket,'') AS Bucket
				FROM	dbo.DocumentosPedido doc
				WHERE	doc.Id=@IdDocumento
			END

		-- 11 Adjudicacion directa desde la requisicion PCM
		IF(@TipoDocumento=11)
			BEGIN
				SELECT	Carpeta, Identificador, Mime, NombreDocumento,ISNULL(Bucket,'') AS Bucket
				FROM	dbo.PCMDocumentoAdjunto
				WHERE	IdDocumento=@IdDocumento
			END

	END

